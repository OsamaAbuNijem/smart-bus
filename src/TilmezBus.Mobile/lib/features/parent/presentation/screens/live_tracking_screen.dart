import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/parent/domain/entities/live_tracking.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/live_tracking_controller.dart';
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

  void _recenter() {
    final bus = _displayBusLatLng;
    final dest = _destinationLatLng;
    if (bus != null && dest != null) {
      final bounds = LatLngBounds.fromPoints([bus, dest]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    } else if (bus != null) {
      _mapController.move(bus, 15);
    } else if (dest != null) {
      _mapController.move(dest, 14);
    }
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

    return Column(
      children: [
        _Hero(data: data, l: l),
        Expanded(
          child: Stack(
            children: [
              _Map(
                controller: _mapController,
                bus: _displayBusLatLng,
                home: _homeLatLng,
                school: _schoolLatLng,
                destination: _destinationLatLng,
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
    final etaMinutes = _etaMinutes(data);
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
            if (etaMinutes != null) _EtaPill(minutes: etaMinutes),
          ],
        ),
      ),
    );
  }
}

class _EtaPill extends StatelessWidget {
  const _EtaPill({required this.minutes});
  final int minutes;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.yellowTint,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0x66F5C518)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus,
              size: 13, color: AppColors.yellowDeep),
          const SizedBox(width: 5),
          Text(
            '$minutes min',
            style: const TextStyle(
              color: AppColors.yellowDeep,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
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

class _Map extends ConsumerWidget {
  const _Map({
    required this.controller,
    required this.bus,
    required this.home,
    required this.school,
    required this.destination,
    required this.busLabel,
    required this.homeLabel,
    required this.schoolLabel,
  });
  final MapController controller;
  final LatLng? bus;
  final LatLng? home;
  final LatLng? school;
  // Active destination — school in morning trips, home in return trips.
  final LatLng? destination;
  final String? busLabel;
  final String homeLabel;
  final String schoolLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialCenter =
        bus ?? destination ?? home ?? school ?? const LatLng(31.95, 35.93);
    final initialZoom = bus != null && destination != null ? 13.0 : 14.0;

    // Fetch a street-following route between bus and the active destination
    // (school for morning, home for return). Snap to ~111m grid so small bus
    // movements reuse the cached path.
    List<LatLng> linePoints =
        (bus != null && destination != null) ? [bus!, destination!] : const [];
    if (bus != null && destination != null) {
      final routed = ref.watch(routedPathProvider(
        fromLat: bus!.latitude.roundForRoute,
        fromLng: bus!.longitude.roundForRoute,
        toLat: destination!.latitude.roundForRoute,
        toLng: destination!.longitude.roundForRoute,
      ));
      final routedList = routed.valueOrNull;
      if (routedList != null && routedList.length >= 2) {
        linePoints = routedList;
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
                strokeWidth: 4.0,
                color: AppColors.yellow,
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
            if (bus != null)
              Marker(
                point: bus!,
                width: 100,
                height: 80,
                alignment: Alignment.bottomCenter,
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final t = _ctrl.value;
            final size = 30 + 50 * t;
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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null)
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
                  widget.label!,
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
              width: 40,
              height: 40,
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
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.directions_bus,
                size: 18,
                color: AppColors.ink,
              ),
            ),
          ],
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

class _CrewCard extends StatelessWidget {
  const _CrewCard({required this.data, required this.l});
  final LiveTracking data;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (data.driverName != null && data.driverName!.isNotEmpty) {
      rows.add(_CrewRow(
        role: l.liveTrackingDriver,
        name: data.driverName!,
        phone: data.driverPhone,
        isDriver: true,
      ));
    }
    if (data.assistantName != null && data.assistantName!.isNotEmpty) {
      rows.add(_CrewRow(
        role: l.liveTrackingAssistant,
        name: data.assistantName!,
        phone: data.assistantPhone,
        isDriver: false,
      ));
    }
    if (rows.isEmpty) {
      rows.add(Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          l.liveTrackingNoCrew,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.slate500,
          ),
        ),
      ));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.slate100,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _CrewRow extends StatelessWidget {
  const _CrewRow({
    required this.role,
    required this.name,
    required this.phone,
    required this.isDriver,
  });
  final String role;
  final String name;
  final String? phone;
  final bool isDriver;

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
    final (gradient, fg) = isDriver
        ? (
            const LinearGradient(
              colors: [Color(0xFFDBEAFE), Color(0xFF93C5FD)],
            ),
            const Color(0xFF1E40AF),
          )
        : (
            const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFCD34D)],
            ),
            const Color(0xFF92400E),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.slate200,
                  blurRadius: 0,
                  spreadRadius: 1.5,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: fg,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null) ...[
            _CrewBtn(
              icon: Icons.message,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF34D399), Color(0xFF25D366)],
              ),
              foreground: Colors.white,
              shadow: const Color(0xFF25D366),
              onTap: _whatsapp,
            ),
            const SizedBox(width: 6),
            _CrewBtn(
              icon: Icons.call,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.yellow, AppColors.yellowDeep],
              ),
              foreground: AppColors.ink,
              shadow: AppColors.yellow,
              onTap: _call,
            ),
          ],
        ],
      ),
    );
  }
}

class _CrewBtn extends StatelessWidget {
  const _CrewBtn({
    required this.icon,
    required this.gradient,
    required this.foreground,
    required this.shadow,
    required this.onTap,
  });
  final IconData icon;
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: shadow.withValues(alpha: 0.55),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: Icon(icon, size: 14, color: foreground)),
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
