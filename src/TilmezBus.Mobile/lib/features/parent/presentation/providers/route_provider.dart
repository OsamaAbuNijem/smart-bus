import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/config/env.dart';

part 'route_provider.g.dart';

/// Fetches a driving route between two points from the OSRM public demo.
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
  final url =
      '${Env.osrmBaseUrl}/route/v1/driving/'
      '$fromLng,$fromLat;$toLng,$toLat'
      '?overview=full&geometries=geojson';
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));
  final resp = await dio.get<Map<String, dynamic>>(url);
  final routes = (resp.data?['routes'] as List?) ?? const [];
  if (routes.isEmpty) return const [];
  final coords =
      (routes.first['geometry']?['coordinates'] as List?) ?? const [];
  return coords
      .map((c) => LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          ))
      .toList(growable: false);
}

extension RoundForRouteCache on double {
  double get roundForRoute => (this * 1000).round() / 1000;
}
