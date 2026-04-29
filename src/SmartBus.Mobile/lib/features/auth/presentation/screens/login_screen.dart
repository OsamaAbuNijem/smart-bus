import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/core/locale/locale_controller.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/domain/entities/user.dart';
import 'package:smart_bus/features/auth/presentation/providers/otp_controller.dart';
import 'package:smart_bus/features/auth/presentation/widgets/login_top_section.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _countryCode = '+962';
  static const _flag = '🇯🇴';
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _normalisedPhone() {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final stripped = digits.startsWith('0') ? digits.substring(1) : digits;
    return '$_countryCode$stripped';
  }

  bool get _phoneValid =>
      _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 8;

  Future<void> _submit() async {
    if (!_phoneValid) return;
    FocusScope.of(context).unfocus();
    // The router auto-navigates to /otp when OtpController flips to
    // OtpPending; no need to call context.go here.
    final ok = await ref.read(otpControllerProvider.notifier).requestOtp(
          phoneNumber: _normalisedPhone(),
          role: UserRole.parent,
        );
    if (!mounted || ok) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.loginUnknownError)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loading = ref.watch(otpControllerProvider).isLoading;

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
                    const LoginTopSection(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              l.loginTitle,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.loginSendOtpHint,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.text2,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            _PhoneField(
                              controller: _phoneCtrl,
                              flag: _flag,
                              code: _countryCode,
                              hint: l.loginPhonePlaceholder,
                              enabled: !loading,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            _PrimaryButton(
                              label: l.loginSendOtp,
                              loading: loading,
                              onPressed: _phoneValid ? _submit : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                      child: Text(
                        l.loginTerms,
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

/// Soft yellow accent in the upper-left, fades to white. Subtle, premium.
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

class _PhoneField extends StatefulWidget {
  const _PhoneField({
    required this.controller,
    required this.flag,
    required this.code,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final String flag;
  final String code;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? AppColors.yellow : AppColors.border,
            width: focused ? 1.6 : 1,
          ),
          boxShadow: [
            if (focused)
              BoxShadow(
                color: AppColors.yellow.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(widget.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              widget.code,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1,
              height: 22,
              color: AppColors.border,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: AppColors.text3,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ],
        ),
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

class LangSwitchButton extends ConsumerWidget {
  const LangSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(localeControllerProvider).valueOrNull?.languageCode ??
            Localizations.localeOf(context).languageCode;
    final showLabel = current == 'en' ? 'عربي' : 'EN';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => ref.read(localeControllerProvider.notifier).toggleEnAr(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                showLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
