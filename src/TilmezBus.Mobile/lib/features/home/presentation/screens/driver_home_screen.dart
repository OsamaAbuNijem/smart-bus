import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/models/my_today_trip_dto.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:tilmez_bus/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Driver home — only shows in-progress trips. Tapping a trip opens the
/// driver map with the routed pickup / drop-off waypoints.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Periodic refresh so a trip the assistant just started shows up on
    // the driver's screen without a pull-to-refresh. 10 s mirrors the
    // parent home's cadence; assistant actions land on this screen
    // within one tick.
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      ref.invalidate(myTodayTripsProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final tripsAsync = ref.watch(myTodayTripsProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(name: user?.fullName ?? '', l: l),
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFF4F4F5),
                child: RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(myTodayTripsProvider),
                  color: AppColors.yellowDeep,
                  child: tripsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _ErrorTile(message: '$e'),
                    data: (trips) {
                      final live = trips
                          .where((t) => t.isLive && t.tripId != null)
                          .toList();
                      return ListView(
                        padding:
                            const EdgeInsets.fromLTRB(14, 14, 14, 24),
                        children: [
                          _SectionLabel(text: l.driverActiveTrips),
                          const SizedBox(height: 8),
                          if (live.isEmpty)
                            _NoActiveTrip(l: l)
                          else
                            for (final t in live) ...[
                              _ActiveTripCard(trip: t, l: l),
                              const SizedBox(height: 10),
                            ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.name, required this.l});
  final String name;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = _greetingFor(DateTime.now().hour, l);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          _GreetAvatar(name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name.isEmpty ? l.homeDriverTitle : name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _GlassIconBtn(
            icon: Icons.notifications_none_rounded,
            badge: ref.watch(notificationsUnreadCountProvider) > 0,
            onTap: () => context.push(AppRoute.notifications),
          ),
          const SizedBox(width: 8),
          _GlassIconBtn(
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppRoute.driverSettings),
          ),
        ],
      ),
    );
  }

  String _greetingFor(int hour, AppLocalizations l) {
    if (hour < 12) return l.assistantGreetMorning.toUpperCase();
    if (hour < 18) return l.assistantGreetAfternoon.toUpperCase();
    return l.assistantGreetEvening.toUpperCase();
  }
}

class _GreetAvatar extends StatelessWidget {
  const _GreetAvatar({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue, Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x662563EB),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '👤';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _GlassIconBtn extends StatelessWidget {
  const _GlassIconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.slate100),
              boxShadow: AppShadows.sm,
            ),
            child: Icon(icon, size: 19, color: AppColors.ink),
          ),
          if (badge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.slate400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.trip, required this.l});
  final MyTodayTripDto trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('h:mm a');
    final morning = trip.isMorning;
    return GestureDetector(
      onTap: () => context.push(
        AppRoute.driverTripMapFor(trip.tripId!),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.yellowTint, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.85],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellow),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            // Same trip-type chip the assistant uses on the home cards —
            // small soft-tinted block, amber for morning, violet for return.
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: morning
                    ? const Color(0xFFFEF3C7)
                    : AppColors.violetSoft,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: morning
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFDDD6FE),
                ),
              ),
              child: Icon(
                morning
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_outlined,
                size: 18,
                color: morning
                    ? const Color(0xFFD97706)
                    : AppColors.violet,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${morning ? l.assistantMorningPickup : l.assistantAfternoonDropoff} · ${trip.busPlateNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const _LivePill(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l.assistantStartedAt} ${fmt.format((trip.actualDeparture ?? trip.scheduledDeparture).toLocal())} · ${trip.boardedCount}/${trip.studentCount} ${l.assistantBoarded}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 14, color: AppColors.blue),
                      const SizedBox(width: 5),
                      Text(
                        l.driverOpenRouteMap,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.blue,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.yellow, AppColors.yellowDeep],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NoActiveTrip extends StatelessWidget {
  const _NoActiveTrip({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_bus_filled_outlined,
              color: AppColors.slate500,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.driverNoActiveTrip,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.driverNoActiveTripBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.redDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
