import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:tilmez_bus/core/config/env.dart';
import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_details_dto.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Last-resort school anchor when the Schools row has no coords configured
/// yet. Roughly the centre of Amman. The real coordinate comes from the
/// SuperAdmin via the Create/Update School flow.
const _kSchoolFallback = LatLng(31.9539, 35.9106);

/// Driver-only map view: renders an ordered route through the trip's boarded
/// student homes plus the school. Morning trips go [home1 → home2 → school],
/// return trips go [school → home1 → home2]. Polyline geometry is fetched
/// from OSRM (public demo server) for actual driving distance.
///
/// While mounted, the screen polls the trip-details provider every 8s so the
/// progress bar + dropped-off pins refresh as the assistant marks students
/// done — without forcing the driver to pull-to-refresh.
class DriverTripMapScreen extends ConsumerStatefulWidget {
  const DriverTripMapScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<DriverTripMapScreen> createState() =>
      _DriverTripMapScreenState();
}

class _DriverTripMapScreenState extends ConsumerState<DriverTripMapScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        ref.invalidate(tripDetailsProvider(widget.tripId));
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detailsAsync = ref.watch(tripDetailsProvider(widget.tripId));
    return Scaffold(
      backgroundColor: Colors.white,
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is Failure ? e.message : '$e',
          onRetry: () => ref.invalidate(tripDetailsProvider(widget.tripId)),
        ),
        data: (d) => _MapView(details: d, l: l),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final stops = _buildStops(details);
    if (stops.length < 2) {
      return _NoStopsView(l: l, hasNone: stops.isEmpty);
    }
    return _RoutedMap(stops: stops, details: details, l: l);
  }

  /// Build the ordered stop list for this trip.
  ///
  /// Only boarded students with coordinates are routed — absent / no-show
  /// students are skipped. The visit order is computed via nearest-neighbour
  /// from the school: the home FARTHEST from the school is the morning
  /// pickup #1, then we always go to the closest unvisited home. This
  /// keeps the bus walking inwards until it reaches the school. Return
  /// trips reuse the same chain reversed — the bus drops the closest-to-
  /// school student first, working outwards.
  List<_Stop> _buildStops(TripDetailsDto d) {
    // Morning trips end at the school, so the school is rendered as the
    // final destination — except the moment any student arrives at school
    // (end-trip flips them to DroppedOff), the school is no longer
    // relevant either, so we hide it as well by tagging it dropped.
    // Return trips never show the school: the bus *left* from there and
    // the route is just home → home → home.
    final school = _Stop(
      point: LatLng(
        d.schoolLatitude ?? _kSchoolFallback.latitude,
        d.schoolLongitude ?? _kSchoolFallback.longitude,
      ),
      label: d.schoolName ?? l.driverSchoolPin,
      kind: _StopKind.school,
      dropped: d.droppedOffCount > 0,
    );

    // Include every non-absent student with a known location — this covers
    // a freshly started trip where nobody has boarded yet, so the driver
    // can still see the planned route before pickups begin.
    final morning = d.isMorning;
    final homes = d.students
        .where((s) =>
            !s.isAbsent &&
            s.latitude != null &&
            s.longitude != null)
        .map((s) => _Stop(
              point: LatLng(s.latitude!, s.longitude!),
              label: s.fullName,
              kind: _StopKind.home,
              area: (s.homeArea?.trim().isNotEmpty ?? false)
                  ? s.homeArea!.trim()
                  : null,
              // "On bus" means the driver doesn't still need to *reach*
              // this student. On Morning trips that's the moment the
              // assistant marks them boarded; on Return trips every rider
              // is on the bus from the start, so don't tag them — the
              // driver still has to drive them home.
              boarded: morning && s.isBoarded,
              dropped: s.isDroppedOff,
            ))
        .toList();

    final ordered = _orderByNearest(homes, school);

    if (d.isMorning) {
      // Morning: pick up the farthest student first, work toward school.
      return [...ordered, school];
    }
    // Return: bus leaves school and drops in the reverse pickup order
    // (closest-to-school first, farthest last). The school itself is not
    // a stop on the route — the bus is already there at trip start.
    return ordered.reversed.toList();
  }

  /// Greedy nearest-neighbour traversal of [homes] anchored at [school].
  /// The first stop is the home FARTHEST from the school; each next stop
  /// is the closest unvisited home from the current position.
  List<_Stop> _orderByNearest(List<_Stop> homes, _Stop school) {
    if (homes.isEmpty) return const [];
    final remaining = [...homes];
    // Farthest from school becomes the first pickup.
    remaining.sort((a, b) => _sqDist(b.point, school.point)
        .compareTo(_sqDist(a.point, school.point)));
    final result = [remaining.removeAt(0)];
    while (remaining.isNotEmpty) {
      final last = result.last.point;
      remaining.sort(
          (a, b) => _sqDist(a.point, last).compareTo(_sqDist(b.point, last)));
      result.add(remaining.removeAt(0));
    }
    return result;
  }

  /// Squared planar distance is enough for ranking nearest neighbours over
  /// city-scale distances; no need to invoke the haversine formula here.
  double _sqDist(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return dx * dx + dy * dy;
  }
}

class _RoutedMap extends StatefulWidget {
  const _RoutedMap({
    required this.stops,
    required this.details,
    required this.l,
  });
  final List<_Stop> stops;
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  State<_RoutedMap> createState() => _RoutedMapState();
}

class _RoutedMapState extends State<_RoutedMap> {
  final MapController _map = MapController();
  List<LatLng> _route = const [];
  bool _loading = true;
  String? _error;
  /// Driver's current GPS position, surfaced from `geolocator`. Drives the
  /// "you-are-here" marker and the per-stop "X.X km away" pill that ticks
  /// down while the driver moves.
  LatLng? _currentPos;
  StreamSubscription<Position>? _posSub;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    _startLocationStream();
  }

  /// Best-effort: ask once for permission, then subscribe to high-accuracy
  /// updates with a 25 m distance filter so we don't spam setState. Failures
  /// (denied permission, simulator without coords) just leave _currentPos
  /// null and the bottom sheet falls back to inter-stop distances.
  Future<void> _startLocationStream() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 25,
        ),
      ).listen((p) {
        if (!mounted) return;
        setState(() => _currentPos = LatLng(p.latitude, p.longitude));
      });
    } catch (_) {
      // Silent — distance pills just won't update.
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _RoutedMap old) {
    super.didUpdateWidget(old);
    // Re-fetch the polyline whenever the *active* (still-to-visit) stops
    // change — that includes a student flipping to "on bus" (we drop them
    // from the route since the bus already has them) or to DroppedOff.
    if (!_sameActiveStops(old.stops, widget.stops)) {
      _fetchRoute();
    }
  }

  /// Stops the bus still needs to drive to. We drop:
  ///   • Boarded students (Morning) — already on the bus.
  ///   • Dropped students (Return)  — already arrived home.
  /// The school stays in either list since it's still a destination on
  /// Morning trips and the origin for Return.
  List<_Stop> get _activeStops =>
      widget.stops.where((s) => !s.boarded && !s.dropped).toList();

  bool _sameActiveStops(List<_Stop> oldAll, List<_Stop> newAll) {
    bool active(_Stop s) => !s.boarded && !s.dropped;
    final a = oldAll.where(active).toList();
    final b = newAll.where(active).toList();
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].point.latitude != b[i].point.latitude ||
          a[i].point.longitude != b[i].point.longitude) {
        return false;
      }
    }
    return true;
  }

  /// Hits OSRM's public demo server to retrieve a real driving polyline
  /// across the ordered stops. On any failure we silently fall back to
  /// straight lines between stops so the screen still renders.
  Future<void> _fetchRoute() async {
    if (!mounted) return;
    final active = _activeStops;
    if (active.length < 2) {
      setState(() {
        _route = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final coords = active
        .map((s) => '${s.point.longitude},${s.point.latitude}')
        .join(';');
    final uri = Uri.parse(
      '${Env.osrmBaseUrl}/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'User-Agent': 'TilmezBusMobile/1.0'},
      ));
      final res = await dio.getUri<dynamic>(uri);
      final body = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : (res.data is String
              ? jsonDecode(res.data as String) as Map<String, dynamic>
              : <String, dynamic>{});
      final routes = body['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw const FormatException('no route');
      }
      final first = routes.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>;
      final raw = geometry['coordinates'] as List<dynamic>;
      final pts = raw
          .map((c) => (c as List<dynamic>))
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _route = pts;
        _loading = false;
        _error = null;
      });
      _fitBounds();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _route = active.map((s) => s.point).toList();
        _loading = false;
        _error = widget.l.driverRouteFallback;
      });
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (_route.length < 2) return;
    final bounds = LatLngBounds.fromPoints(_route);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _map.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(40, 120, 40, 180),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: widget.stops.first.point,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartbus',
            ),
            if (_route.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _route,
                    color: AppColors.yellowDeep,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Only draw pins for stops the bus still has to visit —
                // boarded students fall off the map (the bus has them).
                for (var i = 0; i < _activeStops.length; i++)
                  Marker(
                    point: _activeStops[i].point,
                    width: 44,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: _PinMarker(
                      step: i + 1,
                      stop: _activeStops[i],
                    ),
                  ),
                if (_currentPos != null)
                  Marker(
                    point: _currentPos!,
                    width: 24,
                    height: 24,
                    child: const _DriverHereDot(),
                  ),
              ],
            ),
          ],
        ),

        // Top overlay: back button + route summary card
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _GlassBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RouteSummaryCard(
                      details: widget.details,
                      stops: widget.stops,
                      l: widget.l,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom overlay: ordered stops list
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _StopsListSheet(
            stops: widget.stops,
            currentPos: _currentPos,
            isMorning: widget.details.isMorning,
            l: widget.l,
          ),
        ),

        if (_loading)
          const Positioned(
            top: 110,
            right: 14,
            child: _LoadingChip(),
          ),
        if (_error != null && !_loading)
          Positioned(
            top: 110,
            right: 14,
            child: _ErrorChip(text: _error!),
          ),
      ],
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.details,
    required this.stops,
    required this.l,
  });
  final TripDetailsDto details;
  final List<_Stop> stops;
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    final morning = details.isMorning;
    final stopCount = stops.length - 1; // exclude school terminal
    // Routed students = boarded + dropped (i.e. everyone the bus is
    // carrying or has carried). Progress = dropped / routed.
    final routed = details.students
        .where((s) =>
            !s.isAbsent && s.latitude != null && s.longitude != null)
        .length;
    // Morning leg cares about pickups; Return leg cares about drop-offs.
    // The bar fills with the matching counter so the driver sees real
    // progress through their leg as the assistant marks students.
    final progressNumerator =
        morning ? details.boardedCount : details.droppedOffCount;
    // Morning trips count students who are now on the bus; Return trips
    // count students delivered home.
    final progressLabel =
        morning ? l.assistantOnBus : l.driverProgressLabelReturn;
    final progress = routed == 0 ? 0.0 : progressNumerator / routed;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 14, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.slate100),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      morning ? const Color(0xFFFEF3C7) : AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  morning
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_outlined,
                  size: 16,
                  color: morning ? const Color(0xFFD97706) : AppColors.violet,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${morning ? l.assistantMorningPickup : l.assistantAfternoonDropoff} · ${details.busPlateNumber}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l.driverStopsCount(stopCount),
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
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                progressLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.slate100,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.emerald),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  children: [
                    TextSpan(
                      text: '$progressNumerator',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(text: '/$routed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopsListSheet extends StatelessWidget {
  const _StopsListSheet({
    required this.stops,
    required this.currentPos,
    required this.isMorning,
    required this.l,
  });
  final List<_Stop> stops;
  /// Driver's current GPS, if available. When set, each stop row shows the
  /// straight-line distance from the bus to that home — updates live as the
  /// driver moves. When null, falls back to the leg distance from the
  /// previous stop.
  final LatLng? currentPos;
  final bool isMorning;
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l.driverRouteOrderTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Builder(
                  builder: (_) {
                    // Promote upcoming stops to the top so the next student
                    // the driver needs to reach is always row #1, then list
                    // already-handled stops (boarded / dropped) underneath.
                    bool upcoming(_Stop s) => !s.boarded && !s.dropped;
                    final ordered = [
                      ...stops.where(upcoming),
                      ...stops.where((s) => !upcoming(s)),
                    ];
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: ordered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 6),
                      itemBuilder: (_, i) => _StopRow(
                        step: i + 1,
                        stop: ordered[i],
                        // Live distance from the bus when GPS is known;
                        // otherwise fall back to the static "from previous
                        // stop" estimate based on the original drive order.
                        legKm: currentPos != null
                            ? _haversineKm(currentPos!, ordered[i].point)
                            : (i == 0
                                ? null
                                : _haversineKm(
                                    ordered[i - 1].point,
                                    ordered[i].point)),
                        isLive: currentPos != null,
                        isMorning: isMorning,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.step,
    required this.stop,
    required this.legKm,
    required this.isMorning,
    this.isLive = false,
  });
  final int step;
  final _Stop stop;
  /// Distance to render in the right-edge pill. When [isLive] is true this
  /// is the bus → stop distance and updates as the driver moves; otherwise
  /// it's the static previous → stop leg.
  final double? legKm;
  final bool isMorning;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final isSchool = stop.kind == _StopKind.school;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSchool ? AppColors.blueSoft : AppColors.slate50,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isSchool
              ? AppColors.blue.withValues(alpha: 0.3)
              : AppColors.slate100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSchool ? AppColors.blue : AppColors.ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSchool ? AppColors.blueDark : AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (stop.area != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 11, color: AppColors.slate500),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            stop.area!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate500,
                              letterSpacing: -0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (stop.dropped)
            Builder(builder: (context) {
              // Return trip = student is now at home; Morning trip = at school.
              final l = AppLocalizations.of(context);
              final label = isMorning ? l.driverPinArrived : l.driverPinAtHome;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 10, color: AppColors.emerald),
                    const SizedBox(width: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              );
            })
          else if (stop.boarded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.emeraldSoft,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_bus_filled_outlined,
                      size: 11, color: AppColors.emerald),
                  SizedBox(width: 3),
                  Text(
                    'On bus',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            )
          else if (legKm != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isLive ? AppColors.yellowTint : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLive
                      ? const Color(0x66F5C518)
                      : AppColors.slate200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLive) ...[
                    const Icon(
                      Icons.navigation_outlined,
                      size: 10,
                      color: AppColors.yellowDeep,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    _formatKm(legKm!),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isLive
                          ? AppColors.yellowDeep
                          : AppColors.slate700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 6),
          Icon(
            isSchool ? Icons.school_outlined : Icons.home_outlined,
            size: 14,
            color: isSchool ? AppColors.blue : AppColors.slate500,
          ),
        ],
      ),
    );
  }

  String _formatKm(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }
}

/// Great-circle distance between two coordinates (km). Good enough for stop
/// distance hints — actual driving polyline still comes from OSRM.
double _haversineKm(LatLng a, LatLng b) {
  const earthKm = 6371.0;
  final dLat = _deg2rad(b.latitude - a.latitude);
  final dLon = _deg2rad(b.longitude - a.longitude);
  final lat1 = _deg2rad(a.latitude);
  final lat2 = _deg2rad(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthKm * c;
}

double _deg2rad(double d) => d * (math.pi / 180.0);

class _PinMarker extends StatelessWidget {
  const _PinMarker({required this.step, required this.stop});
  final int step;
  final _Stop stop;
  @override
  Widget build(BuildContext context) {
    final isSchool = stop.kind == _StopKind.school;
    final fill = stop.dropped
        ? AppColors.emerald
        : (isSchool ? AppColors.blue : AppColors.yellowDeep);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: stop.dropped
              ? const Icon(Icons.check_rounded,
                  size: 16, color: Colors.white)
              : (isSchool
                  ? const Icon(Icons.school_rounded,
                      size: 14, color: Colors.white)
                  : Text(
                      '$step',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: CustomPaint(
            size: const Size(10, 6),
            painter: _PinTipPainter(color: fill),
          ),
        ),
      ],
    );
  }
}

/// Pulsing blue dot rendered at the bus's current GPS position.
class _DriverHereDot extends StatelessWidget {
  const _DriverHereDot();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x332563EB),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinTipPainter extends CustomPainter {
  _PinTipPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTipPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GlassBtn extends StatelessWidget {
  const _GlassBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}

class _LoadingChip extends StatelessWidget {
  const _LoadingChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: AppShadows.sm,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Routing…',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  const _ErrorChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.redDark,
        ),
      ),
    );
  }
}

class _NoStopsView extends StatelessWidget {
  const _NoStopsView({required this.l, required this.hasNone});
  final AppLocalizations l;
  final bool hasNone;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _GlassBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop(),
              ),
            ),
            const SizedBox(height: 80),
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppColors.slate500,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hasNone
                  ? l.driverNoBoardedStopsTitle
                  : l.driverNeedMoreStopsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.driverNoBoardedStopsBody,
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
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─── Stop model ─────────────────────────────────────────────────────────

enum _StopKind { home, school }

class _Stop {
  const _Stop({
    required this.point,
    required this.label,
    required this.kind,
    this.area,
    this.boarded = false,
    this.dropped = false,
  });
  final LatLng point;
  final String label;
  final _StopKind kind;
  /// Home-area / district label rendered next to the student name.
  final String? area;
  /// True for any student currently riding the bus — replaces the remaining-
  /// distance pill with an "On bus" tag on the driver map (the bus doesn't
  /// need to drive *to* a passenger it's already carrying).
  final bool boarded;
  /// True once the assistant has marked this student as DroppedOff —
  /// renders the pin greyed with a check overlay and tags the row "Arrived".
  final bool dropped;
}
