import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/parent/domain/entities/student_info.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class StudentInfoScreen extends ConsumerWidget {
  const StudentInfoScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final infoAsync = ref.watch(studentInfoProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBox(message: e.toString()),
        data: (info) => Column(
          children: [
            _Hero(
              info: info,
              l: l,
              onEdit: () =>
                  context.push(AppRoute.studentEditFor(studentId)),
            ),
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(0, -12, 0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: RefreshIndicator(
                  color: AppColors.yellowDeep,
                  onRefresh: () async =>
                      ref.invalidate(studentInfoProvider(studentId)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
                    children: [
                      _SectionHead(title: l.studentInfoGeneral),
                      const SizedBox(height: 8),
                      _GeneralInfoSection(info: info, l: l),
                      if (_hasNotes(info)) ...[
                        const SizedBox(height: 12),
                        _NotesCard(notes: info.notes!, l: l),
                      ],
                      const SizedBox(height: 12),
                      _SectionHead(title: l.studentInfoParentContact),
                      const SizedBox(height: 8),
                      if (info.parent == null)
                        _EmptyContacts(l: l)
                      else
                        _ContactsCard(
                          contacts: [info.parent!],
                          fallbackAddress: info.homeAddress,
                          l: l,
                        ),
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

  bool _hasNotes(StudentInfo info) =>
      info.notes != null && info.notes!.trim().isNotEmpty;
}

// ─── Hero (matches absence/edit/trip-history dark hero pattern) ────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.info,
    required this.l,
    required this.onEdit,
  });
  final StudentInfo info;
  final AppLocalizations l;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final classText = info.className == null || info.className!.isEmpty
        ? ''
        : ' · ${l.studentInfoClassPrefix} ${info.className}';
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
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l.studentInfoTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                _EditPill(onTap: onEdit),
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

class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.yellow.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: AppColors.yellow.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(10, 7, 12, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 12, color: Color(0xFFFCD34D)),
              SizedBox(width: 5),
              Text(
                'Edit',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFCD34D),
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

// ─── Section heading ────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.slate500,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─── General info ──────────────────────────────────────────────────

class _GeneralInfoSection extends StatelessWidget {
  const _GeneralInfoSection({required this.info, required this.l});
  final StudentInfo info;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRowData>[
      if (info.dateOfBirth != null)
        _InfoRowData(
          icon: Icons.calendar_today,
          color: AppColors.violet,
          bg: AppColors.violetSoft,
          border: const Color(0xFFDDD6FE),
          label: l.studentInfoDob,
          value: _formatDate(info.dateOfBirth!),
        ),
      if (info.schoolName != null && info.schoolName!.isNotEmpty)
        _InfoRowData(
          icon: Icons.school,
          color: AppColors.blue,
          bg: AppColors.blueSoft,
          border: const Color(0xFFBFDBFE),
          label: l.studentInfoSchool,
          value: info.schoolName!,
        ),
      _InfoRowData(
        icon: Icons.location_on_outlined,
        color: AppColors.emerald,
        bg: AppColors.emeraldSoft,
        border: const Color(0xFFA7F3D0),
        label: l.studentInfoHomeAddress,
        value: info.homeAddress.isEmpty ? '—' : info.homeAddress,
      ),
      if (info.routeName != null && info.routeName!.isNotEmpty)
        _InfoRowData(
          icon: Icons.alt_route,
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFEF3C7),
          border: const Color(0xFFFDE68A),
          label: l.studentInfoRoute,
          value: info.routeName!,
        ),
    ];

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
          for (var i = 0; i < rows.length; i++)
            _InfoRow(data: rows[i], isLast: i == rows.length - 1),
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData({
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data, required this.isLast});
  final _InfoRowData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.slate100),
              ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: data.border),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 16, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate400,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.1,
                    height: 1.3,
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

// ─── Notes ──────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes, required this.l});
  final String notes;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.yellowTint, Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.yellow),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -4,
            right: 4,
            child: Text(
              '"',
              style: TextStyle(
                fontSize: 56,
                color: AppColors.yellow.withValues(alpha: 0.4),
                fontFamily: 'serif',
                height: 1,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.description,
                        size: 14, color: AppColors.ink),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.studentInfoNotes,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notes,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate700,
                  height: 1.6,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Emergency contacts ─────────────────────────────────────────────

class _ContactsCard extends StatelessWidget {
  const _ContactsCard({
    required this.contacts,
    required this.fallbackAddress,
    required this.l,
  });
  final List<StudentContact> contacts;
  final String fallbackAddress;
  final AppLocalizations l;

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
          for (var i = 0; i < contacts.length; i++)
            _ContactRow(
              contact: contacts[i],
              isLast: i == contacts.length - 1,
              fallbackAddress: fallbackAddress,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.isLast,
    required this.fallbackAddress,
  });
  final StudentContact contact;
  final bool isLast;
  final String fallbackAddress;

  bool get _isMother =>
      contact.relation?.toLowerCase().contains('mother') == true ||
      contact.relation?.contains('أم') == true;
  bool get _isFather =>
      contact.relation?.toLowerCase().contains('father') == true ||
      contact.relation?.contains('أب') == true;

  @override
  Widget build(BuildContext context) {
    final address = (contact.address?.isNotEmpty ?? false)
        ? contact.address!
        : fallbackAddress;

    final (avatarBg, avatarFg) = _isMother
        ? (
            const LinearGradient(
              colors: [Color(0xFFFECDD3), Color(0xFFFDA4AF)],
            ),
            const Color(0xFF9F1239),
          )
        : _isFather
            ? (
                const LinearGradient(
                  colors: [Color(0xFFDBEAFE), Color(0xFF93C5FD)],
                ),
                const Color(0xFF1E40AF),
              )
            : (
                const LinearGradient(
                  colors: [AppColors.slate100, AppColors.slate200],
                ),
                AppColors.slate700,
              );

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.slate100),
              ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: avatarBg,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.slate200,
                  blurRadius: 0,
                  spreadRadius: 1.5,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(contact.name),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: avatarFg,
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
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (contact.relation != null && contact.relation!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          contact.relation!,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    Text(
                      contact.phoneNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.slate400),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate500,
                            height: 1.4,
                            letterSpacing: -0.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      alignment: Alignment.center,
      child: Text(
        l.studentInfoNoContacts,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.slate500,
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.slate500),
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
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}

String _formatDate(DateTime dt) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[dt.month.clamp(1, 12)]} ${dt.day}, ${dt.year}';
}
