import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/parent/domain/entities/student_info.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/student_edit_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

const _gradeOptions = <String>[
  'KG-A',
  'KG-B',
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
  'Grade 6',
];

class StudentEditScreen extends ConsumerWidget {
  const StudentEditScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(studentInfoProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (info) => _EditForm(info: info, studentId: studentId),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.info, required this.studentId});
  final StudentInfo info;
  final String studentId;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  static const _countryCode = '+962';
  late final TextEditingController _nameCtrl;
  late final TextEditingController _classCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _parentNameCtrl;
  late final TextEditingController _parentPhoneCtrl;
  late String _grade;

  @override
  void initState() {
    super.initState();
    final info = widget.info;
    _nameCtrl = TextEditingController(text: info.fullName);
    _classCtrl = TextEditingController(text: info.className ?? '');
    _notesCtrl = TextEditingController(text: info.notes ?? '');
    _parentNameCtrl = TextEditingController(text: info.parent?.name ?? '');
    _parentPhoneCtrl = TextEditingController(
      text: _stripCountryCode(info.parent?.phoneNumber ?? ''),
    );
    _grade = _gradeOptions.contains(info.grade) ? info.grade : info.grade;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _classCtrl.dispose();
    _notesCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    super.dispose();
  }

  String _stripCountryCode(String phone) {
    if (phone.startsWith(_countryCode)) {
      return phone.substring(_countryCode.length);
    }
    return phone;
  }

  String _composedPhone() {
    final cleaned = _parentPhoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith(_countryCode)) return cleaned;
    if (cleaned.startsWith('0')) return '$_countryCode${cleaned.substring(1)}';
    return '$_countryCode$cleaned';
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty ||
        _grade.trim().isEmpty ||
        _parentNameCtrl.text.trim().isEmpty ||
        _parentPhoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.studentEditMissingFields)));
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(studentEditControllerProvider(widget.studentId).notifier)
        .save(
          fullName: _nameCtrl.text.trim(),
          grade: _grade.trim(),
          className: _classCtrl.text.trim().isEmpty
              ? null
              : _classCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          parentName: _parentNameCtrl.text.trim(),
          parentPhone: _composedPhone(),
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.studentEditSaved)));
      context.pop();
      return;
    }
    final err =
        ref.read(studentEditControllerProvider(widget.studentId)).error;
    final msg = switch (err) {
      ValidationFailure(:final message) when message.isNotEmpty => message,
      Failure() => l.studentEditFailed,
      _ => l.studentEditFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final saving =
        ref.watch(studentEditControllerProvider(widget.studentId)).isLoading;

    return SafeArea(
      child: Column(
        children: [
          _Hero(info: widget.info, l: l),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -12, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                children: [
                  _SectionHead(title: l.studentEditBasicInfo),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _TextField(
                        icon: Icons.person_outline,
                        label: l.studentEditFullName,
                        controller: _nameCtrl,
                        enabled: !saving,
                        hint: l.studentEditFullNameHint,
                      ),
                      _ReadOnlyField(
                        icon: Icons.badge_outlined,
                        label: l.studentEditStudentId,
                        labelTag: l.studentEditAuto,
                        value: widget.info.nationalNumber,
                      ),
                      _Row2(
                        left: _DropdownField(
                          icon: Icons.school,
                          label: l.studentEditGrade,
                          value: _grade,
                          options: _gradeOptions,
                          enabled: !saving,
                          onChanged: (v) =>
                              setState(() => _grade = v ?? _grade),
                        ),
                        right: _TextField(
                          icon: Icons.grid_view,
                          label: l.studentEditClass,
                          controller: _classCtrl,
                          enabled: !saving,
                          hint: l.studentEditClassHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionHead(title: l.studentEditNotes),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _TextAreaField(
                        icon: Icons.description_outlined,
                        label: l.studentEditDriverNote,
                        controller: _notesCtrl,
                        enabled: !saving,
                        hint: l.studentEditNotesHint,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionHead(
                    title: l.studentEditParentInfo,
                    pillIcon: Icons.check,
                    pillText: l.studentEditVerified,
                  ),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _TextField(
                        icon: Icons.person_outline,
                        label: l.studentEditFullName,
                        controller: _parentNameCtrl,
                        enabled: !saving,
                        hint: l.studentEditParentNameHint,
                      ),
                      _PhoneField(
                        icon: Icons.call,
                        label: l.studentEditMobile,
                        controller: _parentPhoneCtrl,
                        enabled: !saving,
                        flag: '🇯🇴',
                        code: _countryCode,
                        hint: '7X XXX XXXX',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _SaveBar(
            cancelText: l.commonCancel,
            saveText: l.studentEditSave,
            saving: saving,
            onCancel: saving ? null : () => context.pop(),
            onSave: saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ───────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.info, required this.l});
  final StudentInfo info;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final classText =
        info.className == null || info.className!.isEmpty ? '' : ' · ${info.className}';
    final subtitle = '${info.nationalNumber} · ${info.grade}$classText';
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1F2E), Color(0xFF0F172A)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
        child: Column(
          children: [
            Row(
              children: [
                _DarkIconBtn(
                  icon: Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward
                      : Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l.studentEditEyebrow.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.7,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkIconBtn extends StatelessWidget {
  const _DarkIconBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: Icon(icon, size: 15, color: Colors.white)),
        ),
      ),
    );
  }
}

// ─── Section heading ───────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, this.pillIcon, this.pillText});
  final String title;
  final IconData? pillIcon;
  final String? pillText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.yellow,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.20),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.slate700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (pillText != null && pillIcon != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.emeraldSoft,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(pillIcon, size: 9, color: AppColors.emerald),
                  const SizedBox(width: 4),
                  Text(
                    pillText!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Card + fields ─────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
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
    this.labelTag,
    this.borderRight = false,
  });
  final IconData icon;
  final String label;
  final Widget child;
  final String? labelTag;
  final bool borderRight;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 42,
            decoration: BoxDecoration(
              border: Border(
                right: isRtl
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.slate100),
                left: isRtl
                    ? const BorderSide(color: AppColors.slate100)
                    : BorderSide.none,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.slate400),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 8),
              decoration: BoxDecoration(
                border: Border(
                  right: borderRight && !isRtl
                      ? const BorderSide(color: AppColors.slate100)
                      : BorderSide.none,
                  left: borderRight && isRtl
                      ? const BorderSide(color: AppColors.slate100)
                      : BorderSide.none,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate500,
                          letterSpacing: 0.7,
                        ),
                      ),
                      if (labelTag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            labelTag!,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.hint,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
    this.labelTag,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? labelTag;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      labelTag: labelTag,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.slate500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = {value, ...options}.toList();
    return _FieldShell(
      icon: icon,
      label: label,
      borderRight: true,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.expand_more,
              size: 16, color: AppColors.slate500),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.2,
          ),
          onChanged: enabled ? onChanged : null,
          items: [
            for (final o in items)
              DropdownMenuItem<String>(value: o, child: Text(o)),
          ],
        ),
      ),
    );
  }
}

class _Row2 extends StatelessWidget {
  const _Row2({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.slate100),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  const _TextAreaField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.hint,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.45,
          letterSpacing: -0.1,
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.flag,
    required this.code,
    required this.hint,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String flag;
  final String code;
  final String hint;

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
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  ],
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: 0.2,
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

// ─── Save bar ──────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.cancelText,
    required this.saveText,
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });
  final String cancelText;
  final String saveText;
  final bool saving;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.slate700,
              side: const BorderSide(color: AppColors.slate200, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 44),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
            child: Text(cancelText),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: onSave == null ? null : AppShadows.yellow,
              ),
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor:
                        AppColors.yellow.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.ink,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check,
                                size: 14, color: AppColors.ink),
                            const SizedBox(width: 6),
                            Text(saveText),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

