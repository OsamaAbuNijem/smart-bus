import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'package:smart_bus/core/config/env.dart';
import 'package:smart_bus/core/storage/secure_storage.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/parent/data/repositories/parent_repository.dart';
import 'package:smart_bus/features/parent/domain/entities/live_tracking.dart';

part 'live_tracking_controller.g.dart';

/// Initial snapshot loaded over HTTP. SignalR updates the bus location in
/// place via [LiveTrackingController.applyLocation].
@riverpod
class LiveTrackingController extends _$LiveTrackingController {
  HubConnection? _hub;
  String? _busGroup;
  Timer? _pollTimer;

  @override
  Future<LiveTracking> build(String studentId) async {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) {
      throw StateError('Not logged in');
    }
    final repo = ref.watch(parentRepositoryProvider);
    final snapshot = await repo.getLiveTracking(
      parentId: user.entityId,
      studentId: studentId,
    );

    ref.onDispose(_disposeHub);
    ref.onDispose(_stopPolling);
    // SignalR is disabled for now: the IIS-hosted hub returns 500 on the
    // long-polling/negotiate path and the reconnect spam blows the API's
    // global 60/min rate limit. Polling /live every few seconds is reliable
    // and keeps the map moving. Re-enable _connect once the hub is healthy.
    _startPolling();

    return snapshot;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollOnce());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollOnce() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    final current = state.valueOrNull;
    if (user == null || current == null) return;
    try {
      final repo = ref.read(parentRepositoryProvider);
      final fresh = await repo.getLiveTracking(
        parentId: user.entityId,
        studentId: studentId,
      );
      // Silently update — no loading flash.
      state = AsyncValue.data(fresh);
    } catch (_) {/* keep last known state */}
  }

  /// Apply a fresh bus location to the in-memory snapshot.
  void applyLocation({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    required DateTime timestamp,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        busLocation: BusLocation(
          latitude: latitude,
          longitude: longitude,
          speed: speed,
          heading: heading,
          timestamp: timestamp,
        ),
      ),
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(parentRepositoryProvider);
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => repo.getLiveTracking(
          parentId: user.entityId,
          studentId: studentId,
        ));
    state = result;
  }

  Future<void> _connect(String busId) async {
    try {
      final token =
          await ref.read(secureStorageProvider).readAccessToken();
      final url = '${Env.apiBaseUrl}/hubs/bus-tracking';

      // ignore: avoid_print
      print('[SignalR] connecting to $url (token=${token == null ? "null" : "present"})');

      final hub = HubConnectionBuilder()
          .withUrl(
            url,
            options: HttpConnectionOptions(
              accessTokenFactory: token == null ? null : () async => token,
              transport: HttpTransportType.LongPolling,
              logMessageContent: true,
            ),
          )
          .build();

      hub.on('BusLocationUpdated', _onBusLocationUpdated);
      hub.on('Connected', (args) {
        // ignore: avoid_print
        print('[SignalR] server says Connected: $args');
      });
      hub.onclose(({Exception? error}) {
        // ignore: avoid_print
        print('[SignalR] closed: $error');
      });
      hub.onreconnecting(({Exception? error}) {
        // ignore: avoid_print
        print('[SignalR] reconnecting: $error');
      });
      hub.onreconnected(({String? connectionId}) {
        // ignore: avoid_print
        print('[SignalR] reconnected: $connectionId');
      });

      await hub.start();
      // ignore: avoid_print
      print('[SignalR] connected, joining bus-$busId');

      _hub = hub;
      _busGroup = busId;

      // Small breathing room before the invoke — some servers reject
      // immediate group operations during the connection-establish phase.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await hub.invoke('JoinBusGroup', args: <Object>[busId]);
      // ignore: avoid_print
      print('[SignalR] joined bus-$busId');
    } catch (e, st) {
      // ignore: avoid_print
      print('[SignalR] connect failed: $e\n$st');
    }
  }

  void _onBusLocationUpdated(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final raw = args.first;
    if (raw is! Map) return;
    final lat = (raw['latitude'] ?? raw['Latitude']) as num?;
    final lng = (raw['longitude'] ?? raw['Longitude']) as num?;
    if (lat == null || lng == null) return;
    final speed = (raw['speed'] ?? raw['Speed']) as num?;
    final heading = (raw['heading'] ?? raw['Heading']) as num?;
    final ts = raw['timestamp'] ?? raw['Timestamp'];
    final timestamp = ts is String
        ? DateTime.tryParse(ts) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();
    applyLocation(
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      speed: speed?.toDouble(),
      heading: heading?.toDouble(),
      timestamp: timestamp,
    );
  }

  Future<void> _disposeHub() async {
    final hub = _hub;
    final group = _busGroup;
    _hub = null;
    _busGroup = null;
    if (hub == null) return;
    try {
      if (group != null) {
        await hub.invoke('LeaveBusGroup', args: <Object>[group]);
      }
    } catch (_) {/* ignore */}
    try {
      await hub.stop();
    } catch (_) {/* ignore */}
  }
}
