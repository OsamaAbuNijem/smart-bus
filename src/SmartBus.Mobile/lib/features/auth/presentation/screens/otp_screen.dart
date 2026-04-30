import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/presentation/providers/otp_controller.dart';
import 'package:smart_bus/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bus/features/auth/presentation/widgets/login_top_section.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

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
    final ok = await ref.read(otpControllerProvider.notifier).requestOtp(
          phoneNumber: pending.phoneNumber,
          role: pending.role,
        );
    if (!mounted) return;
    if (ok) {
      final fresh = ref.read(otpControllerProvider).valueOrNull;
      if (fresh is OtpPending) _restartTimer(fresh.expiresAt);
    }
  }

  String _formatRemaining() {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _prettyPhone(String e164) {
    // +9627XXXXXXXX → +962 7X XXX XXXX (very simple; just for display).
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
      body: LoginBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  LoginTopSection(
                    title: l.otpHeroTitle,
                    subtitle: l.otpHeroSubtitle,
                    showBadges: false,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                      child: _OtpCard(
                        eyebrow: l.otpEyebrow,
                        title: l.otpTitle,
                        sentTo: phone,
                        sentLabel: l.otpSentTo,
                        ctrls: _ctrls,
                        focusNodes: _focusNodes,
                        onChanged: (_) => setState(() {}),
                        onComplete: _verify,
                        onSubmit: _verify,
                        onResend: loading ? null : _resend,
                        loading: loading,
                        codeComplete: _codeComplete,
                        confirmLabel: l.otpConfirm,
                        resendPrefix: l.otpResendPrefix,
                        resendLabel: l.otpResend,
                        countdown: _formatRemaining(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
                    child: Text(
                      l.otpFooter,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate400,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const Positioned(top: 14, right: 18, child: LangSwitchButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.eyebrow,
    required this.title,
    required this.sentTo,
    required this.sentLabel,
    required this.ctrls,
    required this.focusNodes,
    required this.onChanged,
    required this.onComplete,
    required this.onSubmit,
    required this.onResend,
    required this.loading,
    required this.codeComplete,
    required this.confirmLabel,
    required this.resendPrefix,
    required this.resendLabel,
    required this.countdown,
  });

  final String eyebrow;
  final String title;
  final String sentTo;
  final String sentLabel;
  final List<TextEditingController> ctrls;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;
  final VoidCallback onSubmit;
  final VoidCallback? onResend;
  final bool loading;
  final bool codeComplete;
  final String confirmLabel;
  final String resendPrefix;
  final String resendLabel;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      child: Column(
        children: [
          _CardEyebrow(label: eyebrow),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (sentTo.isNotEmpty)
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                ),
                children: [
                  TextSpan(text: '$sentLabel '),
                  TextSpan(
                    text: sentTo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 14),
          _OtpRow(
            ctrls: ctrls,
            focusNodes: focusNodes,
            onChanged: onChanged,
            onComplete: onComplete,
          ),
          const SizedBox(height: 18),
          _ConfirmButton(
            label: confirmLabel,
            loading: loading,
            enabled: codeComplete,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onResend,
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                      children: [
                        TextSpan(text: '$resendPrefix '),
                        TextSpan(
                          text: resendLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.blue,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.slate400,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      countdown,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardEyebrow extends StatelessWidget {
  const _CardEyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.yellow],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.yellowDeep,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 14,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.yellow, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_otpLength, (i) {
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
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
    final showAccent = filled || focused;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 58,
      height: 64,
      decoration: BoxDecoration(
        color: filled ? AppColors.yellowTint : AppColors.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: showAccent ? AppColors.yellowDeep : AppColors.slate200,
          width: showAccent ? 2 : 1.5,
        ),
        boxShadow: showAccent
            ? [
                BoxShadow(
                  color: AppColors.yellow
                      .withValues(alpha: focused ? 0.18 : 0.10),
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        showCursor: true,
        cursorColor: AppColors.yellowDeep,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
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
    final actionable = enabled && !loading;
    return Opacity(
      opacity: actionable ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: actionable ? AppShadows.yellow : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: actionable ? onPressed : null,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.yellow, AppColors.yellowDeep],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.ink,
                      ),
                    )
                  else ...[
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16, color: AppColors.ink),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
