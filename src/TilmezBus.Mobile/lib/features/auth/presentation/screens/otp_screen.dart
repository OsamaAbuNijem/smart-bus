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
  late final List<TextEditingController> _ctrls;
  late final List<FocusNode> _focusNodes;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(otpControllerProvider).valueOrNull;
      if (s is OtpPending) {
        _restartTimer(s.expiresAt);
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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

  String get _enteredCode => _ctrls.map((c) => c.text).join();
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
    for (final c in _ctrls) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {});
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
      body: AuthBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(22, 56, 22, 12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 68,
                            ),
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
                                  ctrls: _ctrls,
                                  focusNodes: _focusNodes,
                                  onChanged: (_) => setState(() {}),
                                  onComplete: _verify,
                                  onSubmit: _verify,
                                  onResend: loading ? null : _resend,
                                  loading: loading,
                                  codeComplete: _codeComplete,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
    required this.ctrls,
    required this.focusNodes,
    required this.onChanged,
    required this.onComplete,
    required this.onSubmit,
    required this.onResend,
    required this.loading,
    required this.codeComplete,
  });

  final String title;
  final String sentLabel;
  final String sentTo;
  final String verifyLabel;
  final String resendPrefix;
  final String resendLabel;
  final String countdown;
  final List<TextEditingController> ctrls;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;
  final VoidCallback onSubmit;
  final VoidCallback? onResend;
  final bool loading;
  final bool codeComplete;

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
          _OtpRow(
            ctrls: ctrls,
            focusNodes: focusNodes,
            onChanged: onChanged,
            onComplete: onComplete,
          ),
          const SizedBox(height: 14),
          _VerifyButton(
            label: verifyLabel,
            loading: loading,
            enabled: codeComplete,
            onPressed: onSubmit,
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

// ── 4 OTP boxes (square, equal width, gap 9) ────────────────────────────────

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.ctrls,
    required this.focusNodes,
    required this.onChanged,
    required this.onComplete,
  });
  final List<TextEditingController> ctrls;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(_otpLength, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 9),
              child: AspectRatio(
                aspectRatio: 1,
                child: _OtpBox(
                  controller: ctrls[i],
                  focusNode: focusNodes[i],
                  onChanged: (v) {
                    if (v.isNotEmpty && i < _otpLength - 1) {
                      focusNodes[i + 1].requestFocus();
                    }
                    if (v.isEmpty && i > 0) {
                      focusNodes[i - 1].requestFocus();
                    }
                    onChanged(v);
                    if (ctrls.every((c) => c.text.isNotEmpty)) onComplete();
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    final focused = focusNode.hasFocus;
    final active = focused;

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          showCursor: true,
          cursorColor: AppColors.yellowDeep,
          cursorHeight: 24,
          cursorWidth: 2,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isCollapsed: true,
          ),
          onChanged: onChanged,
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
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.yellowDeep,
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
