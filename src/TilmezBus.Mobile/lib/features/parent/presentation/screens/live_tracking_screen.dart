import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/parent/domain/entities/live_tracking.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/live_tracking_controller.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/route_provider.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveTrackingScreen extends ConsumerWidget {
  const LiveTrackingScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tracking = ref.watch(liveTrackingControllerProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: tracking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorScreen(message: e.toString(), l: l),
        data: (data) => _LiveBody(data: data, studentId: studentId, l: l),
      ),
    );
  }
}

class _LiveBody extends ConsumerStatefulWidget {
  const _LiveBody({
    required this.data,
    required this.studentId,
    required this.l,
  });
  final LiveTracking data;
  final String studentId;
  final AppLocalizations l;

  @override
  ConsumerState<_LiveBody> createState() => _LiveBodyState();
}

class _LiveBodyState extends ConsumerState<_LiveBody> {
  final _mapController = MapController();
  Timer? _ageTicker;
  /// Timestamp of the last bus fix we already recentered on. Tracked so the
  /// 3 s parent poll only nudges the camera when the bus actually moved —
  /// repeating the same fix shouldn't fight the user's pinch / pan.
  DateTime? _lastRecenterTs;
  /// Set once we've shown the "Trip ended" dialog so a stale poll doesn't
  /// re-open it after the parent dismisses.
  bool _tripEndedShown = false;
  /// Bus position used as the first waypoint when fetching the OSRM
  /// polyline. Held stable while the bus is on the cached route so the
  /// line doesn't re-route on every 11 m of motion. Updated to the live
  /// bus only when [_isOffRoute] flags a real deviation.
  LatLng? _routeAnchorBus;

  /// Threshold (metres) used to decide whether the bus has left the
  /// currently rendered polyline. Set wide enough to absorb GPS jitter
  /// and lane-level wander.
  static const double _offRouteMeters = 80.0;

  @override
  void initState() {
    super.initState();
    // Refresh "Last updated X ago" once a second.
    _ageTicker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _ageTicker?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Pops a one-shot dialog when the trip transitions to Completed while
  /// the parent has the live map open. Tapping Close drops the parent
  /// back on their home screen and invalidates [childTripsProvider] so
  /// the trip row updates from "in progress" to "completed" without a
  /// manual pull-to-refresh.
  Future<void> _showTripEndedDialog() async {
    if (_tripEndedShown || !mounted) return;
    _tripEndedShown = true;
    final l = widget.l;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.flag_circle, color: AppColors.emerald),
            const SizedBox(width: 8),
            Expanded(child: Text(l.liveTrackingTripEndedTitle)),
          ],
        ),
        content: Text(l.liveTrackingTripEndedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.liveTrackingTripEndedClose),
          ),
        ],
      ),
    );
    if (!mounted) return;
    ref.invalidate(childTripsProvider(widget.studentId));
    context.go(AppRoute.homeParent);
  }

  LatLng? get _homeLatLng {
    final d = widget.data;
    if (d.homeLatitude == null || d.homeLongitude == null) return null;
    return LatLng(d.homeLatitude!, d.homeLongitude!);
  }

  LatLng? get _schoolLatLng {
    final d = widget.data;
    if (d.schoolLatitude == null || d.schoolLongitude == null) return null;
    return LatLng(d.schoolLatitude!, d.schoolLongitude!);
  }

  LatLng? get _destinationLatLng => _destination(widget.data);
  LatLng? get _displayBusLatLng => _displayBus(widget.data);

  /// Tight follow-cam: keep the bus dead-center at a high zoom so the
  /// parent always sees the bus and the streets right around it, not a
  /// wide fit-bounds view that drifts as the destination changes. Falls
  /// back to the destination only if no bus fix is available yet.
  static const double _followZoom = 17.0;
  void _recenter() {
    final bus = _displayBusLatLng;
    if (bus != null) {
      _mapController.move(bus, _followZoom);
      return;
    }
    final dest = _destinationLatLng;
    if (dest != null) _mapController.move(dest, 14);
  }

  Future<void> _refresh() async {
    await ref
        .read(liveTrackingControllerProvider(widget.studentId).notifier)
        .refresh();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final l = widget.l;

    // React to every poll update for this student. Two things to handle:
    //   • A fresh bus fix → recenter the camera so the parent stays focused
    //     on the bus and its remaining route after each fetch.
    //   • Trip status flipped to Completed → pop the one-shot "Trip ended"
    //     dialog. We only fire the dialog once; later polls keep coming
    //     back as Completed but [_tripEndedShown] guards against re-open.
    // Keep _stableLineProvider mounted for the lifetime of this screen.
    // It's autoDispose so it'd otherwise be reset to [] in the brief
    // gaps where _Map.build is using `fresh` directly (no fallback
    // watch), which broke the deviation check below: a momentarily
    // empty stable line forced the anchor to advance, which changed
    // the OSRM cache key, which triggered a re-fetch — that's what was
    // making the polyline flicker on every poll.
    ref.listen(_stableLineProvider, (_, _) {});

    ref.listen(
      liveTrackingControllerProvider(widget.studentId),
      (_, next) {
        next.whenData((d) {
          final ts = d.busLocation?.timestamp;
          if (ts != null && ts != _lastRecenterTs) {
            _lastRecenterTs = ts;
            // Defer to post-frame so we don't fight the FlutterMap build
            // that's currently happening for the same change.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _recenter();
            });
          }
          // Decide whether the route polyline needs to be refetched. We
          // only swap the anchor when the bus has actually deviated from
          // the rendered polyline by > [_offRouteMeters] — otherwise we
          // keep the previous anchor so the OSRM cache hits and the line
          // stays visually identical, just with the bus marker gliding
          // along it. The bus position is read from the FRESH data [d]
          // because widget.data isn't updated until the post-listen
          // build runs.
          final bus = _displayBus(d);
          if (bus != null) {
            final stable = ref.read(_stableLineProvider);
            final shouldAnchor = _routeAnchorBus == null ||
                (stable.length >= 2 &&
                    _minMetersToPolyline(bus, stable) > _offRouteMeters);
            if (shouldAnchor) {
              _routeAnchorBus = bus;
            }
          }
          if (d.tripStatus?.toLowerCase() == 'completed') {
            unawaited(_showTripEndedDialog());
          }
        });
      },
    );

    return Column(
      children: [
        _Hero(data: data, l: l),
        Expanded(
          child: Stack(
            children: [
              _Map(
                controller: _mapController,
                bus: _displayBusLatLng,
                // routeBus is the anchored bus position that drives the
                // OSRM cache key. Falls back to the live bus on the very
                // first build before [_LiveBodyState] has had a chance to
                // see a poll. Holding it stable while the bus is on the
                // cached route keeps the polyline from re-routing on
                // every poll.
                routeBus: _routeAnchorBus ?? _displayBusLatLng,
                home: _homeLatLng,
                school: _schoolLatLng,
                destination: _destinationLatLng,
                pickup: _pickup(widget.data),
                pickupAlreadyVisited: _pickupVisited(widget.data),
                busLabel: data.busPlateNumber == null
                    ? null
                    : 'Bus #${data.busPlateNumber}',
                homeLabel: l.liveTrackingHome,
                schoolLabel: l.driverSchoolPin,
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Column(
                  children: [
                    _MapCtrl(
                      icon: Icons.my_location,
                      onTap: _recenter,
                      tint: AppColors.blue,
                    ),
                    const SizedBox(height: 6),
                    _MapCtrl(icon: Icons.layers_outlined, onTap: _refresh),
                  ],
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: _ZoomGroup(controller: _mapController),
              ),
            ],
          ),
        ),
        _Sheet(data: data, l: l),
      ],
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.data, required this.l});
  final LiveTracking data;
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LivePulse(color: AppColors.emerald),
                      const SizedBox(width: 5),
                      Text(
                        l.liveTrackingLive.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.studentFullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            // Top-banner ETA was removed — remaining time + speed live in
            // the bottom-sheet `_Stats` grid so they don't compete with the
            // student name for header space.
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
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse({this.color = AppColors.emerald});
  final Color color;
  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        final spread = 6 * t;
        final opacity = (1 - t).clamp(0.0, 1.0);
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.55 * opacity),
                blurRadius: 0,
                spreadRadius: spread,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Map ───────────────────────────────────────────────────────────

/// Last successful OSRM polyline for this screen. Held outside the keyed
/// `routedPathThroughProvider` so a refetch (which spawns a new family
/// instance in the `loading` state) doesn't blank the polyline — we keep
/// drawing the previous geometry while the new one is in flight. AutoDispose
/// so a fresh entry to the screen starts empty.
final _stableLineProvider =
    StateProvider.autoDispose<List<LatLng>>((_) => const []);

class _Map extends ConsumerWidget {
  const _Map({
    required this.controller,
    required this.bus,
    required this.routeBus,
    required this.home,
    required this.school,
    required this.destination,
    required this.pickup,
    required this.pickupAlreadyVisited,
    required this.busLabel,
    required this.homeLabel,
    required this.schoolLabel,
  });
  final MapController controller;
  /// Live bus position used for the marker + polyline trimming.
  final LatLng? bus;
  /// Anchored bus position used as the first waypoint when fetching the
  /// OSRM route. Held stable while the bus is on the cached route — see
  /// `_LiveBodyState._routeAnchorBus`. The marker still tracks the live
  /// [bus] so it glides along the polyline between OSRM refetches.
  final LatLng? routeBus;
  final LatLng? home;
  final LatLng? school;
  // Active destination — school in morning trips, home in return trips.
  final LatLng? destination;
  // Pickup point — home in morning, school in return. Used as the middle
  // waypoint when fetching the OSRM route so the parent sees the full
  // bus → pickup → destination path BEFORE the student boards.
  final LatLng? pickup;
  // True once the bus has reached the pickup — i.e., on Morning trips
  // after the student is on board (boardingStatus = "Boarded"), or on
  // Return trips since the bus always starts at the school. When true we
  // drop the pickup waypoint and just draw bus → destination.
  final bool pickupAlreadyVisited;
  final String? busLabel;
  final String homeLabel;
  final String schoolLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialCenter =
        bus ?? destination ?? home ?? school ?? const LatLng(31.95, 35.93);
    final initialZoom = bus != null && destination != null ? 13.0 : 14.0;

    // Only draw the REMAINING distance from the bus to the destination.
    // - Before pickup (Morning, status=Waiting): include the home as an
    //   intermediate waypoint so the parent sees bus → home → school.
    // - After pickup (Morning, status=Boarded): home is behind the bus
    //   already, so we drop it and draw bus → school straight away.
    // - Return trips: pickup is the school which the bus has left, so we
    //   skip it and draw bus → home.
    // Use the anchored bus position for the OSRM waypoint list — that's
    // what keys the cache, so anchoring it while the bus follows the
    // current polyline means the line stays stable. The marker tracks
    // the live [bus] via trimming below, so visually the bus glides
    // along the road even though the underlying polyline didn't change.
    final routeStart = routeBus ?? bus;
    final waypoints = <LatLng>[
      if (routeStart != null) routeStart,
      if (pickup != null &&
          !pickupAlreadyVisited &&
          (routeStart == null || _distSq(routeStart, pickup!) > 0.000001))
        pickup!,
      if (destination != null &&
          (pickup == null ||
              pickupAlreadyVisited ||
              _distSq(pickup!, destination!) > 0.000001))
        destination!,
    ];
    List<LatLng> linePoints = waypoints.length >= 2 ? waypoints : const [];
    if (waypoints.length >= 2) {
      final key = waypointsCacheKey(waypoints);
      final routed = ref.watch(routedPathThroughProvider(waypointsKey: key));
      // Promote each successful response into the stable cache so the next
      // refetch (different key → fresh `loading` state) still has something
      // to render against.
      ref.listen(
        routedPathThroughProvider(waypointsKey: key),
        (_, next) => next.whenData((d) {
          if (d.length >= 2) {
            ref.read(_stableLineProvider.notifier).state = d;
          }
        }),
      );
      final fresh = routed.valueOrNull;
      if (fresh != null && fresh.length >= 2) {
        linePoints = fresh;
      } else {
        final stable = ref.watch(_stableLineProvider);
        if (stable.length >= 2) linePoints = stable;
      }
    }
    // Project the bus's actual GPS onto the polyline so the marker glides
    // along the road shape between OSRM refetches. Also trim the polyline
    // so it starts at the bus — anything "behind" the bus's projected
    // position is dropped, leaving only the remaining route to render.
    LatLng? busOnLine = bus;
    if (bus != null && linePoints.length >= 2) {
      final trimmed = _trimPolylineFrom(bus!, linePoints);
      if (trimmed.isNotEmpty) {
        busOnLine = trimmed.first;
        linePoints = trimmed;
      }
    }

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        maxZoom: 18,
        minZoom: 4,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.smartbus.tilmez_bus',
          maxNativeZoom: 19,
        ),
        if (linePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: linePoints,
                strokeWidth: 4.5,
                color: AppColors.blue,
                borderStrokeWidth: 1.0,
                borderColor: Colors.white,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (home != null)
              Marker(
                point: home!,
                width: 80,
                height: 70,
                alignment: Alignment.bottomCenter,
                child: _PinWithLabel(
                  label: homeLabel,
                  color: const Color(0xFFE11D48),
                  icon: Icons.home_filled,
                ),
              ),
            if (school != null)
              Marker(
                point: school!,
                width: 80,
                height: 70,
                alignment: Alignment.bottomCenter,
                child: _PinWithLabel(
                  label: schoolLabel,
                  color: AppColors.blue,
                  icon: Icons.school,
                ),
              ),
            if (busOnLine != null)
              Marker(
                point: busOnLine,
                width: 110,
                height: 110,
                // Center the marker on the coordinate so the bus icon sits
                // exactly on the polyline's first vertex — no anchor offset,
                // no visual gap between the icon and the route line.
                alignment: Alignment.center,
                child: _BusMarker(label: busLabel),
              ),
          ],
        ),
      ],
    );
  }
}

class _PinWithLabel extends StatelessWidget {
  const _PinWithLabel({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.slate100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ],
    );
  }
}

class _BusMarker extends StatefulWidget {
  const _BusMarker({this.label});
  final String? label;

  @override
  State<_BusMarker> createState() => _BusMarkerState();
}

class _BusMarkerState extends State<_BusMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stack is centered: the bus disc and the pulse share the marker's
    // centerpoint, which is exactly the polyline's first vertex. The label
    // (if any) is `Positioned` above the icon and `clipBehavior: none`
    // lets it overflow without shifting the icon's anchor.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final t = _ctrl.value;
            final size = 32 + 50 * t;
            final opacity = (0.55 * (1 - t)).clamp(0.0, 1.0);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.yellow.withValues(alpha: opacity),
              ),
            );
          },
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.yellow, AppColors.yellowDeep],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.directions_bus,
            size: 17,
            color: AppColors.ink,
          ),
        ),
        if (widget.label != null)
          Positioned(
            bottom: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.label!,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MapCtrl extends StatelessWidget {
  const _MapCtrl({required this.icon, required this.onTap, this.tint});
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: const BorderSide(color: AppColors.slate100),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(icon, size: 15, color: tint ?? AppColors.slate700),
          ),
        ),
      ),
    );
  }
}

class _ZoomGroup extends StatelessWidget {
  const _ZoomGroup({required this.controller});
  final MapController controller;

  void _zoom(double delta) {
    final z = controller.camera.zoom;
    controller.move(controller.camera.center, (z + delta).clamp(4.0, 18.0));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.slate100),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _zoom(1),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Icon(Icons.add, size: 16, color: AppColors.slate700),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate100),
          InkWell(
            onTap: () => _zoom(-1),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Icon(Icons.remove, size: 16, color: AppColors.slate700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet ──────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  const _Sheet({required this.data, required this.l});
  final LiveTracking data;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = data.busLocation?.timestamp;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Stats(data: data, l: l),
            const SizedBox(height: 12),
            _CrewCard(data: data, l: l),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _LivePulse(color: AppColors.emerald),
                const SizedBox(width: 6),
                Text(
                  l.liveTrackingLastUpdated(_relativeTime(lastUpdated, l)),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate400,
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

class _Stats extends StatelessWidget {
  const _Stats({required this.data, required this.l});
  final LiveTracking data;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final speedKmh = data.busLocation?.speed == null
        ? null
        : (data.busLocation!.speed! * 3.6).round();
    final distance = _kmDistance(data);
    final boardingTime = data.boardingTime;
    final etaMin = _etaMinutes(data);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.check,
                bg: const Color(0xFFFEF3C7),
                fg: const Color(0xFFD97706),
                border: const Color(0xFFFDE68A),
                label: l.liveTrackingBoarded,
                value: _hhmm(boardingTime),
                unit: _ampm(boardingTime),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: Icons.location_on_outlined,
                bg: AppColors.blueSoft,
                fg: AppColors.blue,
                border: const Color(0xFFBFDBFE),
                label: l.liveTrackingDistance,
                value: distance == null ? '—' : distance.toStringAsFixed(1),
                unit: distance == null ? '' : 'km',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.speed,
                bg: AppColors.violetSoft,
                fg: AppColors.violet,
                border: const Color(0xFFDDD6FE),
                label: l.liveTrackingSpeed,
                value: speedKmh == null ? '—' : '$speedKmh',
                unit: speedKmh == null ? '' : 'km/h',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: Icons.access_time,
                bg: AppColors.emeraldSoft,
                fg: AppColors.emerald,
                border: const Color(0xFFA7F3D0),
                label: l.liveTrackingArrives,
                value: etaMin == null ? '—' : _etaRange(etaMin),
                unit: etaMin == null ? '' : 'min',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.border,
    required this.label,
    required this.value,
    required this.unit,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color border;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: fg),
          ),
          const SizedBox(width: 9),
          Expanded(
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
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Assistant contact card — parents reach the assistant on the bus, not
/// the driver, so this is the only crew row we render. Polished layout:
/// avatar with stronger yellow gradient, role pill above the name, phone
/// number underneath, and a pair of call / WhatsApp action buttons with
/// labels.
class _CrewCard extends StatelessWidget {
  const _CrewCard({required this.data, required this.l});
  final LiveTracking data;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final name = data.assistantName;
    final phone = data.assistantPhone;
    if (name == null || name.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            const Icon(Icons.support_agent,
                size: 18, color: AppColors.slate400),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.liveTrackingNoCrew,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return _AssistantCard(name: name, phone: phone, l: l);
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({
    required this.name,
    required this.phone,
    required this.l,
  });
  final String name;
  final String? phone;
  final AppLocalizations l;

  Future<void> _call() async {
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    if (phone == null) return;
    final cleaned = phone!.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBEB), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66F5C518)),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.yellow, AppColors.yellowDeep],
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.yellow.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.yellowTint,
                        borderRadius: BorderRadius.circular(100),
                        border:
                            Border.all(color: const Color(0x66F5C518)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.support_agent,
                              size: 10, color: AppColors.yellowDeep),
                          const SizedBox(width: 4),
                          Text(
                            l.liveTrackingAssistant.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.yellowDeep,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (phone != null && phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 11, color: AppColors.slate500),
                          const SizedBox(width: 4),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              phone!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate500,
                                letterSpacing: -0.1,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
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
          if (phone != null && phone!.isNotEmpty) ...[
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: _CrewActionBtn(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF34D399), Color(0xFF25D366)],
                    ),
                    foreground: Colors.white,
                    shadow: const Color(0xFF25D366),
                    onTap: _whatsapp,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CrewActionBtn(
                    icon: Icons.call,
                    label: l.liveTrackingCall,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.yellow, AppColors.yellowDeep],
                    ),
                    foreground: AppColors.ink,
                    shadow: AppColors.yellow,
                    onTap: _call,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Wide call/WhatsApp button with an icon + label. Stretches to fill its
/// column so the two actions sit side-by-side with equal weight.
class _CrewActionBtn extends StatelessWidget {
  const _CrewActionBtn({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.foreground,
    required this.shadow,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color foreground;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Ink(
          height: 38,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: shadow.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: foreground,
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

// ─── Error ────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.l});
  final String message;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 36, color: Colors.white54),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────

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
  final l = dt.toLocal();
  final h = l.hour;
  final m = l.minute.toString().padLeft(2, '0');
  final hh12 = h % 12 == 0 ? 12 : h % 12;
  return '$hh12:$m';
}

String _ampm(DateTime? dt) {
  if (dt == null) return '';
  return dt.toLocal().hour >= 12 ? 'PM' : 'AM';
}

int? _etaMinutes(LiveTracking data) {
  // Rough ETA: distance to the active destination / GPS speed when known,
  // otherwise a 30 km/h urban average.
  final speed = data.busLocation?.speed; // m/s
  final dist = _meters(data); // meters
  if (dist == null) return null;
  final mps = (speed != null && speed > 1.0) ? speed : 30 * 1000 / 3600;
  final secs = dist / mps;
  return (secs / 60).round().clamp(1, 999);
}

/// Spreads a single ETA estimate into a short range that reflects normal
/// urban variability — roughly ±15-20%, snapped to whole minutes, with a
/// minimum spread of 2 min so it always reads as a range.
String _etaRange(int mins) {
  final low = math.max(1, (mins * 0.85).round());
  var high = (mins * 1.20).round() + 1;
  if (high - low < 2) high = low + 2;
  return '$low-$high';
}

/// Whether the bus has already reached the pickup point — i.e., we
/// shouldn't include `pickup` in the OSRM waypoint list because it's
/// behind the bus. Morning trips: true once the student is on board.
/// Return trips: always true (bus has left the school before the parent
/// starts watching).
bool _pickupVisited(LiveTracking data) {
  final morning = data.tripType?.toLowerCase() == 'morning';
  if (!morning) return true;
  final status = data.boardingStatus?.toLowerCase();
  return status == 'boarded' ||
      status == 'arrived' ||
      status == 'droppedoff' ||
      status == 'dropped_off';
}

/// Trims [line] so it starts at the closest point to [p], dropping every
/// vertex that's "behind" [p] along the polyline. Result is
/// `[projected_bus, next_vertex, ..., destination]` — i.e., the remaining
/// route to render. Empty when the polyline is too short to project onto.
List<LatLng> _trimPolylineFrom(LatLng p, List<LatLng> line) {
  if (line.length < 2) return line;
  // cos(lat) at the bus latitude — used to scale longitude into metric
  // units so the projection is accurate at non-equatorial latitudes
  // (Jordan ≈ 31°N, where unscaled lon distances are ~15% off).
  final kx = math.cos(p.latitude * math.pi / 180.0);
  int bestSegment = 0;
  LatLng bestPoint = line.first;
  var bestDistSq = double.infinity;
  for (var i = 0; i < line.length - 1; i++) {
    final candidate = _projectOntoSegment(p, line[i], line[i + 1], kx);
    final d = _metricDistSq(p, candidate, kx);
    if (d < bestDistSq) {
      bestDistSq = d;
      bestSegment = i;
      bestPoint = candidate;
    }
  }
  // Keep: projected_bus + vertex(bestSegment + 1) + everything after.
  return <LatLng>[bestPoint, ...line.sublist(bestSegment + 1)];
}

/// Perpendicular foot of [p] on segment [a]→[b], clamped to the segment,
/// computed in a local equirectangular frame so the result tracks the road
/// instead of skewing in longitude at our latitudes.
LatLng _projectOntoSegment(LatLng p, LatLng a, LatLng b, double kx) {
  final dx = (b.longitude - a.longitude) * kx;
  final dy = b.latitude - a.latitude;
  final lenSq = dx * dx + dy * dy;
  if (lenSq < 1e-15) return a;
  var t = ((p.longitude - a.longitude) * kx * dx +
          (p.latitude - a.latitude) * dy) /
      lenSq;
  if (t < 0) t = 0;
  if (t > 1) t = 1;
  return LatLng(
    a.latitude + t * dy,
    a.longitude + t * dx / (kx == 0 ? 1 : kx),
  );
}

/// Squared distance between two points in a local metric frame (longitudes
/// pre-scaled by [kx] = cos(lat)). Used to pick the closest road point so
/// a bus near a curving street picks the nearest segment, not a far one
/// that's just east/west of it.
double _metricDistSq(LatLng a, LatLng b, double kx) {
  final dx = (a.longitude - b.longitude) * kx;
  final dy = a.latitude - b.latitude;
  return dx * dx + dy * dy;
}

/// Squared planar distance between two points — fine for short
/// city-scale distances where we just need an "are these the same point"
/// check (used to drop redundant waypoints from the OSRM call).
double _distSq(LatLng a, LatLng b) {
  final dx = a.latitude - b.latitude;
  final dy = a.longitude - b.longitude;
  return dx * dx + dy * dy;
}

LatLng? _pickup(LiveTracking data) {
  final morning = data.tripType?.toLowerCase() == 'morning';
  if (morning) {
    if (data.homeLatitude != null && data.homeLongitude != null) {
      return LatLng(data.homeLatitude!, data.homeLongitude!);
    }
  } else {
    if (data.schoolLatitude != null && data.schoolLongitude != null) {
      return LatLng(data.schoolLatitude!, data.schoolLongitude!);
    }
  }
  return null;
}

LatLng? _destination(LiveTracking data) {
  final morning = data.tripType?.toLowerCase() == 'morning';
  if (morning) {
    if (data.schoolLatitude != null && data.schoolLongitude != null) {
      return LatLng(data.schoolLatitude!, data.schoolLongitude!);
    }
    if (data.homeLatitude != null && data.homeLongitude != null) {
      return LatLng(data.homeLatitude!, data.homeLongitude!);
    }
  } else {
    if (data.homeLatitude != null && data.homeLongitude != null) {
      return LatLng(data.homeLatitude!, data.homeLongitude!);
    }
    if (data.schoolLatitude != null && data.schoolLongitude != null) {
      return LatLng(data.schoolLatitude!, data.schoolLongitude!);
    }
  }
  return null;
}

/// Best-effort bus position: real GPS when available, otherwise interpolate
/// along the pickup → destination line using the trip's elapsed time.
LatLng? _displayBus(LiveTracking data) {
  final bus = data.busLocation;
  if (bus != null) return LatLng(bus.latitude, bus.longitude);
  final pickup = _pickup(data);
  final dest = _destination(data);
  if (pickup == null || dest == null) return null;
  final status = data.tripStatus?.toLowerCase();
  if (status == 'completed') return dest;
  if (status == 'scheduled') return pickup;
  final start = data.actualDeparture ?? data.scheduledDeparture;
  if (start == null) return pickup;
  final end = data.actualArrival ?? start.add(const Duration(minutes: 30));
  final totalSec = end.difference(start).inSeconds;
  final elapsedSec = DateTime.now().difference(start).inSeconds;
  final f = totalSec <= 0 ? 0.5 : (elapsedSec / totalSec).clamp(0.0, 1.0);
  return LatLng(
    pickup.latitude + (dest.latitude - pickup.latitude) * f,
    pickup.longitude + (dest.longitude - pickup.longitude) * f,
  );
}

double? _meters(LiveTracking data) {
  final bus = _displayBus(data);
  final dest = _destination(data);
  if (bus == null || dest == null) return null;
  return _haversine(bus.latitude, bus.longitude, dest.latitude, dest.longitude);
}

double? _kmDistance(LiveTracking data) {
  final m = _meters(data);
  return m == null ? null : m / 1000.0;
}

double _haversine(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = (1 - math.cos(dLat)) / 2 +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          (1 - math.cos(dLng)) /
          2;
  return 2 * r * math.asin(math.sqrt(a));
}

double _toRad(double d) => d * math.pi / 180.0;

/// Minimum distance in metres from [p] to any segment of [line]. Used
/// by the parent map to decide whether the bus has left the currently
/// rendered polyline and we should refetch a fresh route. Computed in
/// a local equirectangular frame (longitudes pre-scaled by cos(lat))
/// so it stays accurate at non-equatorial latitudes.
double _minMetersToPolyline(LatLng p, List<LatLng> line) {
  if (line.length < 2) return double.infinity;
  final kx = math.cos(p.latitude * math.pi / 180.0);
  const metersPerDegLat = 111320.0;
  final metersPerDegLon = metersPerDegLat * kx;
  double best = double.infinity;
  for (var i = 0; i < line.length - 1; i++) {
    final a = line[i];
    final b = line[i + 1];
    final dx = (b.longitude - a.longitude) * metersPerDegLon;
    final dy = (b.latitude  - a.latitude)  * metersPerDegLat;
    final lenSq = dx * dx + dy * dy;
    double t;
    if (lenSq < 1e-9) {
      t = 0;
    } else {
      t = ((p.longitude - a.longitude) * metersPerDegLon * dx +
              (p.latitude  - a.latitude)  * metersPerDegLat * dy) /
          lenSq;
      if (t < 0) t = 0;
      if (t > 1) t = 1;
    }
    final px = a.longitude * metersPerDegLon + t * dx;
    final py = a.latitude  * metersPerDegLat + t * dy;
    final qx = p.longitude * metersPerDegLon;
    final qy = p.latitude  * metersPerDegLat;
    final d = math.sqrt((px - qx) * (px - qx) + (py - qy) * (py - qy));
    if (d < best) best = d;
  }
  return best;
}

String _relativeTime(DateTime? when, AppLocalizations l) {
  if (when == null) return l.liveTrackingNever;
  final secs = DateTime.now().difference(when).inSeconds;
  if (secs < 5) return l.liveTrackingJustNow;
  if (secs < 60) return '${secs}s';
  final mins = (secs / 60).floor();
  if (mins < 60) return '${mins}m';
  final hrs = (mins / 60).floor();
  return '${hrs}h';
}
