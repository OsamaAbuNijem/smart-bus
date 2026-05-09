import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/errors/failures.dart';
import 'package:smart_bus/core/locale/locale_controller.dart';
import 'package:smart_bus/core/storage/secure_storage.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:smart_bus/features/auth/domain/entities/user.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class AssistantSettingsScreen extends ConsumerStatefulWidget {
  const AssistantSettingsScreen({super.key});

  @override
  ConsumerState<AssistantSettingsScreen> createState() =>
      _AssistantSettingsScreenState();
}

class _AssistantSettingsScreenState
    extends ConsumerState<AssistantSettingsScreen> {
  static const _countryCode = '+962';

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      // The stored phone is in E.164 (+962XXXXXXXXX). Show only the local
      // 9-digit portion for editing — country code is rendered separately.
      _phoneCtrl.text =
          user.phoneNumber.startsWith(_countryCode)
              ? user.phoneNumber.substring(_countryCode.length)
              : user.phoneNumber.replaceAll(RegExp(r'\D'), '');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _phoneValid =>
      _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 8;
  bool get _canSave =>
      !_saving && _nameCtrl.text.trim().isNotEmpty && _phoneValid;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
      final stripped = digits.startsWith('0') ? digits.substring(1) : digits;
      final phone = '$_countryCode$stripped';

      final ds = ref.read(assistantRemoteDataSourceProvider);
      await ds.updateMyProfile(
        fullName: _nameCtrl.text.trim(),
        phoneNumber: phone,
      );

      // Mirror updates into local secure storage so the home greeting +
      // OTP-prefill stay in sync without a full re-login.
      final storage = ref.read(secureStorageProvider);
      await Future.wait([
        storage.writeFullName(_nameCtrl.text.trim()),
        storage.writePhoneNumber(phone),
      ]);
      // Refresh the auth controller so the UI updates immediately.
      ref.invalidate(authControllerProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsSaved)),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l.settingsLogoutTitle),
          content: Text(l.settingsLogoutBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.settingsCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l.settingsLogout),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final localeAsync = ref.watch(localeControllerProvider);
    final currentLang = localeAsync.valueOrNull?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _ProfileHero(
              name: _nameCtrl.text.trim().isEmpty
                  ? (user?.fullName ?? '')
                  : _nameCtrl.text.trim(),
              phone: user?.phoneNumber ?? '',
              role: user?.role ?? UserRole.assistant,
              roleLabel: switch (user?.role) {
                UserRole.driver => l.loginRoleDriver,
                UserRole.parent => l.loginRoleParent,
                _ => l.loginRoleAssistant,
              },
            ),
            const SizedBox(height: 22),
            _SectionLabel(text: l.settingsLanguage),
            const SizedBox(height: 10),
            _LanguageSegmented(
              current: currentLang,
              onChanged: (code) => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(code),
            ),
            const SizedBox(height: 22),
            _SectionLabel(text: l.settingsProfile),
            const SizedBox(height: 10),
            _InputCard(
              icon: Icons.person_outline_rounded,
              label: l.settingsFullName,
              child: TextField(
                controller: _nameCtrl,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l.settingsFullNameHint,
                  hintStyle: const TextStyle(
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            _InputCard(
              icon: Icons.call_outlined,
              label: l.settingsPhoneNumber,
              leadingTrailing: const _CountryChip(),
              child: TextField(
                controller: _phoneCtrl,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: const InputDecoration(
                  hintText: '7XX XXX XXX',
                  hintStyle: TextStyle(
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 0.6,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 28),
            _PrimarySaveButton(
              loading: _saving,
              enabled: _canSave,
              onTap: _save,
              label: l.settingsSave,
            ),
            const SizedBox(height: 10),
            _LogoutButton(label: l.settingsLogout, onTap: _logout),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.slate500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Profile hero ──────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.phone,
    required this.role,
    required this.roleLabel,
  });
  final String name;
  final String phone;
  final UserRole role;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? '—' : name;
    // Per-role palette so the hero matches the home brand mark for that
    // role: yellow for assistant, blue for driver, violet otherwise.
    final (avatarA, avatarB, avatarFg, glow) = switch (role) {
      UserRole.driver => (
          AppColors.blue,
          const Color(0xFF1E40AF),
          Colors.white,
          const Color(0x802563EB),
        ),
      UserRole.parent => (
          AppColors.violet,
          const Color(0xFF5B21B6),
          Colors.white,
          const Color(0x807C3AED),
        ),
      _ => (
          AppColors.yellow,
          AppColors.yellowDeep,
          AppColors.ink,
          const Color(0x80F5C518),
        ),
    };
    final (pillBg, pillBorder, pillFg) = switch (role) {
      UserRole.driver => (
          AppColors.blueSoft,
          AppColors.blue.withValues(alpha: 0.3),
          AppColors.blueDark,
        ),
      _ => (
          AppColors.violetSoft,
          const Color(0xFFDDD6FE),
          AppColors.violet,
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [avatarA, avatarB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: glow,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(displayName),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: avatarFg,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: pillBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 11, color: pillFg),
                const SizedBox(width: 5),
                Text(
                  roleLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: pillFg,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_outlined,
                    size: 12, color: AppColors.slate500),
                const SizedBox(width: 5),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '👤';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

// ── Input card ────────────────────────────────────────────────────────────
//
// Single-row input field: leading icon, stacked tiny label + the actual
// TextField inline next to it. The whole card highlights yellow on focus
// (we listen on the TextField's focus node nested inside).

class _InputCard extends StatefulWidget {
  const _InputCard({
    required this.icon,
    required this.label,
    required this.child,
    this.leadingTrailing,
  });
  final IconData icon;
  final String label;
  final Widget child;
  /// Optional widget to render between the icon and the input — used for the
  /// country-code chip on the phone field.
  final Widget? leadingTrailing;

  @override
  State<_InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<_InputCard> {
  final FocusScopeNode _scope = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _scope.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _scope.hasFocus;
    return GestureDetector(
      onTap: () => _scope.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused ? AppColors.yellowDeep : AppColors.slate200,
            width: focused ? 1.6 : 1,
          ),
          boxShadow: focused
              ? const [
                  BoxShadow(
                    color: Color(0x40F5C518),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    focused ? AppColors.yellowTint : AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: focused ? AppColors.yellowDeep : AppColors.slate600,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: focused
                          ? AppColors.yellowDeep
                          : AppColors.slate500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.leadingTrailing != null) ...[
                        widget.leadingTrailing!,
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FocusScope(
                          node: _scope,
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.slate200),
      ),
      child: const Text(
        '🇯🇴  +962',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.slate700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ── Language segmented control (plain text, no icons) ────────────────────

class _LanguageSegmented extends StatelessWidget {
  const _LanguageSegmented({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LanguageSegment(
              label: 'English',
              selected: current == 'en',
              onTap: () => onChanged('en'),
            ),
          ),
          Expanded(
            child: _LanguageSegment(
              label: 'العربية',
              selected: current == 'ar',
              onTap: () => onChanged('ar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected ? AppShadows.sm : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
            color: selected ? AppColors.ink : AppColors.slate500,
          ),
        ),
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────

class _PrimarySaveButton extends StatelessWidget {
  const _PrimarySaveButton({
    required this.loading,
    required this.enabled,
    required this.onTap,
    required this.label,
  });
  final bool loading, enabled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.yellow, AppColors.yellowDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled ? AppShadows.yellow : null,
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ink,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: AppColors.ink),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 16, color: AppColors.red),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.red,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
