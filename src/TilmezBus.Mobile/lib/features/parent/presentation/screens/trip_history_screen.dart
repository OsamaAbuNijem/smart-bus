import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/parent/domain/entities/child_trip.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final infoAsync = ref.watch(studentInfoProvider(studentId));
    final tripsAsync = ref.watch(tripHistoryProvider(studentId));

    final childName = infoAsync.valueOrNull?.fullName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _Hero(childName: childName, l: l),
          Expanded(
            child: tripsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: _ErrorBox(message: e.toString())),
              data: (trips) {
                // Show only the trailing 7-day window so the page matches its
                // "This Week" header and the last-7 hero subtitle.
                final cutoff = DateTime.now()
                    .subtract(const Duration(days: 7));
                final recent = trips
                    .where((t) => t.tripDate.toLocal().isAfter(cutoff))
                    .toList();
                if (recent.isEmpty) {
                  return _Empty(l: l);
                }
                return RefreshIndicator(
                  color: AppColors.yellowDeep,
                  onRefresh: () async =>
                      ref.invalidate(tripHistoryProvider(studentId)),
                  child: _GroupedList(trips: recent, l: l),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.childName, required this.l});
  final String childName;
  final AppLocalizations l;

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
              onTap: () => context.pop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.tripHistoryTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                  if (childName.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightIconBtn extends StatelessWidget {
  const _LightIconBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

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
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Grouped list ──────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.trips, required this.l});
  final List<ChildTrip> trips;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDay(trips);
    final today = _dayKey(DateTime.now());
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final entry = groups[index];
        final isToday = entry.dayKey == today;
        final isYesterday = entry.dayKey == yesterday;
        final dayName = isToday
            ? l.tripHistoryToday
            : isYesterday
                ? l.tripHistoryYesterday
                : _dayName(entry.day.weekday);
        final dayDate =
            '${_dayName3(entry.day.weekday)}, ${_monShort(entry.day.month)} ${entry.day.day}';

        return Padding(
          padding: EdgeInsets.only(bottom: index == groups.length - 1 ? 0 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DayHeader(
                dayNumber: entry.day.day,
                dayName: dayName,
                dayDate: '· $dayDate',
                isToday: isToday,
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < entry.trips.length; i++) ...[
                if (i != 0) const SizedBox(height: 8),
                _TripCard(trip: entry.trips[i], l: l),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.dayNumber,
    required this.dayName,
    required this.dayDate,
    required this.isToday,
  });
  final int dayNumber;
  final String dayName;
  final String dayDate;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: isToday ? AppColors.yellowTint : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isToday
                    ? const Color(0x66F5C518)
                    : AppColors.slate200,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isToday ? AppColors.yellowDeep : AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: dayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: ' $dayDate',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trip card ─────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.l});
  final ChildTrip trip;
  final AppLocalizations l;

  bool get _isMorning => trip.tripType.toLowerCase() == 'morning';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _TripTypeIcon(isMorning: _isMorning),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isMorning
                          ? l.tripHistoryMorningPickup
                          : l.tripHistoryAfternoonDropoff,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 10,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          // Trip times stay in LTR — '9:13 AM' shouldn't
                          // flip to 'AM 9:13' when the locale is Arabic.
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              _timeText(trip, l),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(trip: trip, l: l),
            ],
          ),
          const SizedBox(height: 10),
          _Crew(driver: trip.driverName, assistant: trip.assistantName, l: l),
        ],
      ),
    );
  }
}

class _TripTypeIcon extends StatelessWidget {
  const _TripTypeIcon({required this.isMorning});
  final bool isMorning;

  @override
  Widget build(BuildContext context) {
    final bg = isMorning
        ? const Color(0xFFFEF3C7)
        : AppColors.violetSoft;
    final border = isMorning
        ? const Color(0xFFFDE68A)
        : const Color(0xFFDDD6FE);
    final color = isMorning
        ? const Color(0xFFD97706)
        : AppColors.violet;
    final icon = isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.trip, required this.l});
  final ChildTrip trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Reflect the trip's current phase (or absence) so this matches the
    // recent-trips rows on the parent home page.
    final (Color bg, Color fg, Color border, String text) =
        trip.boardingStatus == BoardingStatus.absent
            ? (
                const Color(0xFFFFE4E6),
                const Color(0xFFE11D48),
                const Color(0xFFFECDD3),
                l.parentTagAbsent,
              )
            : switch (trip.tripPhase) {
                TripPhase.completed => (
                    AppColors.emeraldSoft,
                    AppColors.emerald,
                    const Color(0xFFA7F3D0),
                    l.parentStatusArrived,
                  ),
                TripPhase.inProgress => (
                    const Color(0xFFFEF3C7),
                    const Color(0xFFD97706),
                    const Color(0xFFFDE68A),
                    l.parentStatusOnBus,
                  ),
                TripPhase.scheduled => (
                    AppColors.slate100,
                    AppColors.slate500,
                    AppColors.slate200,
                    l.parentStatusAwaiting,
                  ),
              };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _Crew extends StatelessWidget {
  const _Crew({
    required this.driver,
    required this.assistant,
    required this.l,
  });
  final String? driver;
  final String? assistant;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.slate200, style: BorderStyle.solid),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CrewPerson(
              role: l.tripHistoryDriver,
              name: driver ?? '—',
              isDriver: true,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.slate200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _CrewPerson(
              role: l.tripHistoryAssistant,
              name: assistant ?? '—',
              isDriver: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrewPerson extends StatelessWidget {
  const _CrewPerson({
    required this.role,
    required this.name,
    required this.isDriver,
  });
  final String role;
  final String name;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = isDriver
        ? (AppColors.blueSoft, AppColors.blue)
        : (const Color(0xFFFEF3C7), const Color(0xFFD97706));

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(name),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: 0.7,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Empty / error ────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history,
                size: 36, color: AppColors.slate400),
            const SizedBox(height: 10),
            Text(
              l.tripHistoryEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
                height: 1.5,
              ),
            ),
          ],
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
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.slate500),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────

class _DayGroup {
  const _DayGroup(this.dayKey, this.day, this.trips);
  final String dayKey; // YYYY-MM-DD
  final DateTime day;
  final List<ChildTrip> trips;
}

List<_DayGroup> _groupByDay(List<ChildTrip> trips) {
  final map = <String, List<ChildTrip>>{};
  final dayDate = <String, DateTime>{};
  for (final t in trips) {
    final local = t.tripDate.toLocal();
    final key = _dayKey(local);
    map.putIfAbsent(key, () => []).add(t);
    dayDate[key] = DateTime(local.year, local.month, local.day);
  }
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return keys.map((k) => _DayGroup(k, dayDate[k]!, map[k]!)).toList();
}

String _dayKey(DateTime d) {
  final local = d.toLocal();
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$day';
}

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

String _hhmm(DateTime? dt) {
  if (dt == null) return '—';
  final local = dt.toLocal();
  final h = local.hour;
  final m = local.minute.toString().padLeft(2, '0');
  final hh12 = h % 12 == 0 ? 12 : h % 12;
  final ampm = h >= 12 ? 'PM' : 'AM';
  return '$hh12:$m $ampm';
}

String _timeText(ChildTrip trip, AppLocalizations l) {
  if (trip.boardingStatus == BoardingStatus.absent) {
    return l.tripHistoryReportedAbsent;
  }
  final start = trip.boardingTime ?? trip.actualDeparture ?? trip.scheduledDeparture;
  final end = trip.dropoffTime ?? trip.actualArrival;
  if (end == null) return _hhmm(start);
  return '${_hhmm(start)} — ${_hhmm(end)}';
}

String _monShort(int month) {
  const months = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month.clamp(1, 12)];
}

String _dayName(int weekday) {
  const days = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  return days[weekday.clamp(1, 7)];
}

String _dayName3(int weekday) {
  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday.clamp(1, 7)];
}
