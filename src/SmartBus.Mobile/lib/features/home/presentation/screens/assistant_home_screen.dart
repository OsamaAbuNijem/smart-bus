import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/assistant/data/models/my_today_trip_dto.dart';
import 'package:smart_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class AssistantHomeScreen extends ConsumerWidget {
  const AssistantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final tripsAsync = ref.watch(myTodayTripsProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(name: user?.fullName ?? '', l: l),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(myTodayTripsProvider),
                color: AppColors.yellowDeep,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    _StartCard(
                      onScan: () => context.push(AppRoute.assistantQrScan),
                      onManual: () =>
                          context.push(AppRoute.assistantManualSetup),
                      l: l,
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(title: l.assistantTodaysTrips),
                    const SizedBox(height: 8),
                    tripsAsync.when(
                      loading: () => const _SkeletonTrips(),
                      error: (e, _) => _ErrorTile(message: '$e'),
                      data: (trips) {
                        if (trips.isEmpty) {
                          return _EmptyTrips(l: l);
                        }
                        return Column(
                          children: [
                            for (final t in trips) ...[
                              _TripCard(trip: t, l: l),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero (white) ───────────────────────────────────────────────────────

class _Hero extends ConsumerWidget {
  const _Hero({required this.name, required this.l});
  final String name;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dayShort = DateFormat('E').format(now);
    final dateStr = DateFormat('MMM dd').format(now);
    final timeStr = DateFormat('h:mm a').format(now);
    final greeting = _greetingFor(now.hour, l);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _GreetAvatar(name: name),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👋', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      name.isEmpty ? l.homeAssistantTitle : name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _IconBtn(
                icon: Icons.notifications_none_rounded,
                badge: true,
                onTap: () => context.push(AppRoute.notifications),
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.settings_outlined,
                onTap: () => context.push(AppRoute.assistantSettings),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DtPill(
                icon: Icons.calendar_today_outlined,
                label: '$dayShort  $dateStr',
                emphasis: dayShort,
              ),
              const SizedBox(width: 6),
              _DtPill(
                icon: Icons.access_time_rounded,
                label: timeStr,
              ),
            ],
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
          colors: [AppColors.yellow, AppColors.yellowDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66F5C518),
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
          color: AppColors.ink,
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              border: Border.all(color: AppColors.slate100),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.slate700),
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

class _DtPill extends StatelessWidget {
  const _DtPill({required this.icon, required this.label, this.emphasis});
  final IconData icon;
  final String label;
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        border: Border.all(color: AppColors.slate100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.slate500),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
              letterSpacing: 0.1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Start card (Scan Bus QR + manual link) ─────────────────────────────

class _StartCard extends StatelessWidget {
  const _StartCard({
    required this.onScan,
    required this.onManual,
    required this.l,
  });
  final VoidCallback onScan;
  final VoidCallback onManual;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onScan,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.yellow, AppColors.yellowDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.ink,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.assistantScanBusQr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.assistantScanBusQrSub,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onManual,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.assistantManualSetupCta,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.slate600,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ─── Trip card ──────────────────────────────────────────────────────────

class _TripCard extends ConsumerWidget {
  const _TripCard({required this.trip, required this.l});
  final MyTodayTripDto trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = trip.isLive;
    final morning = trip.isMorning;

    return GestureDetector(
      onTap: () {
        // Live + completed trips both have a tripId and open the live/recap
        // details view. Scheduled placeholders fall back to manual setup.
        if (trip.tripId != null) {
          context.push(AppRoute.assistantTripDetailsFor(trip.tripId!));
        } else if (trip.isScheduled) {
          context.push(AppRoute.assistantManualSetup, extra: trip);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: live
              ? const LinearGradient(
                  colors: [AppColors.yellowTint, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 0.8],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: live ? AppColors.yellow : AppColors.slate200,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
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
                  Text(
                    '${morning ? l.assistantMorningPickup : l.assistantAfternoonDropoff} · ${trip.busPlateNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _meta(trip, l),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(trip: trip, l: l),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }

  String _meta(MyTodayTripDto t, AppLocalizations l) {
    final fmt = DateFormat('h:mm a');
    if (t.isLive && t.actualDeparture != null) {
      return '${l.assistantStartedAt} ${fmt.format(t.actualDeparture!.toLocal())} · ${t.boardedCount}/${t.studentCount} ${l.assistantBoarded}';
    }
    if (t.isCompleted &&
        t.actualDeparture != null &&
        t.actualArrival != null) {
      final dayLabel = _dayLabel(t.actualDeparture!.toLocal());
      return '$dayLabel · ${fmt.format(t.actualDeparture!.toLocal())} — ${fmt.format(t.actualArrival!.toLocal())} · ${t.studentCount} ${l.assistantStudents}';
    }
    return '${fmt.format(t.scheduledDeparture.toLocal())} · ${t.studentCount} ${l.assistantStudents}';
  }

  String _dayLabel(DateTime when) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final w = DateTime(when.year, when.month, when.day);
    final diff = t.difference(w).inDays;
    if (diff == 0) return DateFormat('EEE').format(when);
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(when);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.trip, required this.l});
  final MyTodayTripDto trip;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (trip.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.yellow, AppColors.yellowDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8CF5C518),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PulseDot(),
            const SizedBox(width: 5),
            Text(
              l.assistantStatusLive,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.05,
              ),
            ),
          ],
        ),
      );
    }
    if (trip.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.emeraldSoft,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 10, color: AppColors.emerald),
            const SizedBox(width: 4),
            Text(
              l.assistantStatusDone,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.emerald,
                letterSpacing: -0.05,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Text(
        l.assistantStatusScheduled,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppColors.slate600,
          letterSpacing: -0.05,
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(_ctrl),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Empty / loading / error states ─────────────────────────────────────

class _SkeletonTrips extends StatelessWidget {
  const _SkeletonTrips();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++) ...[
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.slate200),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.redDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l.assistantNoTripsToday,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.slate500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
