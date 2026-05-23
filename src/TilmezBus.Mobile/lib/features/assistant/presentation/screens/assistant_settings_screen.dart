import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/locale/locale_controller.dart';
import 'package:tilmez_bus/core/storage/secure_storage.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/features/auth/domain/entities/user.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

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
      _phoneCtrl.text = user.phoneNumber.startsWith(_countryCode)
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

      // Profile-update endpoint only exists for the driver/assistant flow.
      // Parents save locally — name/phone live in the JWT and are mirrored
      // to secure storage below so the home greeting + OTP-prefill stay in
      // sync.
      final user = ref.read(authControllerProvider).valueOrNull;
      if (user?.role != UserRole.parent) {
        final ds = ref.read(assistantRemoteDataSourceProvider);
        await ds.updateMyProfile(
          fullName: _nameCtrl.text.trim(),
          phoneNumber: phone,
        );
      }

      final storage = ref.read(secureStorageProvider);
      await Future.wait([
        storage.writeFullName(_nameCtrl.text.trim()),
        storage.writePhoneNumber(phone),
      ]);
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
    final localeAsync = ref.watch(localeControllerProvider);
    final currentLang = localeAsync.valueOrNull?.languageCode ?? 'en';
    // The "School info" card is only meaningful for crew members — the
    // backing API resolves the school via Drivers.UserId, which parents
    // don't have. Skip the section entirely on the parent settings page.
    final role = ref.watch(authControllerProvider).valueOrNull?.role;
    final showSchoolInfo =
        role == UserRole.driver || role == UserRole.assistant;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _Hero(title: l.settingsTitle, onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              children: [
                _SectionTitle(text: l.settingsLanguage),
                const SizedBox(height: 8),
                _Card(
                  children: [
                    _LanguageOptionTile(
                      icon: Icons.language,
                      label: 'English',
                      selected: currentLang == 'en',
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLocale('en'),
                    ),
                    _LanguageOptionTile(
                      icon: Icons.language,
                      label: 'العربية',
                      selected: currentLang == 'ar',
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLocale('ar'),
                    ),
                  ],
                ),
                if (showSchoolInfo) ...[
                  const SizedBox(height: 14),
                  _SectionTitle(text: l.settingsSchoolInfo),
                  const SizedBox(height: 8),
                  _SchoolInfoCard(l: l),
                ],
                const SizedBox(height: 14),
                _SectionTitle(text: l.settingsProfile),
                const SizedBox(height: 8),
                _Card(
                  children: [
                    _TextFieldRow(
                      icon: Icons.person_outline,
                      label: l.settingsFullName,
                      controller: _nameCtrl,
                      enabled: !_saving,
                      hint: l.settingsFullNameHint,
                      onChanged: (_) => setState(() {}),
                    ),
                    _PhoneFieldRow(
                      icon: Icons.call_outlined,
                      label: l.settingsPhoneNumber,
                      controller: _phoneCtrl,
                      enabled: !_saving,
                      flag: '🇯🇴',
                      code: _countryCode,
                      hint: '7X XXX XXXX',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LogoutTile(label: l.settingsLogout, onTap: _logout),
              ],
            ),
          ),
          _SaveBar(
            saveText: l.settingsSave,
            saving: _saving,
            onSave: _canSave ? _save : null,
          ),
        ],
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.slate100)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Row(
          children: [
            _LightIconBtn(
              icon: Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward
                  : Icons.arrow_back,
              onTap: onBack,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightIconBtn extends StatelessWidget {
  const _LightIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slate50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: const BorderSide(color: AppColors.slate100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: Icon(
              icon,
              size: 17,
              color: AppColors.slate700,
              // Pin to LTR so Icons.arrow_forward stays → in Arabic instead
              // of auto-flipping to ← via matchTextDirection.
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppColors.slate500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─── School info card ──────────────────────────────────────────────

/// Reads the lightweight school info from `myFleetSchoolProvider` and
/// renders a card with name / city (area) / phone. Falls back to a
/// neutral empty state when the user isn't linked to any school yet.
class _SchoolInfoCard extends ConsumerWidget {
  const _SchoolInfoCard({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myFleetSchoolProvider);
    return async.when(
      loading: () => Container(
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate200),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => _Card(
        children: [
          _ReadOnlyRow(
            icon: Icons.error_outline,
            label: l.settingsSchoolInfo,
            value: l.settingsSchoolMissing,
          ),
        ],
      ),
      data: (s) {
        if (s == null) {
          return _Card(
            children: [
              _ReadOnlyRow(
                icon: Icons.school_outlined,
                label: l.settingsSchoolName,
                value: l.settingsSchoolMissing,
              ),
            ],
          );
        }
        return _Card(
          children: [
            _ReadOnlyRow(
              icon: Icons.school_outlined,
              label: l.settingsSchoolName,
              value: s.name.isEmpty ? '—' : s.name,
            ),
            _ReadOnlyRow(
              icon: Icons.place_outlined,
              label: l.settingsSchoolCity,
              value: (s.city == null || s.city!.isEmpty) ? '—' : s.city!,
            ),
            _ReadOnlyRow(
              icon: Icons.call_outlined,
              label: l.settingsSchoolPhone,
              // Render phone LTR so '+962…' doesn't flip in Arabic.
              value: (s.phoneNumber == null || s.phoneNumber!.isEmpty)
                  ? '—'
                  : s.phoneNumber!,
              valueDir: TextDirection.ltr,
            ),
          ],
        );
      },
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueDir,
  });
  final IconData icon;
  final String label;
  final String value;
  final TextDirection? valueDir;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: Directionality(
        textDirection: valueDir ?? Directionality.of(context),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.slate700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ─── Card + fields (mirrors student info screen) ───────────────────

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.slate100,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.icon,
    required this.label,
    required this.child,
  });
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // Skip IntrinsicHeight here — text-field intrinsic measurement can
    // round 1 px short of the column's actual rendered height and cause an
    // overflow stripe. A plain Row + a separately-painted divider keeps the
    // icon column flush with the field without needing intrinsic sizing.
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: isRtl
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 42),
              child: Container(
                width: 1,
                color: AppColors.slate100,
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              child: Icon(icon, size: 16, color: AppColors.slate400),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate500,
                        letterSpacing: 0.7,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  const _TextFieldRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.hint,
    this.onChanged,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.words,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.slate400,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          filled: false,
        ),
      ),
    );
  }
}

class _PhoneFieldRow extends StatelessWidget {
  const _PhoneFieldRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.flag,
    required this.code,
    required this.hint,
    this.onChanged,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String flag;
  final String code;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 14, height: 1)),
                    const SizedBox(width: 6),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 14,
                color: AppColors.slate200,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 13.5,
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
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Language option (row inside the card) ─────────────────────────

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: _FieldShell(
        icon: icon,
        label: '',
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.yellowTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x66F5C518)),
                ),
                child: const Icon(
                  Icons.check,
                  size: 13,
                  color: AppColors.yellowDeep,
                ),
              )
            else
              const SizedBox(width: 22, height: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Logout tile (destructive, rendered above save bar) ────────────

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.red.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.logout, size: 16, color: AppColors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.red,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Save bar ──────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saveText,
    required this.saving,
    required this.onSave,
  });
  final String saveText;
  final bool saving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
              disabledBackgroundColor:
                  AppColors.yellow.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            child: saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.ink,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.ink),
                      const SizedBox(width: 7),
                      Text(saveText),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

