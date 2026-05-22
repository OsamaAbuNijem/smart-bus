import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/config/env.dart';

part 'route_provider.g.dart';

/// Fetches a driving route between two points from the self-hosted OSRM.
/// The result is a list of LatLng forming a polyline that follows streets.
///
/// We snap each input coordinate to ~111m grid (3 decimal places) so small
/// bus movements reuse the cached route instead of refetching every poll.
@Riverpod(keepAlive: true)
Future<List<LatLng>> routedPath(
  Ref ref, {
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) async {
  return _fetchOsrmGeometry([
    LatLng(fromLat, fromLng),
    LatLng(toLat, toLng),
  ]);
}

/// Multi-waypoint variant: fetches a street-following polyline through
/// every point in [waypoints], in order. Used by the parent live-tracking
/// map to draw bus → home → school (morning) or bus → home (return) as
/// one continuous route, matching the driver-map look. Coordinates are
/// snapped to ~111m grid so the keepAlive cache hits across bus jitter.
@Riverpod(keepAlive: true)
Future<List<LatLng>> routedPathThrough(
  Ref ref, {
  required String waypointsKey,
}) async {
  final pts = waypointsKey
      .split(';')
      .map((pair) {
        final xy = pair.split(',');
        return LatLng(double.parse(xy[1]), double.parse(xy[0]));
      })
      .toList(growable: false);
  if (pts.length < 2) return const [];
  return _fetchOsrmGeometry(pts);
}

/// Builds the snapped `lng,lat;lng,lat;…` string used as the cache key for
/// [routedPathThrough]. 4-decimal snap ≈ 11 m grid so meaningful bus
/// movements (>~25 m geolocator distance filter) reliably trigger a fresh
/// OSRM fetch and the parent map redraws the street-following polyline
/// after each update, while small jitters still hit the keepAlive cache.
String waypointsCacheKey(Iterable<LatLng> points) => points
    .map((p) =>
        '${(p.longitude * 10000).round() / 10000},${(p.latitude * 10000).round() / 10000}')
    .join(';');

Future<List<LatLng>> _fetchOsrmGeometry(List<LatLng> points) async {
  final coords = points
      .map((p) => '${p.longitude},${p.latitude}')
      .join(';');
  // alternatives=3 asks OSRM for up to three viable routes between the
  // waypoints; we then pick the one with the smallest `distance` so the
  // parent always sees the SHORTEST path (by metres travelled) rather
  // than the default which optimises for duration. Falls back to the
  // first route silently if the server doesn't honour alternatives.
  final url =
      '${Env.osrmBaseUrl}/route/v1/driving/$coords'
      '?overview=full&geometries=geojson&alternatives=3';
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));
  final resp = await dio.get<Map<String, dynamic>>(url);
  final routes = (resp.data?['routes'] as List?) ?? const [];
  if (routes.isEmpty) return const [];
  final shortest = _shortestByDistance(routes);
  final raw =
      (shortest['geometry']?['coordinates'] as List?) ?? const [];
  return raw
      .map((c) => LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          ))
      .toList(growable: false);
}

/// Returns the OSRM route with the smallest `distance` (metres). Routes
/// missing a numeric distance are skipped; if none has one we just
/// return the first route the server gave us.
Map<String, dynamic> _shortestByDistance(List<dynamic> routes) {
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

extension RoundForRouteCache on double {
  double get roundForRoute => (this * 1000).round() / 1000;
}
