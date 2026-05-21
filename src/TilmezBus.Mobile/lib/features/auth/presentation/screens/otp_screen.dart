import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/otp_controller.dart';
import 'package:tilmez_bus/features/auth/presentation/screens/login_screen.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

const int _otpLength = 4;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // Single source of truth — one hidden TextField captures all input
  // (number pad, backspace, paste). The visible boxes are read-only and
  // just display individual digits from this controller. This pattern
  // keeps the iOS keyboard open across all 4 positions; the multi-field
  // approach was making iOS drop focus between fields and dismiss the
  // keyboard on every keystroke.
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(otpControllerProvider).valueOrNull;
      if (s is OtpPending) {
        _restartTimer(s.expiresAt);
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ctrl.removeListener(_onTextChanged);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Auto-submit once the full code is typed.
    if (_ctrl.text.length == _otpLength) {
      _verify();
    }
  }

  void _restartTimer(DateTime expiresAt) {
    _ticker?.cancel();
    _remaining = expiresAt.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final r = expiresAt.difference(DateTime.now());
      setState(() => _remaining = r.isNegative ? Duration.zero : r);
    });
  }

  String get _enteredCode => _ctrl.text;
  bool get _codeComplete => _enteredCode.length == _otpLength;

  Future<void> _verify() async {
    if (!_codeComplete) return;
    FocusScope.of(context).unfocus();
    final ok =
        await ref.read(otpControllerProvider.notifier).verifyOtp(_enteredCode);
    if (!mounted || ok) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.otpInvalid)));
    _ctrl.clear();
    _focus.requestFocus();
  }

  Future<void> _resend() async {
    final pending = ref.read(otpControllerProvider).valueOrNull;
    if (pending is! OtpPending) return;
    // Honor the visible countdown — a request before it elapses would just
    // come back as a server cooldown error anyway. Show a localized message
    // tied to the 2-minute timer so the user knows how long to wait.
    if (_remaining > Duration.zero) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.otpResendWait(_formatRemaining()))),
      );
      return;
    }
    try {
      final ok = await ref.read(otpControllerProvider.notifier).requestOtp(
            phoneNumber: pending.phoneNumber,
          );
      if (!mounted) return;
      if (ok) {
        final fresh = ref.read(otpControllerProvider).valueOrNull;
        if (fresh is OtpPending) _restartTimer(fresh.expiresAt);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    }
  }

  void _back() {
    ref.read(otpControllerProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoute.login);
    }
  }

  String _formatRemaining() {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _prettyPhone(String e164) {
    final m = RegExp(r'^\+962(\d{2})(\d{3})(\d{4})$').firstMatch(e164);
    if (m == null) return e164;
    return '+962 ${m.group(1)} ${m.group(2)} ${m.group(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loading = ref.watch(otpControllerProvider).isLoading;
    final pending = ref.watch(otpControllerProvider).valueOrNull;
    final phone = pending is OtpPending ? _prettyPhone(pending.phoneNumber) : '';

    return Scaffold(
      backgroundColor: Colors.white,
      // Static layout — content is anchored to the top of the screen so
      // it never moves when the keyboard appears or focus changes. The
      // OTP card sits high enough that the keyboard never covers it on
      // any modern iPhone, so we don't need keyboard-aware padding.
      resizeToAvoidBottomInset: false,
      body: AuthBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      // Bottom padding > top padding so MainAxisAlignment.center
                      // sits visually a bit above true-center — clear of the
                      // keyboard area when it's open.
                      padding: const EdgeInsets.fromLTRB(22, 40, 22, 220),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const BrandBlock(showTagline: false),
                          const SizedBox(height: 24),
                          _OtpCard(
                            title: l.otpTitle,
                            sentLabel: l.otpSentTo,
                            sentTo: phone,
                            verifyLabel: l.otpConfirm,
                            resendPrefix: l.otpResendPrefix,
                            resendLabel: l.otpResend,
                            countdown: _formatRemaining(),
                            controller: _ctrl,
                            focusNode: _focus,
                            onSubmit: _verify,
                            // Disable until the OTP countdown elapses —
                            // a server cooldown would reject early
                            // resends anyway and the gray-out signals it.
                            onResend: (loading || _remaining > Duration.zero)
                                ? null
                                : _resend,
                            loading: loading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                    child: Text(
                      l.otpFooter,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate400,
                        letterSpacing: -0.05,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                top: 14,
                start: 18,
                child: _BackPill(label: l.otpBack, onTap: _back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Back pill (replaces the lang button on this screen) ─────────────────────

class _BackPill extends StatelessWidget {
  const _BackPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slate50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: AppColors.slate100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 13, color: AppColors.slate700),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OTP card ────────────────────────────────────────────────────────────────

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.title,
    required this.sentLabel,
    required this.sentTo,
    required this.verifyLabel,
    required this.resendPrefix,
    required this.resendLabel,
    required this.countdown,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onResend,
    required this.loading,
  });

  final String title;
  final String sentLabel;
  final String sentTo;
  final String verifyLabel;
  final String resendPrefix;
  final String resendLabel;
  final String countdown;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback? onResend;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.45,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (sentTo.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    sentLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                      letterSpacing: -0.05,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Force LTR so the leading "+" and the digits keep their
                // natural left-to-right order even when the app locale is
                // Arabic — phone numbers shouldn't mirror.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    sentTo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _OtpRow(controller: controller, focusNode: focusNode),
          const SizedBox(height: 14),
          // Verify button enables itself when the controller has 4 digits.
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) => _VerifyButton(
              label: verifyLabel,
              loading: loading,
              enabled: controller.text.length == _otpLength,
              onPressed: onSubmit,
            ),
          ),
          const SizedBox(height: 14),
          _ResendRow(
            resendPrefix: resendPrefix,
            resendLabel: resendLabel,
            countdown: countdown,
            onResend: onResend,
          ),
        ],
      ),
    );
  }
}

// ── OTP input: 4 visual boxes backed by a single hidden TextField ───────────
//
// Why: with 4 separate TextFields and focus-jumping in onChanged, iOS drops
// focus between fields each keystroke, which dismisses + re-presents the
// software keyboard and shifts the layout. It also makes backspace tricky
// because an already-empty field doesn't fire onChanged. With one input,
// the keyboard stays attached for the whole sequence and the native
// backspace deletes the last digit naturally.

class _OtpRow extends StatelessWidget {
  const _OtpRow({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: focusNode.requestFocus,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Visual boxes — read directly from the shared controller.
          AnimatedBuilder(
            animation: Listenable.merge([controller, focusNode]),
            builder: (_, _) {
              final text = controller.text;
              final focused = focusNode.hasFocus;
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: List.generate(_otpLength, (i) {
                    final filled = i < text.length;
                    // The "active" box is where the next digit will go.
                    final active = focused && i == text.length;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 9),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _OtpVisualBox(
                            digit: filled ? text[i] : '',
                            active: active,
                            filled: filled,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          // Invisible TextField overlaid across the whole row that
          // actually owns the keyboard. Zero opacity so it doesn't show,
          // but still receives input + caret.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: _otpLength,
                scrollPadding: EdgeInsets.zero,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only single-box visual. Doesn't own any controller or focus —
/// just renders whatever the parent tells it.
class _OtpVisualBox extends StatelessWidget {
  const _OtpVisualBox({
    required this.digit,
    required this.active,
    required this.filled,
  });

  final String digit;
  final bool active;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bg;
    if (active) {
      borderColor = AppColors.yellowDeep;
      bg = Colors.white;
    } else if (filled) {
      borderColor = AppColors.ink;
      bg = Colors.white;
    } else {
      borderColor = AppColors.slate200;
      bg = AppColors.slate50;
    }
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: label,
      loading: loading,
      onPressed: enabled ? onPressed : null,
      trailingIcon: Icons.check,
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.resendPrefix,
    required this.resendLabel,
    required this.countdown,
    required this.onResend,
  });
  final String resendPrefix;
  final String resendLabel;
  final String countdown;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final disabled = onResend == null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: onResend,
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                  letterSpacing: -0.05,
                ),
                children: [
                  TextSpan(text: '$resendPrefix '),
                  TextSpan(
                    text: resendLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: disabled
                          ? AppColors.slate400
                          : AppColors.yellowDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time,
                  size: 11, color: AppColors.slate700),
              const SizedBox(width: 5),
              Text(
                countdown,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
