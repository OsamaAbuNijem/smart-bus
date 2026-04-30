import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/errors/failures.dart';
import 'package:smart_bus/core/locale/locale_controller.dart';
import 'package:smart_bus/core/routing/app_router.dart';
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
  final _phoneFocus = FocusNode();
  bool _phoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (_phoneFocused != _phoneFocus.hasFocus) {
        setState(() => _phoneFocused = _phoneFocus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
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
    final ok = await ref.read(otpControllerProvider.notifier).requestOtp(
          phoneNumber: _normalisedPhone(),
          role: UserRole.parent,
        );
    if (!mounted) return;
    if (ok) {
      // Belt + suspenders: the router auto-redirects when state flips to
      // OtpPending, but call go() directly to avoid depending on the
      // listenable propagation timing.
      context.go(AppRoute.otp);
      return;
    }
    final l = AppLocalizations.of(context);
    final err = ref.read(otpControllerProvider).error;
    final msg = switch (err) {
      ValidationFailure() => l.loginPhoneNotRegistered,
      NotFoundFailure() => l.loginPhoneNotRegistered,
      NetworkFailure() => l.loginNetworkError,
      TimeoutFailure() => l.loginNetworkError,
      _ => l.loginUnknownError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _scanCardComingSoon() {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.loginScanComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loading = ref.watch(otpControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoginBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  LoginTopSection(
                    title: l.loginAppName,
                    subtitle: l.loginAppSubtitle,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                      child: _SignInCard(
                        eyebrow: l.loginEyebrow,
                        title: l.loginCardTitle,
                        description: l.loginCardDesc,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SegmentedControl(
                              activeIndex: 0,
                              labels: [l.loginTabPhone, l.loginTabScan],
                              icons: const [Icons.call, Icons.qr_code_2],
                              onChange: (i) {
                                if (i == 1) _scanCardComingSoon();
                              },
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l.loginPhoneLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _PhoneRow(
                              controller: _phoneCtrl,
                              focusNode: _phoneFocus,
                              focused: _phoneFocused,
                              flag: _flag,
                              code: _countryCode,
                              hint: l.loginPhonePlaceholder,
                              enabled: !loading,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 4),
                              child: Text(
                                l.loginPhoneHelp,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _GradientButton(
                              label: l.loginSendOtp,
                              loading: loading,
                              onPressed: _phoneValid ? _submit : null,
                              trailingIcon: Icons.arrow_forward,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
                    child: Text(
                      l.loginTerms,
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

// ── Reusable widgets used by both Login and OTP screens ────────────────────

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.eyebrow,
    required this.title,
    this.description,
    required this.child,
  });
  final String eyebrow;
  final String title;
  final String? description;
  final Widget child;

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
          _Eyebrow(label: eyebrow),
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
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});
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

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.activeIndex,
    required this.labels,
    required this.icons,
    required this.onChange,
  });
  final int activeIndex;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: active ? AppShadows.sm : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[i],
                      size: 14,
                      color: active ? AppColors.ink : AppColors.slate500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.ink : AppColors.slate500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.flag,
    required this.code,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final String flag;
  final String code;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: focused ? Colors.white : AppColors.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused ? AppColors.yellowDeep : AppColors.slate200,
            width: 1.5,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20, height: 1)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(right: 12),
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.slate200, width: 1.5),
                ),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: 0.1,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    this.trailingIcon,
  });
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled ? AppShadows.yellow : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
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
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 14, color: AppColors.ink),
                    ],
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

class LangSwitchButton extends ConsumerWidget {
  const LangSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(localeControllerProvider).valueOrNull?.languageCode ??
            Localizations.localeOf(context).languageCode;
    final showLabel = current == 'en' ? 'عربي' : 'EN';

    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.10),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () => ref.read(localeControllerProvider.notifier).toggleEnAr(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 7, 12, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 14, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                showLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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

// Re-export so OtpScreen imports from a single place.
class LoginShared {
  LoginShared._();
}
