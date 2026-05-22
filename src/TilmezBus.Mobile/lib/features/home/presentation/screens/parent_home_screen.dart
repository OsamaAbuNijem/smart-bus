import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';

import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:tilmez_bus/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:tilmez_bus/features/parent/domain/entities/child_trip.dart';
import 'package:tilmez_bus/features/parent/domain/entities/live_tracking.dart';
import 'package:tilmez_bus/features/parent/domain/entities/parent_child.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/live_tracking_controller.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

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
                      // Hide the child-picker strip when the parent only has
                      // one student — there's nothing to switch between.
                      if (children.length > 1)
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
                  _greetingForNow(l),
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
          _HeaderIcon(
            icon: Icons.notifications_none,
            badge: ref.watch(notificationsUnreadCountProvider) > 0,
            onTap: () => context.push(AppRoute.notifications),
          ),
          const SizedBox(width: 8),
          _HeaderIcon(
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppRoute.parentSettings),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.yellow : AppColors.slate200,
            width: active ? 1.8 : 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.28),
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
                color: active ? AppColors.ink : AppColors.slate700,
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

class _ChildPanel extends ConsumerStatefulWidget {
  const _ChildPanel({required this.child, required this.l});
  final ParentChild child;
  final AppLocalizations l;

  @override
  ConsumerState<_ChildPanel> createState() => _ChildPanelState();
}

class _ChildPanelState extends ConsumerState<_ChildPanel> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Periodically invalidate the trips provider so the home picks up
    // new trips the moment the assistant materialises one — without the
    // parent having to pull-to-refresh. 10 s is a balance between
    // surfacing a freshly-started trip quickly and not hammering the
    // API for users whose trip is hours away.
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      ref.invalidate(childTripsProvider(widget.child.id));
    });
  }

  @override
  void didUpdateWidget(covariant _ChildPanel old) {
    super.didUpdateWidget(old);
    // When the parent switches between children we want the next panel
    // to start its own poll for that child immediately, not wait for
    // the previous timer's tick.
    if (old.child.id != widget.child.id) {
      ref.invalidate(childTripsProvider(widget.child.id));
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final child = widget.child;
    final tripsAsync = ref.watch(childTripsProvider(child.id));

    return RefreshIndicator(
      color: AppColors.yellowDeep,
      onRefresh: () async => ref.invalidate(childTripsProvider(child.id)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
              // Live card only when there's a trip currently rolling. Empty-
              // state placeholder is reserved for parents with no trips at all.
              final candidate = trips
                  .where((t) => t.tripPhase == TripPhase.inProgress)
                  .firstOrNull;
              // Peek at the live boarding status only when there's an
              // in-progress candidate to evaluate against — avoids spinning
              // up the live tracker when no trip is rolling. On Morning
              // trips we drop the hero while the bus is heading to the
              // pickup but the student hasn't boarded yet: from the
              // parent's perspective their child's journey has not
              // started, so the home stays uncluttered until the
              // assistant marks them boarded. Return trips never trigger
              // this because students are auto-boarded the moment the
              // assistant flips the trip to InProgress.
              final live = candidate != null
                  ? ref
                      .watch(liveTrackingControllerProvider(child.id))
                      .valueOrNull
                  : null;
              final liveBoarding =
                  live?.boardingStatus?.toLowerCase();
              final hideMorningPrePickup =
                  candidate?.tripType == 'Morning' &&
                      (liveBoarding == null || liveBoarding == 'waiting');
              final liveTrip = hideMorningPrePickup ? null : candidate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (liveTrip != null) ...[
                    _TripHero(trip: liveTrip, l: l, studentId: child.id),
                    const SizedBox(height: 14),
                  ] else if (trips.isEmpty) ...[
                    _NoTripsHero(l: l),
                    const SizedBox(height: 14),
                  ],
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
                    _HistoryCard(trips: trips.take(4).toList(), l: l),
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

class _TripHero extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Status palette on the white surface: amber for in-flight, emerald
    // for done — saturated tokens since the background is no longer dark.
    final statusBgLight =
        _pending ? const Color(0xFFFEF3C7) : AppColors.emeraldSoft;
    final statusBorderLight = _pending
        ? const Color(0xFFFDE68A)
        : const Color(0xFFA7F3D0);
    final statusFgLight =
        _pending ? const Color(0xFFB45309) : AppColors.emerald;
    final statusDotLight =
        _pending ? const Color(0xFFD97706) : AppColors.emerald;

    final isInProgress = trip.tripPhase == TripPhase.inProgress;
    final isCompleted = trip.tripPhase == TripPhase.completed;
    // Pull live position only when there's something to track. For completed /
    // scheduled trips we still want the progress line filled / empty without
    // hitting the controller.
    final live = isInProgress
        ? ref.watch(liveTrackingControllerProvider(studentId)).valueOrNull
        : null;
    // While the bus is on its way to the pickup (Morning: home; Return:
    // school) but hasn't picked the student up yet, the progress bar
    // represents "the journey of *my child*" — and that journey hasn't
    // begun. Freeze the rail at 0 % and hide the ETA so the card shows
    // only the status text ("Bus on the way"). The rail + ETA come back
    // the moment the assistant marks the student boarded.
    final boardingStatusRaw = live?.boardingStatus?.toLowerCase();
    final isPreBoarding =
        isInProgress && boardingStatusRaw == 'waiting';
    final progress = isPreBoarding
        ? const _RouteProgressData(fraction: 0.0, remainingMinutes: null)
        : _computeRouteProgress(trip, live, isCompleted);

    // Watch the live-tracking poll for a status transition into Completed
    // while the parent is sitting on the home page. We surface a SnackBar
    // and invalidate the trips list so the in-progress hero collapses
    // into the "no trip" placeholder + the row in History reflects the
    // new state. Guarded against re-firing by checking the previous
    // value's tripStatus.
    if (isInProgress) {
      ref.listen(
        liveTrackingControllerProvider(studentId),
        (prev, next) {
          final prevStatus =
              prev?.valueOrNull?.tripStatus?.toLowerCase();
          final nextStatus = next.valueOrNull?.tripStatus?.toLowerCase();
          if (prevStatus != 'completed' && nextStatus == 'completed') {
            ref.invalidate(childTripsProvider(studentId));
            final messenger = ScaffoldMessenger.maybeOf(context);
            messenger?.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(l.liveTrackingTripEndedBody),
            ));
          }
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.md,
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
                    Icon(
                      trip.tripType == 'Morning'
                          ? Icons.wb_sunny_outlined
                          : Icons.nightlight_outlined,
                      size: 12,
                      color: trip.tripType == 'Morning'
                          ? const Color(0xFFD97706)
                          : AppColors.violet,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (trip.tripType == 'Morning'
                              ? l.assistantMorningPickup
                              : l.assistantAfternoonDropoff)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBgLight,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusBorderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusDotLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusText(trip, l, live: live),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusFgLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Route stops + animated progress line
          Row(
            children: [
              // Whichever side of the route is the school we render as a
              // generic "School" instead of the verbose admin name (e.g.
              // "TilmezBus Demo School") so it never gets truncated.
              _Stop(
                label: l.parentTripPickup,
                name: trip.tripType == 'Return'
                    ? l.driverSchoolPin
                    : l.liveTrackingHome,
                rightAlign: false,
              ),
              const SizedBox(width: 10),
              _RouteProgress(
                fraction: progress.fraction,
                remainingMinutes: progress.remainingMinutes,
                liveLabel: l.liveTrackingArrives,
              ),
              const SizedBox(width: 10),
              _Stop(
                label: l.parentTripDropoff,
                name: trip.tripType == 'Morning'
                    ? l.driverSchoolPin
                    : l.liveTrackingHome,
                rightAlign: true,
              ),
            ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.yellowTint,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x66F5C518)),
            ),
            child: const Icon(Icons.directions_bus,
                color: AppColors.yellowDeep, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            l.parentNoTrips,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
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
    required this.rightAlign,
  });
  final String label;
  final String name;
  final bool rightAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment:
            rightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.slate500,
              letterSpacing: 1.0,
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
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bus-on-rail progress indicator. The rail spans the available width with
/// dots at each end; the bus slides along it based on [fraction] (0..1).
/// When [remainingMinutes] is set, a centered "live" caption with a small
/// arrival range (e.g. "7-10 min") sits below the rail.
class _RouteProgress extends StatelessWidget {
  const _RouteProgress({
    required this.fraction,
    required this.remainingMinutes,
    required this.liveLabel,
  });
  final double fraction;
  final int? remainingMinutes;
  final String liveLabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                const railHeight = 4.0;
                const busSize = 28.0;
                const railCenterY = 20.0;
                const totalHeight = 40.0;
                final f = fraction.clamp(0.0, 1.0);
                final width = c.maxWidth;
                // Center the bus on the rail; subtract endpoint dot diameters
                // so it visually halts at the dots, not past them.
                const endInset = 8.0;
                final travel = (width - busSize).clamp(0.0, width);
                final busStart = endInset + (travel - endInset * 2) * f;
                // Use the *Directional widgets so the bus moves home→school
                // visually right-to-left in Arabic locales (matches reading
                // direction). All offsets are in start/end terms, not left/right.
                return SizedBox(
                  height: totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PositionedDirectional(
                        start: 0,
                        end: 0,
                        top: railCenterY - railHeight / 2,
                        child: Container(
                          height: railHeight,
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(railHeight),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 0,
                        top: railCenterY - railHeight / 2,
                        child: Container(
                          width: (busStart + busSize / 2).clamp(0.0, width),
                          height: railHeight,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(railHeight),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 0,
                        top: railCenterY - 4,
                        child: _EndDot(),
                      ),
                      PositionedDirectional(
                        end: 0,
                        top: railCenterY - 4,
                        child: _EndDot(),
                      ),
                      AnimatedPositionedDirectional(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        start: busStart,
                        top: railCenterY - busSize / 2,
                        child: Container(
                          width: busSize,
                          height: busSize,
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
                      ),
                    ],
                  ),
                );
              },
            ),
            if (remainingMinutes != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatRemainingRange(context, remainingMinutes!),
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Spreads a single ETA estimate into a short range that reflects normal
/// urban variability — roughly ±15-20%, snapped to whole minutes, with a
/// minimum spread of 2 min so it always reads as a range. Uses the Arabic
/// minute abbreviation (د) when the locale is Arabic.
String _formatRemainingRange(BuildContext context, int mins) {
  final low = math.max(1, (mins * 0.85).round());
  var high = (mins * 1.20).round() + 1;
  if (high - low < 2) high = low + 2;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return isArabic ? '$low-$high د' : '$low-$high min';
}

class _EndDot extends StatelessWidget {
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
                  trip.tripType == 'Morning'
                      ? l.tripHistoryMorningPickup
                      : l.tripHistoryAfternoonDropoff,
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
                      // Trip times stay in LTR — '9:13 AM' shouldn't flip
                      // to 'AM 9:13' when the locale is Arabic.
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _historyTimeText(trip, l),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: Directionality.of(context) ==
                                  TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
          _StatusTag(trip: trip, l: l),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.trip, required this.l});
  final ChildTrip trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Tag reflects the student's actual journey state, not just the
    // trip phase. For an in-progress trip the boardingStatus drives
    // the text: Waiting → "Bus on the way" (bus hasn't picked them up
    // yet), DroppedOff → "Arrived safely" (they reached destination
    // even if the bus is still rolling for others), Boarded → "On the
    // bus". Absent and completed/scheduled fall back to the trip-level
    // tag as before.
    final (IconData icon, Color bg, Color fg, String text) =
        trip.boardingStatus == BoardingStatus.absent
            ? (
                Icons.close,
                const Color(0xFFFFE4E6),
                const Color(0xFFE11D48),
                l.parentTagAbsent,
              )
            : trip.tripPhase == TripPhase.inProgress &&
                    trip.boardingStatus == BoardingStatus.droppedOff
                ? (
                    Icons.check,
                    AppColors.emeraldSoft,
                    AppColors.emerald,
                    l.parentStatusArrived,
                  )
                : trip.tripPhase == TripPhase.inProgress &&
                        trip.boardingStatus == BoardingStatus.waiting
                    ? (
                        Icons.directions_bus_outlined,
                        const Color(0xFFFEF3C7),
                        const Color(0xFFD97706),
                        l.parentStatusWaitingPickup,
                      )
                    : switch (trip.tripPhase) {
                        TripPhase.completed => (
                            Icons.check,
                            AppColors.emeraldSoft,
                            AppColors.emerald,
                            l.parentStatusArrived,
                          ),
                        TripPhase.inProgress => (
                            Icons.directions_bus,
                            const Color(0xFFFEF3C7),
                            const Color(0xFFD97706),
                            l.parentStatusOnBus,
                          ),
                        TripPhase.scheduled => (
                            Icons.schedule,
                            AppColors.slate100,
                            AppColors.slate500,
                            l.parentStatusAwaiting,
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

String _greetingForNow(AppLocalizations l) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l.assistantGreetMorning;
  if (hour < 18) return l.assistantGreetAfternoon;
  return l.assistantGreetEvening;
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

String _statusText(ChildTrip trip, AppLocalizations l, {LiveTracking? live}) {
  if (trip.boardingStatus == BoardingStatus.absent) return l.parentTagAbsent;
  if (trip.tripPhase == TripPhase.completed) return l.parentStatusArrived;
  if (trip.tripPhase == TripPhase.inProgress) {
    // While the trip is rolling, prefer the live boardingStatus over the
    // snapshot in [trip] so the chip reflects the *current* state of
    // the student on the bus — "Bus on the way" before pickup, "On the
    // bus" after the assistant marks them boarded, "Arrived safely"
    // after dropoff. Falls back to "On the bus" if the live tracker
    // hasn't reported a status yet.
    final liveStatus = live?.boardingStatus?.toLowerCase();
    if (liveStatus == 'waiting') return l.parentStatusWaitingPickup;
    if (liveStatus == 'droppedoff' || liveStatus == 'dropped_off') {
      return l.parentStatusArrived;
    }
    return l.parentStatusOnBus;
  }
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

class _RouteProgressData {
  const _RouteProgressData({required this.fraction, required this.remainingMinutes});
  final double fraction;
  final int? remainingMinutes;
}

/// Resolves how far along the route the bus is plus how many minutes are left
/// to the dropoff. Prefers the live GPS distance/speed; falls back to schedule
/// timing when coords or pings are missing so the parent always sees a live
/// readout while the trip is in progress.
_RouteProgressData _computeRouteProgress(
  ChildTrip trip,
  LiveTracking? live,
  bool isCompleted,
) {
  if (isCompleted) return const _RouteProgressData(fraction: 1.0, remainingMinutes: null);
  if (live == null) return const _RouteProgressData(fraction: 0.0, remainingMinutes: null);
  final bus = live.busLocation;
  // Pickup / dropoff coordinate pair flips with trip type.
  final morning = trip.tripType == 'Morning';
  final pickupLat = morning ? live.homeLatitude : live.schoolLatitude;
  final pickupLng = morning ? live.homeLongitude : live.schoolLongitude;
  final dropLat = morning ? live.schoolLatitude : live.homeLatitude;
  final dropLng = morning ? live.schoolLongitude : live.homeLongitude;
  if (bus == null ||
      pickupLat == null || pickupLng == null ||
      dropLat == null || dropLng == null) {
    // No live GPS / coords — show an empty rail and no ETA rather than a
    // schedule-based guess that would diverge from the live map's value.
    return const _RouteProgressData(fraction: 0.0, remainingMinutes: null);
  }
  // Use the same haversine + speed-fallback formula as the live map's
  // `_etaMinutes` so the ETA shown next to this progress bar matches the
  // ETA pill on the live tracking screen down to the minute.
  final total = _haversineMeters(pickupLat, pickupLng, dropLat, dropLng);
  final remaining = _haversineMeters(bus.latitude, bus.longitude, dropLat, dropLng);
  final fraction = total <= 1 ? 0.0 : (1 - remaining / total).clamp(0.0, 1.0);
  final mps = (bus.speed != null && bus.speed! > 1.0) ? bus.speed! : 30 * 1000 / 3600;
  final mins = (remaining / mps / 60).round().clamp(1, 999);
  return _RouteProgressData(fraction: fraction.toDouble(), remainingMinutes: mins);
}

double _haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180.0;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) *
          math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
