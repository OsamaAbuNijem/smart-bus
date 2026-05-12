import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/errors/failures.dart';
import 'package:smart_bus/core/locale/locale_controller.dart';
import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/presentation/providers/otp_controller.dart';
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
      _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length == 9;

  Future<void> _submit() async {
    if (!_phoneValid) return;
    FocusScope.of(context).unfocus();
    final ok = await ref.read(otpControllerProvider.notifier).requestOtp(
          phoneNumber: _normalisedPhone(),
        );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoute.otp);
      return;
    }
    final l = AppLocalizations.of(context);
    final err = ref.read(otpControllerProvider).error;
    // Pass through the server's own message when it gave us one — that lets
    // the cooldown / role-mismatch / etc. text reach the user verbatim.
    // Fall back to the generic "phone not registered" copy only when we
    // truly don't have a better string.
    final msg = switch (err) {
      NotFoundFailure() => l.loginPhoneNotRegistered,
      NetworkFailure() => l.loginNetworkError,
      TimeoutFailure() => l.loginNetworkError,
      ValidationFailure(:final message) when message.isNotEmpty => message,
      ServerFailure(:final message) when message.isNotEmpty => message,
      Failure(:final message) when message.isNotEmpty => message,
      _ => l.loginUnknownError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loading = ref.watch(otpControllerProvider).isLoading;

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
                                const SizedBox(height: 20),
                                _SignInCard(
                                  title: l.loginCardTitle,
                                  description: l.loginCardDesc,
                                  phoneHint: l.loginPhonePlaceholder,
                                  sendLabel: l.loginSendOtp,
                                  phoneCtrl: _phoneCtrl,
                                  phoneFocus: _phoneFocus,
                                  phoneFocused: _phoneFocused,
                                  phoneValid: _phoneValid,
                                  flag: _flag,
                                  code: _countryCode,
                                  loading: loading,
                                  onChanged: (_) => setState(() {}),
                                  onClear: () {
                                    _phoneCtrl.clear();
                                    setState(() {});
                                  },
                                  onSubmit: _phoneValid ? _submit : null,
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
                      l.loginTerms,
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
              const Positioned(top: 14, right: 18, child: LangSwitchButton()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Backdrop (white phone-screen background, like the template) ────────────

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: child);
}

// ── Brand block (logo + tagline) ────────────────────────────────────────────

class BrandBlock extends StatelessWidget {
  const BrandBlock({super.key, this.showTagline = true});
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Image.asset(
          'assets/images/tilmez_bus_logo.png',
          height: 72,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        if (showTagline) ...[
          const SizedBox(height: 14),
          Text(
            l.loginTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
              letterSpacing: -0.05,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Sign-in card ────────────────────────────────────────────────────────────

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.title,
    required this.description,
    required this.phoneHint,
    required this.sendLabel,
    required this.phoneCtrl,
    required this.phoneFocus,
    required this.phoneFocused,
    required this.phoneValid,
    required this.flag,
    required this.code,
    required this.loading,
    required this.onChanged,
    required this.onClear,
    required this.onSubmit,
  });

  final String title;
  final String description;
  final String phoneHint;
  final String sendLabel;
  final TextEditingController phoneCtrl;
  final FocusNode phoneFocus;
  final bool phoneFocused;
  final bool phoneValid;
  final String flag;
  final String code;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onSubmit;

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
          const SizedBox(height: 4),
          // Reserve enough room for a 2-line description so the card height
          // stays stable when the locale flips (Arabic and English wrap to
          // different line counts at the same font size).
          SizedBox(
            height: 38,
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
                letterSpacing: -0.05,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PhoneRow(
            controller: phoneCtrl,
            focusNode: phoneFocus,
            focused: phoneFocused,
            valid: phoneValid,
            flag: flag,
            code: code,
            hint: phoneHint,
            enabled: !loading,
            onChanged: onChanged,
            onClear: onClear,
            onSubmitted: (_) => onSubmit?.call(),
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: sendLabel,
            loading: loading,
            onPressed: onSubmit,
            trailingIcon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.valid,
    required this.flag,
    required this.code,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool valid;
  final String flag;
  final String code;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: focused ? Colors.white : AppColors.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused
                ? AppColors.yellowDeep
                : (valid ? AppColors.emerald : AppColors.slate200),
            width: 1.5,
          ),
          boxShadow: [
            if (focused)
              BoxShadow(
                color: AppColors.yellow.withValues(alpha: 0.22),
                blurRadius: 0,
                spreadRadius: 4,
              ),
            if (focused)
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag,
                        style: const TextStyle(fontSize: 16, height: 1)),
                    const SizedBox(width: 6),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate700,
                        letterSpacing: -0.1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [
                    AutofillHints.telephoneNumberNational,
                  ],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    _JordanPhoneFormatter(),
                  ],
                  cursorColor: AppColors.yellowDeep,
                  cursorWidth: 1.6,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: 0.2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                child: _trailingAdornment(hasText: hasText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailingAdornment({required bool hasText}) {
    if (valid) {
      return Padding(
        key: const ValueKey('check'),
        padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 12, 0),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.emeraldSoft,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Icon(Icons.check, size: 13, color: AppColors.emerald),
        ),
      );
    }
    if (hasText) {
      return Padding(
        key: const ValueKey('clear'),
        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 6, 0),
        child: IconButton(
          onPressed: onClear,
          tooltip: 'Clear',
          splashRadius: 16,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(
            Icons.cancel,
            size: 18,
            color: AppColors.slate400,
          ),
        ),
      );
    }
    return const SizedBox(key: ValueKey('empty'), width: 0);
  }
}

// Auto-format Jordanian mobile numbers as `7X XXX XXXX` while typing.
class _JordanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buf.write(' ');
      buf.write(digits[i]);
    }
    final out = buf.toString();
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.ink,
                      ),
                    )
                  else ...[
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 7),
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

// ── Language switcher (top-right) ───────────────────────────────────────────

class LangSwitchButton extends ConsumerWidget {
  const LangSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(localeControllerProvider).valueOrNull?.languageCode ??
            Localizations.localeOf(context).languageCode;
    final showLabel = current == 'en' ? 'عربي' : 'EN';

    return Material(
      color: AppColors.slate50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: AppColors.slate100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () => ref.read(localeControllerProvider.notifier).toggleEnAr(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 13, color: AppColors.blue),
              const SizedBox(width: 5),
              Text(
                showLabel,
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

