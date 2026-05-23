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
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_details_dto.dart';
import 'package:tilmez_bus/features/assistant/data/services/trip_location_broadcaster.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
  /// Set once we've shown the "Trip ended" dialog so a stale poll cycle
  /// doesn't re-open it after the driver dismisses.
  bool _tripEndedShown = false;

  @override
  void initState() {
    super.initState();
    // Poll every 3 s so any action the assistant takes on the other
    // device (mark boarded, mark dropped off, end trip) shows up on the
    // driver map within one cycle — matches the cadence of the parent's
    // live-tracking poll so all three roles stay roughly in sync.
    _poll = Timer.periodic(const Duration(seconds: 3), (_) {
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

  /// One-shot dialog shown when the assistant flips the trip to Completed
  /// while the driver still has the map open. Tapping Close drops the
  /// driver back on their home screen and invalidates myTodayTripsProvider
  /// so the list refreshes without a pull-to-refresh.
  Future<void> _showTripEndedDialog() async {
    if (_tripEndedShown || !mounted) return;
    _tripEndedShown = true;
    final l = AppLocalizations.of(context);
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
    ref.invalidate(myTodayTripsProvider);
    context.go(AppRoute.homeDriver);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detailsAsync = ref.watch(tripDetailsProvider(widget.tripId));
    // Watch for the Scheduled/InProgress → Completed transition so the
    // driver gets a clear "trip ended" cue and lands back on home with
    // a fresh trips list. Guarded by [_tripEndedShown] so it only fires
    // once per screen mount.
    ref.listen(
      tripDetailsProvider(widget.tripId),
      (_, next) {
        next.whenData((d) {
          if (d.status == 'Completed') {
            unawaited(_showTripEndedDialog());
          }
        });
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is Failure ? e.message : '$e',
          onRetry: () => ref.invalidate(tripDetailsProvider(widget.tripId)),
        ),
        data: (d) {
          // Keep the GPS broadcaster alive while this screen is mounted.
          // The same provider is watched on the trip-details screen, so
          // the broadcaster keeps running as the assistant navigates
          // between map and details.
          if (d.status != 'Completed') {
            ref.watch(tripLocationBroadcasterProvider(d.busId));
          }
          return _MapView(details: d, l: l);
        },
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

}

/// Squared planar distance is enough for ranking nearest neighbours over
/// city-scale distances; no need to invoke the haversine formula here.
/// Hoisted to file scope so [_RoutedMapState] can reuse the same metric
/// when re-ordering stops from the GPS anchor.
double _sqDist(LatLng a, LatLng b) {
  final dx = a.latitude - b.latitude;
  final dy = a.longitude - b.longitude;
  return dx * dx + dy * dy;
}

class _RoutedMap extends ConsumerStatefulWidget {
  const _RoutedMap({
    required this.stops,
    required this.details,
    required this.l,
  });
  final List<_Stop> stops;
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  ConsumerState<_RoutedMap> createState() => _RoutedMapState();
}

class _RoutedMapState extends ConsumerState<_RoutedMap> {
  final MapController _map = MapController();
  List<LatLng> _route = const [];
  bool _loading = true;
  String? _error;
  /// Driver's current GPS position, surfaced from `geolocator`. Drives the
  /// "you-are-here" marker and the per-stop "X.X km away" pill that ticks
  /// down while the driver moves.
  LatLng? _currentPos;
  /// Latest speed reading from the GPS stream, metres/second. 0 when the
  /// device reports an invalid / non-finite value so the on-map overlay
  /// can always render a number instead of a dash.
  double _currentSpeedMps = 0.0;
  /// Compass heading from the GPS stream, degrees clockwise from true
  /// north. Drives the rotation of the bus arrow marker so it always
  /// points along the street the bus is travelling on. Null until the
  /// device has a valid heading (stationary devices report -1 / NaN).
  double? _currentHeadingDeg;
  /// Anchor used to sort the visit order of the active stops. Locked to
  /// the device's FIRST GPS fix on entering the screen so the order
  /// matches "from where the assistant / driver is standing when the
  /// trip starts" — and stays stable as the bus moves through the
  /// trip rather than re-shuffling every poll.
  LatLng? _orderAnchor;
  StreamSubscription<Position>? _posSub;
  /// Total driving duration for the active route, in seconds, as reported
  /// by OSRM. Null until the first successful fetch.
  double? _routeDurationSec;
  /// Monotonically-increasing sequence number for in-flight OSRM fetches.
  /// Every `_fetchRoute` call grabs the next value; only the latest call
  /// is allowed to mutate state on completion. Older calls (already
  /// superseded — e.g. initState's bus-less fetch raced by the first
  /// GPS-fix fetch with bus) are discarded silently so the polyline
  /// doesn't flicker between two stale geometries.
  int _fetchSeq = 0;
  /// While true, every new GPS fix recenters the map on the driver at
  /// [_followZoom]. Toggled off when the driver manually pans / zooms;
  /// the recenter button turns it back on.
  bool _followBus = true;

  /// Zoom level used when the map is in follow-cam mode. Tight enough that
  /// the bus and the surrounding streets are clearly visible, but not so
  /// tight that the driver loses context of upcoming turns.
  static const double _followZoom = 17.0;

  /// Distance threshold (metres) used to decide whether the bus is still
  /// on the cached polyline. Beyond this the route is re-fetched from
  /// the new bus position; below it we keep the existing line. Set wide
  /// enough to absorb GPS jitter and lane-level wander.
  static const double _offRouteMeters = 80.0;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    _startLocationStream();
  }

  /// Center the camera on the bus at the follow zoom. Posted to
  /// post-frame so we don't compete with a build that's in-flight for
  /// the same setState (e.g. the GPS-stream listener).
  void _centerOnBus(LatLng fix) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _map.move(fix, _followZoom);
    });
  }

  /// Re-engage follow mode and snap to the bus immediately. Bound to the
  /// recenter button at the right-edge of the map.
  void _recenterOnBus() {
    final fix = _currentPos;
    if (fix == null) return;
    setState(() => _followBus = true);
    _centerOnBus(fix);
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
        final fix = LatLng(p.latitude, p.longitude);
        final speedMps = p.speed.isFinite && p.speed >= 0 ? p.speed : 0.0;
        // Geolocator reports heading in degrees [0, 360) when valid; -1
        // or NaN when the device is stationary or the heading sensor
        // hasn't locked. Keep the last good heading in that case so the
        // arrow doesn't flicker back to north every time the bus stops.
        final hadingValid = p.heading.isFinite && p.heading >= 0;
        setState(() {
          _currentPos = fix;
          _currentSpeedMps = speedMps;
          if (hadingValid) _currentHeadingDeg = p.heading;
          // First GPS fix locks the route-ordering anchor — students
          // are visited in nearest-neighbour order starting from this
          // position. Both the assistant and the driver, who are on
          // the same bus, will anchor on very nearly the same point
          // and see the same visit order in their bottom-sheet grids.
          _orderAnchor ??= fix;
        });
        // Only refetch the polyline when the bus has actually left the
        // cached route — otherwise the line flickers/redirects on every
        // GPS update even though the driver is still on the same path.
        // Threshold is generous (~80 m) to absorb GPS jitter and brief
        // lane wanders without triggering a redraw.
        if (_route.length < 2 ||
            _minMetersToPolyline(fix, _route) > _offRouteMeters) {
          _fetchRoute();
        }
        // Follow-cam: keep the bus dead-center at a tight zoom on every
        // update so the driver always sees the road right under them.
        // Skipped when the user has actively interacted (panned/zoomed)
        // since the last fix so we don't fight their gestures.
        if (_followBus) _centerOnBus(fix);
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

  /// The full stops list re-ordered by greedy nearest-neighbour starting
  /// from [_orderAnchor]. School (if present) stays at the end of the
  /// chain for Morning trips, matching the original _buildStops logic.
  /// Falls back to the widget's incoming order until the first GPS fix
  /// has set the anchor.
  List<_Stop> get _orderedStops {
    final anchor = _orderAnchor;
    if (anchor == null) return widget.stops;
    final school =
        widget.stops.where((s) => s.kind == _StopKind.school).toList();
    final homes =
        widget.stops.where((s) => s.kind == _StopKind.home).toList();
    if (homes.isEmpty) return widget.stops;
    final result = <_Stop>[];
    final remaining = [...homes];
    var cursor = anchor;
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => _sqDist(a.point, cursor)
          .compareTo(_sqDist(b.point, cursor)));
      result.add(remaining.removeAt(0));
      cursor = result.last.point;
    }
    return [...result, ...school];
  }

  /// Stops the bus still needs to drive to. We drop:
  ///   • Boarded students (Morning) — already on the bus.
  ///   • Dropped students (Return)  — already arrived home.
  /// The school stays in either list since it's still a destination on
  /// Morning trips and the origin for Return.
  List<_Stop> get _activeStops =>
      _orderedStops.where((s) => !s.boarded && !s.dropped).toList();

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

  /// Hits the self-hosted OSRM (same domain as the API) to retrieve a real
  /// driving polyline across the ordered stops. On any failure we silently
  /// fall back to straight lines between stops so the screen still renders.
  ///
  /// We always prepend the driver's current GPS position to the waypoint
  /// list when it's known. That gives two useful behaviours:
  ///   - Early in a Morning trip the route is drawn from the bus to the
  ///     first pickup, so the driver sees the leg they're about to drive.
  ///   - Once every student has boarded, `_activeStops` collapses to just
  ///     `[school]` — without the bus position we'd have a 1-point route
  ///     and nothing rendered. With it we get a clean current→school leg.
  Future<void> _fetchRoute() async {
    if (!mounted) return;
    // Claim the latest sequence number; if a newer fetch starts while
    // we're still in flight, [seq != _fetchSeq] below will tell us to
    // discard our result instead of overwriting the newer polyline.
    final seq = ++_fetchSeq;
    final active = _activeStops;
    final waypoints = <LatLng>[
      ?_currentPos,
      ...active.map((s) => s.point),
    ];
    if (waypoints.length < 2) {
      if (seq != _fetchSeq) return;
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
    final coords = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    // alternatives=3 asks OSRM for up to three viable routes; we pick
    // the one with the smallest `distance` so the driver gets the
    // SHORTEST path (metres) after re-routing off-route, rather than
    // the default route which optimises for duration. Especially
    // important on detours where the fastest option might take the
    // bus a few kilometres around to skip a small congestion zone.
    final uri = Uri.parse(
      '${Env.osrmBaseUrl}/route/v1/driving/$coords'
      '?overview=full&geometries=geojson&alternatives=3',
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
      final first = _shortestRoute(routes);
      final geometry = first['geometry'] as Map<String, dynamic>;
      final raw = geometry['coordinates'] as List<dynamic>;
      final pts = raw
          .map((c) => (c as List<dynamic>))
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
      // OSRM snaps each waypoint to the nearest road, so the geometry's
      // endpoints sit on the street — typically 10-30 m from a home pin
      // inside a compound. Replace the closest geometry vertex of every
      // waypoint with the pin's actual coordinate so the visible line
      // touches the home / school marker instead of stopping short.
      if (pts.length >= 2) {
        for (final wp in waypoints) {
          var bestIdx = 0;
          var bestDistSq = double.infinity;
          final kx = math.cos(wp.latitude * math.pi / 180.0);
          for (var i = 0; i < pts.length; i++) {
            final dLat = pts[i].latitude - wp.latitude;
            final dLng = (pts[i].longitude - wp.longitude) * kx;
            final d = dLat * dLat + dLng * dLng;
            if (d < bestDistSq) {
              bestDistSq = d;
              bestIdx = i;
            }
          }
          pts[bestIdx] = wp;
        }
      }
      // OSRM returns the total drive time in seconds at routes[0].duration.
      // We display it as the ETA pill on the map header.
      final duration = (first['duration'] as num?)?.toDouble();
      if (!mounted || seq != _fetchSeq) return;
      setState(() {
        _route = pts;
        _loading = false;
        _error = null;
        _routeDurationSec = duration;
      });
      _fitBounds();
    } catch (_) {
      if (!mounted || seq != _fetchSeq) return;
      setState(() {
        _route = active.map((s) => s.point).toList();
        _loading = false;
        _error = widget.l.driverRouteFallback;
        _routeDurationSec = null;
      });
      _fitBounds();
    }
  }

  /// Fit the full route polyline into view. Used once at startup so the
  /// driver gets a sense of the whole leg before the first GPS fix kicks
  /// the camera into follow-cam mode. Skipped after a fix arrives —
  /// re-fetches of the route would otherwise yank the camera back to a
  /// wide view every time the assistant marked a student boarded.
  void _fitBounds() {
    if (_route.length < 2) return;
    if (_currentPos != null) return;
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
              // Rotation enabled so the driver can swivel the map to
              // match the heading of the bus / road they're on — easier
              // to read at a glance than a fixed-north view.
              flags: InteractiveFlag.all,
            ),
            // Any user-driven pan / zoom disengages follow mode so we
            // don't yank the map back as soon as the driver tries to
            // peek ahead. The recenter button re-engages it.
            onPositionChanged: (pos, hasGesture) {
              if (hasGesture && _followBus) {
                setState(() => _followBus = false);
              }
            },
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
                    color: AppColors.blue,
                    strokeWidth: 5,
                    borderStrokeWidth: 1.0,
                    borderColor: Colors.white,
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
                    // Next pin uses a wider/taller marker to fit the
                    // enlarged disc + glow without clipping at the edges.
                    width: i == 0 ? 56 : 44,
                    height: i == 0 ? 68 : 56,
                    alignment: Alignment.topCenter,
                    child: _PinMarker(
                      stop: _activeStops[i],
                      // Highlight the bus's next stop so the driver can
                      // pick it out at a glance — first item in the
                      // active list is whoever they're driving to right
                      // now. School and dropped stops keep their default
                      // appearance.
                      isNext: i == 0 &&
                          _activeStops[i].kind != _StopKind.school &&
                          !_activeStops[i].dropped,
                    ),
                  ),
                if (_currentPos != null)
                  Marker(
                    point: _currentPos!,
                    width: 44,
                    height: 44,
                    child: _BusHeadingArrow(
                      headingDeg: _currentHeadingDeg,
                    ),
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
                      stops: _orderedStops,
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
            // Render the GPS-anchored order so the row sequence matches
            // the pin order on the map and the route line above.
            stops: _orderedStops,
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

        // Emergency call: tap dials the school's main phone number
        // (fetched live from `myFleetSchoolProvider`). Disabled / hidden
        // when no phone is on file. Sits above the recenter button so
        // both fit comfortably above the bottom stops sheet.
        const Positioned(
          right: 14,
          bottom: 270,
          child: _EmergencyCallBtn(),
        ),

        // Recenter button: shows only once we have a GPS fix to snap to.
        // Highlighted while follow mode is engaged so the driver knows
        // the camera is locked to them; pressing it after a manual pan
        // re-engages follow + jumps to the bus.
        if (_currentPos != null)
          Positioned(
            right: 14,
            bottom: 220,
            child: _RecenterBtn(
              active: _followBus,
              onTap: _recenterOnBus,
            ),
          ),

        // Speed + ETA overlay. Anchored bottom-left, above the stops
        // sheet, so the driver can glance at remaining time and current
        // speed without looking away from the road shown on the map.
        if (_currentPos != null)
          Positioned(
            left: 14,
            bottom: 220,
            child: _MapStatsCard(
              speedKmh: (_currentSpeedMps * 3.6).round(),
              durationSec: _routeDurationSec,
            ),
          ),
      ],
    );
  }
}

/// Compact on-map card showing the bus's current speed (km/h) and the
/// remaining drive time to the active destination. Renders flush over
/// the map tiles so the driver gets the numbers without taking eyes off
/// the road geometry beneath.
class _MapStatsCard extends StatelessWidget {
  const _MapStatsCard({required this.speedKmh, required this.durationSec});
  final int speedKmh;
  final double? durationSec;

  @override
  Widget build(BuildContext context) {
    final etaText = durationSec == null
        ? '—'
        : '${(durationSec! / 60).ceil().clamp(1, 999)} min';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, size: 14, color: AppColors.violet),
          const SizedBox(width: 5),
          Text(
            '$speedKmh',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            'km/h',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.slate200,
          ),
          const Icon(Icons.schedule_outlined,
              size: 14, color: AppColors.yellowDeep),
          const SizedBox(width: 5),
          Text(
            etaText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating "snap-to-bus" button. Renders with a tinted highlight while
/// follow-cam is engaged so the driver can tell whether tapping it would
/// change anything (it's still tappable to re-snap after a small drift).
class _RecenterBtn extends StatelessWidget {
  const _RecenterBtn({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.blue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? AppColors.blue : AppColors.slate200,
        ),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.my_location,
            size: 19,
            color: active ? Colors.white : AppColors.slate700,
          ),
        ),
      ),
    );
  }
}

/// Floating red "call school" button. Reads the school's phone number
/// from [myFleetSchoolProvider] and dials it via the OS's tel: URL
/// scheme. Renders disabled (grey, non-tappable) when no phone is on
/// file so the driver gets a visible cue that the number is missing
/// rather than the call quietly no-op'ing.
class _EmergencyCallBtn extends ConsumerWidget {
  const _EmergencyCallBtn();

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(myFleetSchoolProvider).valueOrNull?.phoneNumber;
    final enabled = phone != null && phone.isNotEmpty;
    return Material(
      color: enabled ? const Color(0xFFE11D48) : AppColors.slate200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: enabled ? const Color(0xFFE11D48) : AppColors.slate300,
        ),
      ),
      shadowColor: enabled
          ? const Color(0xFFE11D48).withValues(alpha: 0.45)
          : Colors.black.withValues(alpha: 0.12),
      elevation: enabled ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? () => _call(phone) : null,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.emergency_share_rounded,
            size: 19,
            color: Colors.white,
          ),
        ),
      ),
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
              // ETA used to live here as a pill, but the remaining time
              // is now rendered on the map itself via [_MapStatsCard] so
              // the top banner stays purely about trip identity + stop
              // count + boarding progress.
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
              // "Route order" title was removed — the drag handle above
              // already signals this is the stops list, and each row is
              // labelled with its visit-order number so the section
              // header was redundant.
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
                        // Highlight the bus's next stop — first row when
                        // it's actually upcoming. If every stop has been
                        // handled the list reverts to default styling.
                        isNext: i == 0 && upcoming(ordered[0]),
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
    this.isNext = false,
  });
  final int step;
  final _Stop stop;
  /// Distance to render in the right-edge pill. When [isLive] is true this
  /// is the bus → stop distance and updates as the driver moves; otherwise
  /// it's the static previous → stop leg.
  final double? legKm;
  final bool isMorning;
  final bool isLive;
  /// True for the bus's upcoming destination (first row in the list when
  /// it hasn't been handled yet). Renders with a yellow-tinted background,
  /// thicker yellow border, and a small soft glow so the driver can spot
  /// "where I'm headed right now" at a glance.
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final isSchool = stop.kind == _StopKind.school;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.yellowTint
            : (isSchool ? AppColors.blueSoft : AppColors.slate50),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isNext
              ? AppColors.yellowDeep
              : (isSchool
                  ? AppColors.blue.withValues(alpha: 0.3)
                  : AppColors.slate100),
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Next row's step badge flips to yellow so the leading
              // edge of the row matches the row-level highlight.
              color: isNext
                  ? AppColors.yellowDeep
                  : (isSchool ? AppColors.blue : AppColors.ink),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isNext
                ? const Icon(Icons.navigation_rounded,
                    size: 14, color: Colors.white)
                : Text(
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

/// Returns the OSRM route with the smallest `distance` (metres). Routes
/// missing a numeric distance are skipped; if none has one we fall back
/// to the first route in the array so the screen still renders.
Map<String, dynamic> _shortestRoute(List<dynamic> routes) {
  Map<String, dynamic>? best;
  double bestMeters = double.infinity;
  for (final r in routes) {
    if (r is! Map<String, dynamic>) continue;
    final d = (r['distance'] as num?)?.toDouble();
    if (d == null) continue;
    if (d < bestMeters) {
      bestMeters = d;
      best = r;
    }
  }
  return best ?? routes.first as Map<String, dynamic>;
}

/// Minimum distance in metres from [p] to any segment of [line].
/// Returns infinity when the polyline is too short to project onto.
/// Uses a local equirectangular frame (longitudes pre-scaled by
/// cos(lat)) so the projection is accurate at mid-latitudes.
double _minMetersToPolyline(LatLng p, List<LatLng> line) {
  if (line.length < 2) return double.infinity;
  final kx = math.cos(p.latitude * math.pi / 180.0);
  // ~ metres per degree at this latitude. Scaling lat/lon deltas by these
  // factors gives a Euclidean distance in metres that closely tracks
  // haversine for short distances we care about (well under a kilometre).
  const metersPerDegLat = 111320.0;
  final metersPerDegLon = metersPerDegLat * kx;
  double best = double.infinity;
  for (var i = 0; i < line.length - 1; i++) {
    final a = line[i];
    final b = line[i + 1];
    // Project p onto segment a→b in metric space.
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

class _PinMarker extends StatelessWidget {
  const _PinMarker({required this.stop, this.isNext = false});
  final _Stop stop;
  /// True for the upcoming student pin — the bus's next stop. Renders
  /// larger with a yellow halo so the driver picks it out at a glance.
  final bool isNext;

  /// Student pins match the bus marker's disc size (24 px) so all map
  /// icons read at the same visual weight. The "next" pin scales up to
  /// 36 px with a halo for emphasis without ballooning past the bus.
  static const double _studentDisc = 24.0;
  static const double _nextDisc = 36.0;

  @override
  Widget build(BuildContext context) {
    final isSchool = stop.kind == _StopKind.school;
    // Student pins are now blue (same family as the route polyline and
    // the parent live-map's bus theming) instead of the previous yellow
    // — keeps the map palette consistent: yellow for the BUS, blue for
    // students, emerald for "done", and the school stays blue too with
    // the school icon to disambiguate.
    final fill = stop.dropped
        ? AppColors.emerald
        : AppColors.blue;
    final discSize = isNext ? _nextDisc : _studentDisc;
    final iconSize = isNext ? 20.0 : 14.0;
    final IconData glyph = stop.dropped
        ? Icons.check_rounded
        : (isSchool ? Icons.school_rounded : Icons.person_rounded);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Halo only renders for the next pin — soft yellow glow so
            // it pops against the blue disc.
            if (isNext)
              Container(
                width: discSize + 14,
                height: discSize + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.yellow.withValues(alpha: 0.30),
                ),
              ),
            Container(
              width: discSize,
              height: discSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isNext ? 3 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isNext
                        ? AppColors.yellow.withValues(alpha: 0.45)
                        : const Color(0x40000000),
                    blurRadius: isNext ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(glyph, size: iconSize, color: Colors.white),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: CustomPaint(
            size: Size(isNext ? 12 : 10, isNext ? 8 : 6),
            painter: _PinTipPainter(color: fill),
          ),
        ),
      ],
    );
  }
}

/// Yellow heading-arrow marker at the bus's current GPS position. The
/// arrow rotates to match [headingDeg] (degrees clockwise from north),
/// so it visually points along the street the bus is travelling on.
/// Falls back to a static yellow disc when no heading is available yet
/// (stationary device, heading sensor not locked).
class _BusHeadingArrow extends StatelessWidget {
  const _BusHeadingArrow({required this.headingDeg});
  final double? headingDeg;

  @override
  Widget build(BuildContext context) {
    // Translucent halo + arrow disc + bus glyph. The Transform.rotate
    // wraps only the arrow disc so the halo stays a round glow even
    // when the bus is heading sideways.
    final hasHeading = headingDeg != null;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft halo for visual weight against busy map tiles.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.yellow.withValues(alpha: 0.30),
          ),
        ),
        // Arrow + disc, rotated to the bus heading.
        Transform.rotate(
          angle: hasHeading ? headingDeg! * math.pi / 180.0 : 0,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (hasHeading)
                  Positioned(
                    top: -3,
                    child: CustomPaint(
                      size: const Size(14, 10),
                      painter: _ArrowHeadPainter(color: AppColors.yellowDeep),
                    ),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.yellow, AppColors.yellowDeep],
                    ),
                    border: Border.all(color: Colors.white, width: 2.5),
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
            ),
          ),
        ),
        // Bus glyph stays upright regardless of heading — only the
        // arrow + disc rotate, so the icon remains readable while the
        // arrowhead does the directional work.
        const Icon(
          Icons.directions_bus,
          size: 14,
          color: AppColors.ink,
        ),
      ],
    );
  }
}

/// Painter for the small triangular arrowhead that sits above the bus
/// disc and indicates heading. Stroked with [color] (typically yellowDeep)
/// and rendered with a soft outline so it stays visible over both light
/// and dark tile content.
class _ArrowHeadPainter extends CustomPainter {
  _ArrowHeadPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = ui.Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(p, outline);
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowHeadPainter oldDelegate) =>
      oldDelegate.color != color;
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

