import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/routing/app_router.dart';
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
      final state = ref.read(otpControllerProvider).valueOrNull;
      if (state is OtpPending) {
        _restartTimer(state.expiresAt);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loading = ref.watch(otpControllerProvider).isLoading;
    final pending = ref.watch(otpControllerProvider).valueOrNull;
    final phoneShown = pending is OtpPending ? pending.phoneNumber : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const _BackgroundBlob(),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: _BackButton(
                          onPressed: () => context.go(AppRoute.login),
                        ),
                      ),
                    ),
                    const LoginTopSection(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              l.otpTitle,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            if (phoneShown.isNotEmpty)
                              Text(
                                phoneShown,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.text2,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 28),
                            _OtpRow(
                              controllers: _ctrls,
                              focusNodes: _focusNodes,
                              onChanged: (_) => setState(() {}),
                              onComplete: _verify,
                            ),
                            const SizedBox(height: 28),
                            _PrimaryButton(
                              label: l.otpConfirm,
                              loading: loading,
                              onPressed: _codeComplete ? _verify : null,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: loading ? null : _resend,
                                  child: Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.text3,
                                      ),
                                      children: [
                                        TextSpan(text: '${l.otpResendPrefix} '),
                                        TextSpan(
                                          text: l.otpResend,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  l.otpExpires(_formatRemaining()),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.text3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                      child: Text(
                        l.otpFooter,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const Positioned(top: 8, right: 16, child: LangSwitchButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onComplete,
  });
  final List<TextEditingController> controllers;
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
            padding: EdgeInsets.only(left: i == 0 ? 0 : 14),
            child: _OtpBox(
              controller: controllers[i],
              focusNode: focusNodes[i],
              onChanged: (value) {
                if (value.isNotEmpty && i < _otpLength - 1) {
                  focusNodes[i + 1].requestFocus();
                }
                if (value.isEmpty && i > 0) {
                  focusNodes[i - 1].requestFocus();
                }
                onChanged(value);
                final allFilled = controllers.every((c) => c.text.isNotEmpty);
                if (allFilled) onComplete();
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
      width: 60,
      height: 68,
      decoration: BoxDecoration(
        color: filled ? AppColors.yellowLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showAccent ? AppColors.yellow : AppColors.border,
          width: showAccent ? 1.8 : 1,
        ),
        boxShadow: [
          if (focused)
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.50),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.text,
            disabledBackgroundColor:
                AppColors.yellow.withValues(alpha: 0.45),
            disabledForegroundColor: AppColors.text.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.text,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.yellow.withValues(alpha: 0.20),
                      AppColors.yellow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.blue.withValues(alpha: 0.10),
                      AppColors.blue.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
