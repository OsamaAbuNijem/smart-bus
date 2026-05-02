import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bus/core/errors/failures.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/parent/domain/entities/student_info.dart';
import 'package:smart_bus/features/parent/presentation/providers/absence_controller.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class ReportAbsenceScreen extends ConsumerWidget {
  const ReportAbsenceScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final infoAsync = ref.watch(studentInfoProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (info) => _Form(info: info, studentId: studentId, l: l),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({
    required this.info,
    required this.studentId,
    required this.l,
  });
  final StudentInfo info;
  final String studentId;
  final AppLocalizations l;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _noteCtrl = TextEditingController();
  late DateTime _selectedDate;
  AbsenceTripType _tripType = AbsenceTripType.fullDay;
  AbsenceReason _reason = AbsenceReason.illness;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(absenceControllerProvider(widget.studentId).notifier)
        .submit(
          date: _selectedDate,
          tripType: _tripType,
          reason: _reason,
          driverNote: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.l.absenceSubmitted)));
      context.pop();
      return;
    }
    final err =
        ref.read(absenceControllerProvider(widget.studentId)).error;
    final msg = switch (err) {
      ValidationFailure(:final message) when message.isNotEmpty => message,
      Failure() => widget.l.absenceFailed,
      _ => widget.l.absenceFailed,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final info = widget.info;
    final saving =
        ref.watch(absenceControllerProvider(widget.studentId)).isLoading;

    return Stack(
      children: [
        Column(
          children: [
            _Hero(l: l),
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(0, -12, 0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 90),
                  children: [
                    _SectionTitle(text: l.absenceSectionStudent),
                    const SizedBox(height: 8),
                    _StudentCard(info: info, l: l),
                    const SizedBox(height: 14),
                    _SectionTitle(text: l.absenceSectionDate),
                    const SizedBox(height: 8),
                    _DateRow(
                      selected: _selectedDate,
                      onSelect: (d) => setState(() => _selectedDate = d),
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(text: l.absenceSectionService),
                    const SizedBox(height: 8),
                    _OptionsList(
                      tripType: _tripType,
                      onChange: (t) => setState(() => _tripType = t),
                      l: l,
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(text: l.absenceSectionReason),
                    const SizedBox(height: 8),
                    _ReasonGrid(
                      selected: _reason,
                      onChange: (r) => setState(() => _reason = r),
                      l: l,
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(
                      text: l.absenceSectionNote,
                      subtitle: l.absenceOptional,
                    ),
                    const SizedBox(height: 8),
                    _NoteCard(
                      controller: _noteCtrl,
                      enabled: !saving,
                      hint: l.absenceNoteHint,
                    ),
                    const SizedBox(height: 14),
                    _InfoBox(text: l.absenceInfoBox),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _SubmitBar(
            label: l.absenceSubmit,
            saving: saving,
            onTap: saving ? null : _submit,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(child: _BackBtn(onTap: () => context.pop())),
        ),
      ],
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
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
            // Top eyebrow row — back button is positioned absolutely above us.
            Row(
              children: [
                const SizedBox(width: 36),
                Expanded(
                  child: Center(
                    child: Text(
                      l.absenceEyebrow.toUpperCase(),
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
                        l.absenceTitle,
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
                        l.absenceSubtitle,
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

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 0, 0),
      child: Material(
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
            child: Center(
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward
                    : Icons.arrow_back,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, this.subtitle});
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.slate700,
              letterSpacing: 1.0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Student card ──────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, required this.l});
  final StudentInfo info;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final classText = info.className == null || info.className!.isEmpty
        ? info.grade
        : '${info.grade} · ${l.studentInfoClassPrefix} ${info.className}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.yellow, AppColors.yellowDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(info.fullName),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  classText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate500,
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

// ─── Date row ──────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    // 3 past, today, 3 future
    final days = List.generate(7, (i) => t.add(Duration(days: i - 3)));

    return Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          Expanded(
            child: _DateChip(
              date: days[i],
              isPast: days[i].isBefore(t),
              isActive: _sameDay(days[i], selected),
              onTap: days[i].isBefore(t) ? null : () => onSelect(days[i]),
            ),
          ),
          if (i != days.length - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isPast,
    required this.isActive,
    required this.onTap,
  });
  final DateTime date;
  final bool isPast;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayNumColor = isActive ? AppColors.ink : AppColors.ink;
    final dayNameColor = isActive
        ? AppColors.ink.withValues(alpha: 0.7)
        : AppColors.slate500;
    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? null : (isPast ? AppColors.slate50 : Colors.white),
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.yellow, AppColors.yellowDeep],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.transparent : AppColors.slate200,
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.yellow.withValues(alpha: 0.55),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _dayName3(date.weekday),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: dayNameColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: dayNumColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Options ───────────────────────────────────────────────────────

class _OptionsList extends StatelessWidget {
  const _OptionsList({
    required this.tripType,
    required this.onChange,
    required this.l,
  });
  final AbsenceTripType tripType;
  final ValueChanged<AbsenceTripType> onChange;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptionRow(
          icon: Icons.do_not_disturb_on_outlined,
          iconColor: const Color(0xFFE11D48),
          iconBg: const Color(0xFFFFE4E6),
          iconBorder: const Color(0xFFFECDD3),
          title: l.absenceOptionFullTitle,
          desc: l.absenceOptionFullDesc,
          active: tripType == AbsenceTripType.fullDay,
          note: l.absenceFullNote,
          onTap: () => onChange(AbsenceTripType.fullDay),
        ),
        const SizedBox(height: 8),
        _OptionRow(
          icon: Icons.wb_sunny_outlined,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
          iconBorder: const Color(0xFFFDE68A),
          title: l.absenceOptionMorningTitle,
          desc: l.absenceOptionMorningDesc,
          active: tripType == AbsenceTripType.morningOnly,
          onTap: () => onChange(AbsenceTripType.morningOnly),
        ),
        const SizedBox(height: 8),
        _OptionRow(
          icon: Icons.arrow_back,
          iconColor: AppColors.violet,
          iconBg: AppColors.violetSoft,
          iconBorder: const Color(0xFFDDD6FE),
          title: l.absenceOptionReturnTitle,
          desc: l.absenceOptionReturnDesc,
          active: tripType == AbsenceTripType.returnOnly,
          onTap: () => onChange(AbsenceTripType.returnOnly),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.desc,
    required this.active,
    required this.onTap,
    this.note,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String desc;
  final bool active;
  final VoidCallback onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.yellowTint, Colors.white],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.yellowDeep : AppColors.slate200,
              width: 1.5,
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 3,
                )
              else
                ...AppShadows.sm,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      border: Border.all(color: iconBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Radio(active: active),
                ],
              ),
              if (active && note != null) ...[
                const SizedBox(height: 10),
                _OptNote(text: note!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: active ? AppColors.yellowDeep : AppColors.slate300,
          width: active ? 5.5 : 1.5,
        ),
      ),
    );
  }
}

class _OptNote extends StatelessWidget {
  const _OptNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.yellow,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 13,
            color: AppColors.yellowDeep,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.4,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reason grid ───────────────────────────────────────────────────

class _ReasonGrid extends StatelessWidget {
  const _ReasonGrid({
    required this.selected,
    required this.onChange,
    required this.l,
  });
  final AbsenceReason selected;
  final ValueChanged<AbsenceReason> onChange;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final reasons = <_ReasonData>[
      _ReasonData(
        AbsenceReason.illness,
        Icons.favorite_outline,
        const Color(0xFFE11D48),
        const Color(0xFFFFE4E6),
        const Color(0xFFFECDD3),
        l.absenceReasonIllness,
      ),
      _ReasonData(
        AbsenceReason.medicalAppointment,
        Icons.calendar_today_outlined,
        AppColors.blue,
        AppColors.blueSoft,
        const Color(0xFFBFDBFE),
        l.absenceReasonAppointment,
      ),
      _ReasonData(
        AbsenceReason.familyMatter,
        Icons.people_outline,
        AppColors.violet,
        AppColors.violetSoft,
        const Color(0xFFDDD6FE),
        l.absenceReasonFamily,
      ),
      _ReasonData(
        AbsenceReason.other,
        Icons.help_outline,
        AppColors.slate600,
        AppColors.slate100,
        AppColors.slate200,
        l.absenceReasonOther,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4.3,
      children: [
        for (final r in reasons)
          _ReasonTile(
            data: r,
            active: r.value == selected,
            onTap: () => onChange(r.value),
          ),
      ],
    );
  }
}

class _ReasonData {
  const _ReasonData(
    this.value,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.iconBorder,
    this.label,
  );
  final AbsenceReason value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String label;
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.data,
    required this.active,
    required this.onTap,
  });
  final _ReasonData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: active ? AppColors.yellowTint : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.yellowDeep : AppColors.slate200,
              width: 1.5,
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.15),
                  blurRadius: 0,
                  spreadRadius: 2,
                )
              else
                ...AppShadows.sm,
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  border: Border.all(color: data.iconBorder),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, size: 14, color: data.iconColor),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
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

// ─── Note + info + submit ──────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.controller,
    required this.enabled,
    required this.hint,
  });
  final TextEditingController controller;
  final bool enabled;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.slate400,
            fontWeight: FontWeight.w500,
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(12, 9, 12, 9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.yellowDeep, width: 1.5),
          ),
          filled: false,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 15, color: AppColors.blue),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
                height: 1.5,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.label,
    required this.saving,
    required this.onTap,
  });
  final String label;
  final bool saving;
  final VoidCallback? onTap;

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
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: onTap == null ? null : AppShadows.yellow,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onTap,
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
                        const Icon(Icons.send, size: 14, color: AppColors.ink),
                        const SizedBox(width: 7),
                        Text(label),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '—';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dayName3(int weekday) {
  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday.clamp(1, 7)];
}
