import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/network/dio_client.dart';

part 'trip_location_broadcaster.g.dart';

/// Broadcasts the assistant device's GPS to the API for a specific bus.
///
/// Started by any screen on which the assistant is actively driving a
/// trip (trip details, trip map) so the parent app sees the bus move in
/// real time. The provider is parameterised by busId so multiple
/// concurrent trips would each get their own broadcaster (in practice
/// only one assistant is in a trip at a time).
///
/// Behaviour:
///   • On start, fire `getCurrentPosition` immediately so the parent
///     gets a fresh fix without waiting for the stream's first emission.
///   • Subscribe to the geolocator stream with a 25 m distance filter —
///     each emission is broadcast.
///   • Heartbeat every 15 s — re-broadcasts a fresh position so the
///     parent's marker timestamp keeps ticking even when the bus is
///     parked.
///
/// Errors from the geolocator or the HTTP POST are swallowed by design;
/// a flaky network shouldn't disrupt the assistant's local UI.
@Riverpod(keepAlive: false)
class TripLocationBroadcaster extends _$TripLocationBroadcaster {
  StreamSubscription<Position>? _posSub;
  Timer? _heartbeat;
  Position? _lastFix;

  @override
  void build(String busId) {
    _start(busId);
    ref.onDispose(_stop);
  }

  Future<void> _start(String busId) async {
    if (!await _ensurePermission()) return;

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen((p) {
      _lastFix = p;
      _broadcast(busId, p);
    });

    // Immediate first ping + 15 s heartbeat thereafter.
    unawaited(_broadcastNow(busId));
    _heartbeat = Timer.periodic(
        const Duration(seconds: 15), (_) => _broadcastNow(busId));
  }

  Future<bool> _ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      return perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever;
    } catch (_) {
      return false;
    }
  }

  void _stop() {
    _heartbeat?.cancel();
    _posSub?.cancel();
  }

  Future<void> _broadcastNow(String busId) async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastFix = p;
      await _broadcast(busId, p);
    } catch (_) {
      final fix = _lastFix;
      if (fix != null) await _broadcast(busId, fix);
    }
  }

  Future<void> _broadcast(String busId, Position p) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post<void>(
        '/buses/$busId/location',
        data: {
          'latitude': p.latitude,
          'longitude': p.longitude,
          'speed':   p.speed.isFinite   ? p.speed   : null,
          'heading': p.heading.isFinite ? p.heading : null,
        },
      );
      if (kDebugMode) {
        // ignore: avoid_print
        print('[bus-loc] posted ${p.latitude},${p.longitude}');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[bus-loc] POST failed: $e');
      }
    }
  }
}
