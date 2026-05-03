import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/parent/domain/entities/child_trip.dart';
import 'package:smart_bus/features/parent/domain/entities/parent_child.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final childrenAsync = ref.watch(parentChildrenProvider);
    final selectedIndex = ref.watch(selectedChildIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(name: user?.fullName ?? '', l: l),
            childrenAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${l.loginUnknownError} ($e)'),
              ),
              data: (children) {
                if (children.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l.parentNoChildren,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.slate500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final safeIndex = selectedIndex.clamp(0, children.length - 1);
                final selected = children[safeIndex];
                return Expanded(
                  child: Column(
                    children: [
                      _ChildTabs(
                        children: children,
                        activeIndex: safeIndex,
                        onTap: (i) => ref
                            .read(selectedChildIndexProvider.notifier)
                            .select(i),
                      ),
                      Expanded(
                        child: _ChildPanel(child: selected, l: l),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.name, required this.l});
  final String name;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.yellow, AppColors.yellowDeep],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
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
                  l.parentGreetingEyebrow,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? '—' : name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const _HeaderIcon(
            icon: Icons.notifications_none,
            badge: true,
          ),
          const SizedBox(width: 8),
          _HeaderIcon(
            icon: Icons.settings_outlined,
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.badge = false, this.onTap});
  final IconData icon;
  final bool badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slate50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.slate100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 17, color: AppColors.slate600)),
              if (badge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE11D48),
                      border: Border.all(color: Colors.white, width: 2),
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

// ─── Child tabs ────────────────────────────────────────────────────────

class _ChildTabs extends StatelessWidget {
  const _ChildTabs({
    required this.children,
    required this.activeIndex,
    required this.onTap,
  });
  final List<ParentChild> children;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              _ChildTab(
                child: children[i],
                active: i == activeIndex,
                onTap: () => onTap(i),
              ),
              if (i != children.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChildTab extends StatelessWidget {
  const _ChildTab({
    required this.child,
    required this.active,
    required this.onTap,
  });
  final ParentChild child;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(7, 7, 13, 7),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.ink : AppColors.slate200,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.yellow : AppColors.slate100,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(child.fullName),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.ink : AppColors.slate600,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _firstName(child.fullName),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.slate700,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Child panel ───────────────────────────────────────────────────────

class _ChildPanel extends ConsumerWidget {
  const _ChildPanel({required this.child, required this.l});
  final ParentChild child;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(childTripsProvider(child.id));

    return RefreshIndicator(
      color: AppColors.yellowDeep,
      onRefresh: () async => ref.invalidate(childTripsProvider(child.id)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          tripsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _ErrorBox(message: e.toString()),
            data: (trips) {
              final last = trips.isNotEmpty ? trips.first : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (last != null)
                    _TripHero(trip: last, l: l, studentId: child.id)
                  else
                    _NoTripsHero(l: l),
                  const SizedBox(height: 14),
                  _SectionHead(title: l.parentSectionQuickActions),
                  const SizedBox(height: 8),
                  _Actions(l: l, studentId: child.id),
                  const SizedBox(height: 14),
                  _SectionHead(
                    title: l.parentSectionRecentTrips,
                    trailing: l.parentViewAll,
                    onTrailingTap: () =>
                        context.push(AppRoute.studentTripsFor(child.id)),
                  ),
                  const SizedBox(height: 8),
                  if (trips.isEmpty)
                    _EmptyHistory(l: l)
                  else
                    _HistoryCard(trips: trips, l: l),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Trip hero ─────────────────────────────────────────────────────────

class _TripHero extends StatelessWidget {
  const _TripHero({
    required this.trip,
    required this.l,
    required this.studentId,
  });
  final ChildTrip trip;
  final AppLocalizations l;
  final String studentId;

  bool get _pending =>
      trip.tripPhase != TripPhase.completed &&
      trip.boardingStatus != BoardingStatus.absent;

  bool get _showTrackButton =>
      trip.tripPhase == TripPhase.inProgress ||
      trip.tripPhase == TripPhase.scheduled;

  @override
  Widget build(BuildContext context) {
    final statusColor = _pending ? const Color(0xFFFCD34D) : const Color(0xFF6EE7B7);
    final statusBg =
        _pending ? const Color(0x2EF59E0B) : const Color(0x2E10B981);
    final dotColor = _pending ? const Color(0xFFF59E0B) : const Color(0xFF34D399);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F2E), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.50),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 11, color: AppColors.yellow),
                    const SizedBox(width: 6),
                    Text(
                      '${l.parentTripEyebrow} · ${_relativeDay(trip.tripDate, l)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                        boxShadow: [
                          BoxShadow(color: dotColor, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusText(trip, l),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Route stops + bus icon
          Row(
            children: [
              _Stop(
                label: l.parentTripPickup,
                name: trip.pickupStopName,
                time: _hhmm(trip.boardingTime ?? trip.actualDeparture ?? trip.scheduledDeparture),
                rightAlign: false,
              ),
              const SizedBox(width: 10),
              _RouteLine(),
              const SizedBox(width: 10),
              _Stop(
                label: l.parentTripDropoff,
                name: trip.dropoffStopName,
                time: _hhmm(trip.dropoffTime ?? trip.actualArrival),
                rightAlign: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.directions_bus,
                    label: l.parentMetaBus,
                    value: '#${trip.busPlateNumber}',
                  ),
                ),
                _MetaDivider(),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.person_outline,
                    label: l.parentMetaDriver,
                    value: trip.driverName ?? '—',
                  ),
                ),
                _MetaDivider(),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.access_time,
                    label: l.parentMetaDuration,
                    value: trip.durationMinutes != null
                        ? '${trip.durationMinutes} min'
                        : '—',
                  ),
                ),
              ],
            ),
          ),
          if (_showTrackButton) ...[
            const SizedBox(height: 14),
            _TrackLiveBtn(
              label: l.parentTrackLive,
              onTap: () =>
                  context.push(AppRoute.studentLiveFor(studentId)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackLiveBtn extends StatelessWidget {
  const _TrackLiveBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.yellow, AppColors.yellowDeep],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE11D48),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFE11D48), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on, size: 15, color: AppColors.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoTripsHero extends StatelessWidget {
  const _NoTripsHero({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_bus,
              color: AppColors.yellow, size: 32),
          const SizedBox(height: 10),
          Text(
            l.parentNoTrips,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.label,
    required this.name,
    required this.time,
    required this.rightAlign,
  });
  final String label;
  final String name;
  final String time;
  final bool rightAlign;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            rightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: rightAlign ? TextAlign.end : TextAlign.start,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.yellow,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(),
          const _DashedLine(),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.yellow,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.directions_bus,
                size: 14, color: AppColors.ink),
          ),
          const _DashedLine(),
          _Dot(),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.yellow,
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: 0.18),
          width: 3,
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 2,
      child: CustomPaint(painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.yellow
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    const dash = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset((x + dash).clamp(0, size.width), size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

// ─── Section heading ───────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, this.trailing, this.onTrailingTap});
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailing!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right,
                      size: 14, color: AppColors.blue),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────

class _Actions extends StatelessWidget {
  const _Actions({required this.l, required this.studentId});
  final AppLocalizations l;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.person_outline,
            iconColor: AppColors.blue,
            iconBg: AppColors.blueSoft,
            title: l.parentActionStudentInfo,
            sub: l.parentActionStudentInfoSub,
            onTap: () => context.push(AppRoute.studentInfoFor(studentId)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.show_chart,
            iconColor: const Color(0xFFD97706),
            iconBg: const Color(0xFFFEF3C7),
            title: l.parentActionTripHistory,
            sub: l.parentActionTripHistorySub,
            onTap: () => context.push(AppRoute.studentTripsFor(studentId)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFFE11D48),
            iconBg: const Color(0xFFFFE4E6),
            title: l.parentActionAbsence,
            sub: l.parentActionAbsenceSub,
            onTap: () => context.push(AppRoute.studentAbsenceFor(studentId)),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.sub,
    this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String sub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slate200),
            boxShadow: AppShadows.sm,
          ),
          child: _tileBody(),
        ),
      ),
    );
  }

  Widget _tileBody() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }
}

// ─── History list ─────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.trips, required this.l});
  final List<ChildTrip> trips;
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
          for (var i = 0; i < trips.length; i++)
            _HistoryRow(
              trip: trips[i],
              isLast: i == trips.length - 1,
              l: l,
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.trip,
    required this.isLast,
    required this.l,
  });
  final ChildTrip trip;
  final bool isLast;
  final AppLocalizations l;

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
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  trip.tripDate.day.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _monthAbbrev(trip.tripDate.month).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${trip.pickupStopName} → ${trip.dropoffStopName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: AppColors.slate400),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _historyTimeText(trip, l),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ResultTag(trip: trip, l: l),
        ],
      ),
    );
  }
}

class _ResultTag extends StatelessWidget {
  const _ResultTag({required this.trip, required this.l});
  final ChildTrip trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg, text) = switch (trip.resultTag) {
      TripResultTag.onTime => (
          Icons.check,
          AppColors.emeraldSoft,
          AppColors.emerald,
          l.parentTagOnTime,
        ),
      TripResultTag.late => (
          Icons.access_time,
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          '+${trip.delayMinutes ?? 0} min',
        ),
      TripResultTag.absent => (
          Icons.close,
          const Color(0xFFFFE4E6),
          const Color(0xFFE11D48),
          l.parentTagAbsent,
        ),
      TripResultTag.pending => (
          Icons.schedule,
          AppColors.slate100,
          AppColors.slate500,
          l.parentTagPending,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      alignment: Alignment.center,
      child: Text(
        l.parentNoTrips,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.slate500,
          fontWeight: FontWeight.w500,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.slate500,
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '—';
  if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}

String _firstName(String full) {
  final parts = full.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  return parts.isNotEmpty ? parts.first : full;
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

String _relativeDay(DateTime when, AppLocalizations l) {
  final now = DateTime.now();
  final dt = when.toLocal();
  final dayDiff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(dt.year, dt.month, dt.day))
      .inDays;
  if (dayDiff == 0) return l.parentDayToday;
  if (dayDiff == 1) return l.parentDayYesterday;
  return '${dt.day} ${_monthAbbrev(dt.month)}';
}

String _statusText(ChildTrip trip, AppLocalizations l) {
  if (trip.boardingStatus == BoardingStatus.absent) return l.parentTagAbsent;
  if (trip.tripPhase == TripPhase.completed) return l.parentStatusArrived;
  if (trip.tripPhase == TripPhase.inProgress) return l.parentStatusOnBus;
  return l.parentStatusAwaiting;
}

String _historyTimeText(ChildTrip trip, AppLocalizations l) {
  if (trip.boardingStatus == BoardingStatus.absent) return l.parentTagAbsent;
  final start = trip.boardingTime ?? trip.actualDeparture ?? trip.scheduledDeparture;
  final end = trip.dropoffTime ?? trip.actualArrival;
  if (end == null) return _hhmm(start);
  return '${_hhmm(start)} — ${_hhmm(end)}';
}

String _monthAbbrev(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month.clamp(1, 12)];
}
