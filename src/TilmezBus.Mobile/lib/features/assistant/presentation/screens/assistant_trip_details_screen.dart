import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_details_dto.dart';
import 'package:tilmez_bus/features/assistant/data/services/trip_location_broadcaster.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

class AssistantTripDetailsScreen extends ConsumerWidget {
  const AssistantTripDetailsScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detailsAsync = ref.watch(tripDetailsProvider(tripId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is Failure ? e.message : '$e',
          onRetry: () => ref.invalidate(tripDetailsProvider(tripId)),
        ),
        data: (details) => _TripBody(details: details, l: l),
      ),
    );
  }
}

class _TripBody extends ConsumerStatefulWidget {
  const _TripBody({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  ConsumerState<_TripBody> createState() => _TripBodyState();
}

class _TripBodyState extends ConsumerState<_TripBody> {
  /// First GPS fix observed on this screen. The sorted student order is
  /// computed greedy-nearest-neighbour from this point — locked so the
  /// list doesn't reshuffle every time the bus moves a few metres.
  /// Mirrors the driver map's `_orderAnchor`, so both screens converge
  /// on the same visit order when running on the same bus.
  LatLng? _orderAnchor;
  StreamSubscription<Position>? _posSub;

  @override
  void initState() {
    super.initState();
    _startAnchorStream();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  /// Tap a GPS fix to anchor the sort order. Permission was already
  /// granted by `tripLocationBroadcasterProvider`; we just listen
  /// passively to the OS stream. Once the anchor is locked we cancel
  /// the subscription — re-sorting on every fix would defeat the
  /// purpose of the anchor.
  Future<void> _startAnchorStream() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final perm = await Geolocator.checkPermission();
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
        if (!mounted || _orderAnchor != null) return;
        setState(() => _orderAnchor = LatLng(p.latitude, p.longitude));
        unawaited(_posSub?.cancel());
        _posSub = null;
      });
    } catch (_) {
      // Silent — list just stays in original order.
    }
  }

  /// Students sorted by greedy nearest-neighbour from [_orderAnchor].
  /// Falls back to the API's original order until the first GPS fix
  /// has set the anchor. Same algorithm as
  /// `_RoutedMapState._orderedStops` on the driver map, so the two
  /// screens render the same student sequence on a shared bus.
  List<TripStudentDetailDto> _sortedStudents() {
    final all = widget.details.students;
    final anchor = _orderAnchor;
    if (anchor == null || all.isEmpty) return all;
    // Students with coordinates participate in the NN sort; those
    // without keep relative order and are appended at the end so they
    // don't get lost.
    final locatable = <TripStudentDetailDto>[];
    final unlocatable = <TripStudentDetailDto>[];
    for (final s in all) {
      if (s.latitude != null && s.longitude != null) {
        locatable.add(s);
      } else {
        unlocatable.add(s);
      }
    }
    if (locatable.isEmpty) return all;
    final ordered = <TripStudentDetailDto>[];
    final remaining = [...locatable];
    var cursor = anchor;
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = _sqDist(LatLng(a.latitude!, a.longitude!), cursor);
        final db = _sqDist(LatLng(b.latitude!, b.longitude!), cursor);
        return da.compareTo(db);
      });
      final next = remaining.removeAt(0);
      ordered.add(next);
      cursor = LatLng(next.latitude!, next.longitude!);
    }
    return [...ordered, ...unlocatable];
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final l = widget.l;
    final groups = _groupByArea(_sortedStudents());
    final completed = details.status == 'Completed';
    final scheduled = details.status == 'Scheduled';
    // Scan + boarding actions only make sense once the trip is live. The
    // existing `readOnly` gate covered the post-completion case; we widen
    // it to cover the pre-start (Scheduled) case too.
    final readOnly = completed || scheduled;

    // Start broadcasting the bus's GPS to the API for as long as this
    // screen is mounted with an in-progress trip. The parent app reads
    // these pings via /live so the bus marker moves in real time.
    // The provider auto-disposes on screen exit, stopping the broadcast.
    if (!completed) {
      ref.watch(tripLocationBroadcasterProvider(details.busId));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(details: details, l: l),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(tripDetailsProvider(details.tripId)),
            color: AppColors.yellowDeep,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              children: [
                if (!readOnly) ...[
                  () {
                    // SuperAdmin-controlled feature flags from the
                    // school's active subscription. Hide QR / NFC entry
                    // points entirely when disabled. Default both to
                    // true while the call is in-flight so we don't
                    // briefly flash an empty bar on every screen entry.
                    final fleet = ref.watch(myFleetSchoolProvider).valueOrNull;
                    final showQr  = fleet?.enableQr  ?? true;
                    final showNfc = fleet?.enableNfc ?? true;
                    return _ScanActionRow(
                      onQr: () => _onScanQr(context, ref),
                      onNfc: () => _onNfcTap(context),
                      showQr: showQr,
                      showNfc: showNfc,
                      l: l,
                    );
                  }(),
                  const SizedBox(height: 14),
                ],
                _SectionHeader(l: l),
                const SizedBox(height: 10),
                for (final entry in groups.entries) ...[
                  _StopGroup(
                    stopNumber: groups.keys.toList().indexOf(entry.key) + 1,
                    stopName: entry.key,
                    students: entry.value,
                    tripId: details.tripId,
                    isMorning: details.isMorning,
                    readOnly: readOnly,
                    scheduled: scheduled,
                    l: l,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        if (completed)
          _CompletedSummaryBar(details: details, l: l)
        else if (scheduled)
          _StartScheduledBar(details: details, l: l)
        else
          _EndTripBar(details: details, l: l),
      ],
    );
  }

  Map<String, List<TripStudentDetailDto>> _groupByArea(
      List<TripStudentDetailDto> students) {
    final map = <String, List<TripStudentDetailDto>>{};
    for (final s in students) {
      // Empty string is a real key here — the matching _StopGroup hides its
      // header when the area name is empty (no "Unassigned" placeholder).
      final key = s.homeArea?.trim() ?? '';
      (map[key] ??= []).add(s);
    }
    return map;
  }

  void _onScanQr(BuildContext context, WidgetRef ref) {
    // Skip the legacy "paste the token" dialog and drop the assistant
    // straight into the camera scanner. The scan screen handles URL →
    // token extraction, calls the API, and shows inline success / error
    // feedback so the assistant can rattle through students without
    // bouncing back to this screen between each scan.
    context.push(AppRoute.assistantStudentScanFor(widget.details.tripId));
  }

  Future<void> _onNfcTap(BuildContext context) async {
    // Open the dedicated NFC scanner — works the same way as the
    // student QR camera scanner but uses Core NFC / Android NFC to
    // read the card UID. The endpoint that flips boarding state
    // accepts any token string, so NFC and QR resolve through the
    // same /students/scan path on the API side. The scan screen
    // pops back with the rendered success message (e.g. "تم — أحمد")
    // so we surface that here as a snackbar.
    final message = await context
        .push<String>(AppRoute.assistantNfcScanFor(widget.details.tripId));
    if (message == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// Squared planar distance — fine for ranking nearest neighbours at
/// city-scale. Hoisted to file scope so the trip-body state class can
/// reuse it from `_sortedStudents`. Same metric the driver map uses,
/// which is what keeps the two screens in agreement on visit order.
double _sqDist(LatLng a, LatLng b) {
  final dx = a.latitude - b.latitude;
  final dy = a.longitude - b.longitude;
  return dx * dx + dy * dy;
}

// ─── Header ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d · h:mm a');
    final fmtTime = DateFormat('h:mm a');
    final start = details.actualDeparture ?? details.scheduledDeparture;
    final completed = details.status == 'Completed';
    // Absent students don't count toward the totals — they were never
    // expected to ride. Progress means different things per trip type:
    //  • Morning → boarding (students picked up out of expected)
    //  • Return  → drop-offs (students delivered home out of expected)
    final absentCount =
        details.students.where((s) => s.isAbsent).length;
    final expected = details.studentCount - absentCount;
    // Live morning trips show pickups (Boarded); live return trips show
    // drop-offs at home (DroppedOff). On completion, UpdateTripStatus
    // flips every Boarded morning student to DroppedOff — using
    // boardedCount here would render 0/N. Once completed, both legs
    // measure the same thing: students delivered.
    final int progressNumerator;
    if (completed) {
      progressNumerator = details.droppedOffCount;
    } else if (details.isMorning) {
      progressNumerator = details.boardedCount;
    } else {
      progressNumerator = details.droppedOffCount;
    }
    final progress =
        expected <= 0 ? 0.0 : progressNumerator / expected;

    final subtitle = StringBuffer();
    final scheduledStatus = details.status == 'Scheduled';
    if (completed && details.actualArrival != null) {
      // Trip recap. Use the longer "MMM d · h:mm" format so the date is
      // legible in case the user is reviewing a trip from a previous day.
      subtitle
        ..write('${l.assistantStartedAt} ${fmt.format(start.toLocal())}  ·  ')
        ..write(
            '${l.assistantEndedAt} ${fmtTime.format(details.actualArrival!.toLocal())}');
    } else if (scheduledStatus) {
      // Pre-start trips have no ActualDeparture yet — show the creation
      // time (ScheduledDeparture is stamped at StartTripCommand time) so
      // the assistant knows when this draft was set up.
      subtitle.write(
          '${l.assistantCreatedAt} ${fmtTime.format(start.toLocal())}');
    } else {
      subtitle.write('${l.assistantStartedAt} ${fmtTime.format(start.toLocal())}');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BackBtn(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${details.isMorning ? l.assistantMorningPickup : l.assistantAfternoonDropoff} · ${details.busPlateNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate500,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (details.driverName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l.assistantDriverLabel}: ${details.driverName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (details.status == 'InProgress') _LivePill(l: l),
              ],
            ),
            // Pre-start (Scheduled) trips have nothing to measure yet, so
            // the progress row is dead weight — hide it until the trip is
            // live or completed.
            if (details.status != 'Scheduled') ...[
              const SizedBox(height: 12),
              _ProgressRow(
                boarded: progressNumerator,
                total: expected,
                progress: progress,
                isMorning: details.isMorning,
                l: l,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.slate50,
          border: Border.all(color: AppColors.slate100),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 18,
          color: AppColors.slate700,
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
          ),
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
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.boarded,
    required this.total,
    required this.progress,
    required this.isMorning,
    required this.l,
  });
  final int boarded, total;
  final double progress;
  final bool isMorning;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final label =
        isMorning ? l.assistantBoardedLabel : l.driverProgressLabel;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  children: [
                    TextSpan(
                      text: '$boarded',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: ' ${l.assistantOf} $total'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.slate100,
              valueColor: const AlwaysStoppedAnimation(AppColors.yellowDeep),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Scan action row ────────────────────────────────────────────────────

class _ScanActionRow extends StatelessWidget {
  const _ScanActionRow({
    required this.onQr,
    required this.onNfc,
    required this.showQr,
    required this.showNfc,
    required this.l,
  });
  final VoidCallback onQr;
  final VoidCallback onNfc;
  final bool showQr;
  final bool showNfc;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (!showQr && !showNfc) return const SizedBox.shrink();
    final qr = _ScanBtn(
      icon: Icons.qr_code_scanner_rounded,
      title: l.assistantScanQrShort,
      subtitle: l.assistantScanQrSubShort,
      onTap: onQr,
      isQr: true,
    );
    final nfc = _ScanBtn(
      icon: Icons.nfc_rounded,
      title: l.assistantTapNfc,
      subtitle: l.assistantTapNfcSub,
      onTap: onNfc,
      isQr: false,
    );
    if (showQr && !showNfc) return qr;
    if (!showQr && showNfc) return nfc;
    return Row(
      children: [
        Expanded(child: qr),
        const SizedBox(width: 8),
        Expanded(child: nfc),
      ],
    );
  }
}

class _ScanBtn extends StatelessWidget {
  const _ScanBtn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isQr,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool isQr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isQr
              ? const LinearGradient(
                  colors: [AppColors.yellow, AppColors.yellowDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isQr ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isQr ? Colors.transparent : AppColors.slate200,
          ),
          boxShadow: isQr ? AppShadows.yellow : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isQr ? const Color(0x33FFFFFF) : AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isQr ? AppColors.ink : AppColors.slate700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isQr ? AppColors.ink : AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isQr
                          ? const Color(0x99000000)
                          : AppColors.slate500,
                    ),
                  ),
                ],
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
  const _SectionHeader({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
              l.assistantStudentsByStop,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.slate600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.place_outlined,
                size: 12, color: AppColors.slate500),
            const SizedBox(width: 4),
            Text(
              l.assistantRouteOrder,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.slate500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Stop group ─────────────────────────────────────────────────────────

class _StopGroup extends StatelessWidget {
  const _StopGroup({
    required this.stopNumber,
    required this.stopName,
    required this.students,
    required this.tripId,
    required this.isMorning,
    required this.readOnly,
    required this.scheduled,
    required this.l,
  });
  final int stopNumber;
  final String stopName;
  final List<TripStudentDetailDto> students;
  final String tripId;
  final bool isMorning;
  final bool readOnly;
  // Scheduled trips show a roster-only view (no status badges, no stop
  // header) — distinct from "readOnly" which also covers Completed.
  final bool scheduled;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Skip the stop-name row entirely when the area is empty (no
    // "Unassigned" placeholder) — the student tiles read fine on their own.
    final showHeader = stopName.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$stopNumber',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.yellow,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stopName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${students.length} ${l.assistantStudents}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        for (var i = 0; i < students.length; i++) ...[
          _StudentRow(
            student: students[i],
            paletteIndex: i,
            tripId: tripId,
            isMorning: isMorning,
            readOnly: readOnly,
            scheduled: scheduled,
            l: l,
          ),
          if (i < students.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

// ─── Student row ────────────────────────────────────────────────────────

class _StudentRow extends ConsumerStatefulWidget {
  const _StudentRow({
    required this.student,
    required this.paletteIndex,
    required this.tripId,
    required this.isMorning,
    required this.readOnly,
    required this.scheduled,
    required this.l,
  });
  final TripStudentDetailDto student;
  final int paletteIndex;
  final String tripId;
  final bool isMorning;
  final bool readOnly;
  // Scheduled = no trailing widgets (no outcome badge / absence info /
  // pickup toggle) — the roster is for review only at this stage.
  final bool scheduled;
  final AppLocalizations l;

  @override
  ConsumerState<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends ConsumerState<_StudentRow> {
  static const _palette = [
    [Color(0xFFFECACA), Color(0xFFF87171), Color(0xFF7F1D1D)],
    [Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF1E40AF)],
    [Color(0xFFFEF3C7), Color(0xFFFCD34D), Color(0xFF92400E)],
    [Color(0xFFDDD6FE), Color(0xFFA78BFA), Color(0xFF5B21B6)],
    [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFF065F46)],
    [Color(0xFFFED7AA), Color(0xFFFB923C), Color(0xFF9A3412)],
    [Color(0xFFE0E7FF), Color(0xFF818CF8), Color(0xFF3730A3)],
    [Color(0xFFFBCFE8), Color(0xFFF472B6), Color(0xFF831843)],
  ];

  bool _busy = false;

  /// Pick the right name field for the current UI locale — Arabic shows
  /// FullName, English prefers FullNameEn when present and falls back to
  /// FullName otherwise. Mirrors the helper in the trip-setup screen.
  String _displayName(TripStudentDetailDto s) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return s.fullName;
    final en = s.fullNameEn;
    return (en != null && en.trim().isNotEmpty) ? en : s.fullName;
  }

  Future<void> _toggleBoarded() async {
    final s = widget.student;
    if (s.isAbsent) return;
    // Behaviour depends on trip type:
    //  • Morning trip — Waiting ↔ Boarded. The end-trip flow flips boarded
    //    students to "arrived at school" server-side, so the assistant only
    //    needs to confirm pickups during the trip.
    //  • Return trip — Boarded ↔ DroppedOff. Students start the trip on the
    //    bus from school; marking is what flags "arrived home".
    final isMorning = widget.isMorning;
    final next = isMorning
        ? (s.isBoarded ? 'Waiting' : 'Boarded')
        : (s.isDroppedOff ? 'Boarded' : 'DroppedOff');
    setState(() => _busy = true);
    try {
      final action = ref.read(tripActionsProvider(widget.tripId));
      await action.setBoarding(
        studentId: s.studentId,
        status: next,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _notifyArrived() async {
    final s = widget.student;
    try {
      await ref
          .read(tripActionsProvider(widget.tripId))
          .notifyArrived(s.studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.assistantNotifyArrivedOk)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    }
  }

  Future<void> _whatsapp() async {
    final phone = widget.student.parentPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.assistantNoParentPhone)),
      );
      return;
    }
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleaned');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.assistantOpenFailed)),
      );
    }
  }

  Future<void> _call() async {
    final phone = widget.student.parentPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.assistantNoParentPhone)),
      );
      return;
    }
    final url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.assistantOpenFailed)),
      );
    }
  }

  /// Confirm-and-flip the student's status for this trip to Absent. The
  /// parent-side `AbsenceRequest` is unaffected; this only marks them
  /// absent on the live roster so they drop out of routing + counts.
  Future<void> _markAbsent() async {
    final l = widget.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.assistantMarkAbsentTitle),
        content: Text(
          l.assistantMarkAbsentBody(_displayName(widget.student)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l.assistantMarkAbsentConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(tripActionsProvider(widget.tripId))
          .setBoarding(studentId: widget.student.studentId, status: 'Absent');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Reverse an assistant-marked absence — flips the student back to
  /// Waiting (Morning) or Boarded (Return). Parent-reported absences
  /// can't be undone here; the badge stays read-only in that case.
  Future<void> _unmarkAbsent() async {
    final fallback = widget.isMorning ? 'Waiting' : 'Boarded';
    setState(() => _busy = true);
    try {
      await ref.read(tripActionsProvider(widget.tripId)).setBoarding(
            studentId: widget.student.studentId,
            status: fallback,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final l = widget.l;
    final palette = _palette[widget.paletteIndex % _palette.length];
    final boarded = s.isBoarded;
    final absent = s.isAbsent;
    // The row border highlights the same milestone the mark icon does:
    // boarded for Morning, arrived-home for Return.
    final highlight = widget.isMorning ? boarded : s.isDroppedOff;

    return Opacity(
      opacity: absent ? 0.65 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: absent ? AppColors.slate50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight ? const Color(0xFFA7F3D0) : AppColors.slate200,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            _Avatar(
              text: _initials(_displayName(s)),
              bg1: palette[0],
              bg2: palette[1],
              fg: palette[2],
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName(s),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Scheduled trips show only the student's home area
                  // (with a pin) instead of the boarding meta — the trip
                  // hasn't started so there's no status to surface yet.
                  if (widget.scheduled) ...[
                    if ((s.homeArea ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.slate500,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              s.homeArea!.trim(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      _meta(s, l),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (widget.scheduled) ...[
              // Scheduled trips show name + meta only — no status badges
              // and no actions until the assistant taps Start.
            ] else if (widget.readOnly) ...[
              _OutcomeBadge(student: s, l: l),
              if (absent && _hasAbsenceDetail(s)) ...[
                const SizedBox(width: 6),
                _AbsenceInfoBtn(
                  onTap: () => _showAbsenceSheet(s),
                ),
              ],
            ] else if (absent) ...[
              _AbsentBadge(l: l),
              if (_hasAbsenceDetail(s)) ...[
                const SizedBox(width: 6),
                _AbsenceInfoBtn(
                  onTap: () => _showAbsenceSheet(s),
                ),
              ] else ...[
                // Assistant-flipped absences (no parent record) are
                // reversible — tap × to put the student back on the trip.
                const SizedBox(width: 6),
                _CommBtn(
                  icon: Icons.refresh_rounded,
                  color: AppColors.slate600,
                  onTap: _busy ? () {} : _unmarkAbsent,
                ),
              ],
            ] else ...[
              // What "checked" means depends on the leg:
              //   • Morning — student picked up (Boarded)
              //   • Return  — student arrived home (DroppedOff)
              // Boarded students on a Return trip are still "on the bus"
              // and the toggle stays empty so the assistant can clearly
              // tell who hasn't been delivered yet.
              Builder(builder: (_) {
                final checked =
                    widget.isMorning ? boarded : s.isDroppedOff;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PickupToggle(
                      checked: checked,
                      busy: _busy,
                      onTap: _toggleBoarded,
                    ),
                    // The mark-absent button only makes sense while the
                    // student hasn't been picked up / dropped off yet —
                    // once they're checked, marking absent would be
                    // contradictory, so we hide the button.
                    if (!checked) ...[
                      const SizedBox(width: 6),
                      _CommBtn(
                        icon: Icons.person_off_outlined,
                        color: AppColors.red,
                        onTap: _markAbsent,
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(width: 4),
              // Single contact-the-parent button. Tap opens a dropdown
              // menu with Notify (bus-arrived push), WhatsApp, and Call so
              // the row stays compact.
              _ContactMenuBtn(
                // Hide the "Notify arrived" menu item once the student
                // is already checked off (Morning → boarded, Return →
                // dropped). At that point the parent has already gotten
                // a StudentBoarded / StudentArrived push from the
                // boarding flip, so a manual notify is redundant.
                onNotify: highlight ? null : _notifyArrived,
                onWhatsapp: _whatsapp,
                onCall: _call,
                l: l,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasAbsenceDetail(TripStudentDetailDto s) =>
      (s.absenceReason?.isNotEmpty ?? false) ||
      (s.absencePickupPersonName?.isNotEmpty ?? false) ||
      (s.absencePickupPersonRelation?.isNotEmpty ?? false) ||
      (s.absenceDriverNote?.isNotEmpty ?? false);

  Future<void> _showAbsenceSheet(TripStudentDetailDto s) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AbsenceDetailSheet(
        student: s,
        tripId: widget.tripId,
        l: widget.l,
      ),
    );
  }

  String _meta(TripStudentDetailDto s, AppLocalizations l) {
    final parts = <String>[];
    final grade = s.className == null
        ? s.grade
        : '${s.grade}-${s.className}';
    parts.add(grade);
    // Scheduled trips show grade only — no boarding/absence status, since
    // nothing has happened yet (the trip hasn't started).
    if (widget.scheduled) return parts.join(' · ');
    final fmt = DateFormat('h:mm a');
    if (s.isAbsent) {
      parts.add(l.assistantAbsenceReported);
    } else if (s.isDroppedOff && s.dropoffTime != null) {
      // The "drop" event means different things per leg:
      //  • Morning trip → student arrived at school
      //  • Return trip  → student arrived home
      final label = widget.isMorning
          ? l.assistantArrivedSchool
          : l.assistantArrivedHome;
      parts.add('$label ${fmt.format(s.dropoffTime!.toLocal())}');
    } else if (s.isBoarded && s.boardingTime != null) {
      // Both legs use "On bus" once the student is on board. Morning trips
      // append the pickup time so the assistant can see exactly when each
      // student boarded; Return trips skip the timestamp since every row
      // shares the trip-start moment.
      parts.add(widget.isMorning
          ? '${l.assistantOnBus} · ${fmt.format(s.boardingTime!.toLocal())}'
          : l.assistantOnBus);
    } else if (widget.readOnly) {
      parts.add(l.assistantNotBoarded);
    } else {
      parts.add(widget.isMorning
          ? l.assistantWaitingForPickup
          : l.assistantOnBus);
    }
    return parts.join(' · ');
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '·';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.text,
    required this.bg1,
    required this.bg2,
    required this.fg,
  });
  final String text;
  final Color bg1, bg2, fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg1, bg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _AbsentBadge extends StatelessWidget {
  const _AbsentBadge({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.do_not_disturb_alt_rounded,
              size: 10, color: AppColors.slate500),
          const SizedBox(width: 4),
          Text(
            l.assistantAbsentBadge,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only outcome pill rendered on completed-trip rows. Reflects what
/// actually happened: Boarded (green) / Absent (grey) / Not boarded (slate).
class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({required this.student, required this.l});
  final TripStudentDetailDto student;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (student.isAbsent) return _AbsentBadge(l: l);
    if (student.isDroppedOff) {
      return _Pill(
        bg: AppColors.emeraldSoft,
        border: const Color(0xFFA7F3D0),
        fg: AppColors.emerald,
        icon: Icons.check_rounded,
        label: l.assistantStatusDropped,
      );
    }
    if (student.isBoarded) {
      return _Pill(
        bg: AppColors.emeraldSoft,
        border: const Color(0xFFA7F3D0),
        fg: AppColors.emerald,
        icon: Icons.check_rounded,
        label: l.assistantStatusDone,
      );
    }
    return _Pill(
      bg: AppColors.slate100,
      border: AppColors.slate200,
      fg: AppColors.slate600,
      icon: Icons.remove_rounded,
      label: l.assistantNotBoardedShort,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.bg,
    required this.border,
    required this.fg,
    required this.icon,
    required this.label,
  });
  final Color bg, border, fg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only summary bar shown in place of the End-trip button when the
/// trip is already Completed.
// ── Absence info button + bottom sheet ────────────────────────────────────

class _AbsenceInfoBtn extends StatelessWidget {
  const _AbsenceInfoBtn({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: AppColors.slate600,
        ),
      ),
    );
  }
}

class _AbsenceDetailSheet extends ConsumerStatefulWidget {
  const _AbsenceDetailSheet({
    required this.student,
    required this.tripId,
    required this.l,
  });
  final TripStudentDetailDto student;
  final String tripId;
  final AppLocalizations l;

  @override
  ConsumerState<_AbsenceDetailSheet> createState() =>
      _AbsenceDetailSheetState();
}

class _AbsenceDetailSheetState extends ConsumerState<_AbsenceDetailSheet> {
  bool _busy = false;

  Future<void> _cancel() async {
    final l = widget.l;
    final id = widget.student.absenceRequestId;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.assistantAbsenceCancelTitle),
        content: Text(l.assistantAbsenceCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l.assistantAbsenceCancelYes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final ds = ref.read(assistantRemoteDataSourceProvider);
      await ds.cancelAbsenceRequest(id);
      // Force the trip-details refetch so the student switches back to its
      // pre-absent boarding state immediately.
      ref.invalidate(tripDetailsProvider(widget.tripId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.assistantAbsenceCancelled)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final l = widget.l;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.do_not_disturb_alt_rounded,
                    size: 18,
                    color: AppColors.slate600,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.assistantAbsenceSheetTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (student.absenceReason != null)
              _AbsenceRow(
                label: l.assistantAbsenceReasonLabel,
                value: _localiseReason(student.absenceReason!, l),
              ),
            if (student.absencePickupPersonName != null &&
                student.absencePickupPersonName!.isNotEmpty)
              _AbsenceRow(
                label: l.assistantAbsencePickupBy,
                value: [
                  student.absencePickupPersonName!,
                  if (student.absencePickupPersonRelation?.isNotEmpty ??
                      false)
                    '(${student.absencePickupPersonRelation})',
                ].join(' '),
              ),
            if (student.absenceDriverNote != null &&
                student.absenceDriverNote!.isNotEmpty)
              _AbsenceRow(
                label: l.assistantAbsenceNoteLabel,
                value: student.absenceDriverNote!,
              ),
            if (student.absenceRequestId != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _cancel,
                  icon: _busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 16),
                  label: Text(l.assistantAbsenceCancelYes),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _localiseReason(String code, AppLocalizations l) {
    switch (code) {
      case 'Illness':
        return l.assistantAbsenceReasonIllness;
      case 'MedicalAppointment':
        return l.assistantAbsenceReasonMedical;
      case 'FamilyMatter':
        return l.assistantAbsenceReasonFamily;
      case 'Other':
        return l.assistantAbsenceReasonOther;
      default:
        return code;
    }
  }
}

class _AbsenceRow extends StatelessWidget {
  const _AbsenceRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.slate500,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedSummaryBar extends StatelessWidget {
  const _CompletedSummaryBar({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final absentCount =
        details.students.where((s) => s.isAbsent).length;
    final expected = details.studentCount - absentCount;
    // Recap counts arrivals — students who actually finished their leg —
    // which is exactly the DroppedOff count for both Morning (flipped on
    // end-trip) and Return (flipped per-student by the assistant).
    final arrived = details.droppedOffCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.emeraldSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.emerald,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.assistantTripCompletedTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$arrived/$expected ${l.driverProgressLabel.toLowerCase()}',
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
      ),
    );
  }
}

/// Binary "done?" mark used by both legs:
///   • Morning — green check once the student has boarded the bus.
///   • Return  — green check once the student has arrived home.
/// The unchecked state is always a quiet grey square, so a Return trip
/// starts visually empty even though every row is technically Boarded.
class _PickupToggle extends StatelessWidget {
  const _PickupToggle({
    required this.checked,
    required this.busy,
    required this.onTap,
  });
  final bool checked;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked ? AppColors.emerald : AppColors.slate100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: checked
              ? const [
                  BoxShadow(
                    color: Color(0x4D059669),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: busy
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.check_rounded,
                size: 16,
                color: checked ? Colors.white : AppColors.slate400,
              ),
      ),
    );
  }
}

class _CommBtn extends StatelessWidget {
  const _CommBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

/// Contact-the-parent dropdown — collapses the WhatsApp + Call buttons into
/// a single icon that opens a small menu, keeping the row compact even when
/// other actions (mark-absent, pickup toggle) need horizontal space.
enum _ContactAction { notify, whatsapp, call }

class _ContactMenuBtn extends StatelessWidget {
  const _ContactMenuBtn({
    required this.onNotify,
    required this.onWhatsapp,
    required this.onCall,
    required this.l,
  });
  // Nullable so the call site can hide the Notify item — e.g. once the
  // student is already checked off, telling the parent "the bus is here"
  // is redundant. When null we skip the menu entry entirely.
  final VoidCallback? onNotify;
  final VoidCallback onWhatsapp;
  final VoidCallback onCall;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.blue;
    return PopupMenuButton<_ContactAction>(
      tooltip: l.assistantContactParent,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _ContactAction.notify:   onNotify?.call(); break;
          case _ContactAction.whatsapp: onWhatsapp();     break;
          case _ContactAction.call:     onCall();         break;
        }
      },
      itemBuilder: (_) => [
        if (onNotify != null)
          PopupMenuItem(
            value: _ContactAction.notify,
            height: 40,
            child: _ContactMenuRow(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.red,
              label: l.assistantNotifyArrivedMenu,
            ),
          ),
        PopupMenuItem(
          value: _ContactAction.whatsapp,
          height: 40,
          child: const _ContactMenuRow(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: Color(0xFF25D366),
            label: 'WhatsApp',
          ),
        ),
        PopupMenuItem(
          value: _ContactAction.call,
          height: 40,
          child: _ContactMenuRow(
            icon: Icons.phone_rounded,
            iconColor: AppColors.blue,
            label: l.assistantCallMenu,
          ),
        ),
      ],
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.contact_phone_outlined,
          size: 14,
          color: accent,
        ),
      ),
    );
  }
}

class _ContactMenuRow extends StatelessWidget {
  const _ContactMenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

// ─── End trip bar ───────────────────────────────────────────────────────

class _EndTripBar extends ConsumerStatefulWidget {
  const _EndTripBar({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;
  @override
  ConsumerState<_EndTripBar> createState() => _EndTripBarState();
}

class _EndTripBarState extends ConsumerState<_EndTripBar> {
  bool _busy = false;

  bool get _isEmpty => widget.details.studentCount == 0;

  Future<void> _end() async {
    final l = widget.l;
    final deleting = _isEmpty;
    // Empty trips have nothing to complete — confirm a hard delete instead.
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deleting
            ? l.assistantDeleteTripConfirmTitle
            : l.assistantEndTripConfirmTitle),
        content: Text(deleting
            ? l.assistantDeleteTripConfirmBody
            : l.assistantEndTripConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: deleting
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(deleting
                ? l.assistantDeleteTripConfirmYes
                : l.assistantEndTripConfirmYes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final ds = ref.read(assistantRemoteDataSourceProvider);
      if (deleting) {
        await ds.cancelEmptyTrip(widget.details.tripId);
      } else {
        await ds.completeTrip(widget.details.tripId);
      }
      // Invalidate before navigating so the home rebuild picks up the
      // refreshed list (the autoDispose provider was kept alive by the
      // previous home subscription, so a re-mount alone wouldn't refetch).
      ref.invalidate(myTodayTripsProvider);
      ref.invalidate(tripDetailsProvider(widget.details.tripId));
      if (!mounted) return;
      context.go(AppRoute.homeAssistant);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final absentCount =
        widget.details.students.where((s) => s.isAbsent).length;
    final expected = widget.details.studentCount - absentCount;
    // Same numerator the header progress uses — boarding for Morning,
    // drop-offs for Return — so the bottom pill stays in lock-step.
    final progressNumerator = widget.details.isMorning
        ? widget.details.boardedCount
        : widget.details.droppedOffCount;
    final progressLabel = widget.details.isMorning
        ? widget.l.assistantBoardedLabel
        : widget.l.driverProgressLabel;
    // Gate End Trip on a full progress bar — the assistant can only end
    // the trip once every non-absent student has boarded (Morning) or
    // been dropped off (Return). Empty trips bypass this since they
    // short-circuit to a delete.
    final progressComplete =
        _isEmpty || (expected > 0 && progressNumerator >= expected);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: _busy ||
                  widget.details.status == 'Completed' ||
                  !progressComplete
              ? null
              : _end,
          style: _isEmpty
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                )
              : null,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ink,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isEmpty
                        ? widget.l.assistantDeleteTrip
                        : widget.l.assistantEndTrip),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isEmpty
                            ? Colors.white.withValues(alpha: 0.18)
                            : AppColors.ink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '$progressNumerator/$expected $progressLabel',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _isEmpty ? Colors.white : AppColors.ink,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Error view ─────────────────────────────────────────────────────────

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

// ─── Scheduled-trip start bar ────────────────────────────────────────────
// Step 2 of the two-step new-trip flow. The trip was already materialised
// in Scheduled status with its roster; this bar's button flips it to
// InProgress via /trips/{id}/start. Server handles Return-trip auto-
// boarding + driver "trip started" push on that transition.
class _StartScheduledBar extends ConsumerStatefulWidget {
  const _StartScheduledBar({required this.details, required this.l});
  final TripDetailsDto details;
  final AppLocalizations l;

  @override
  ConsumerState<_StartScheduledBar> createState() =>
      _StartScheduledBarState();
}

class _StartScheduledBarState
    extends ConsumerState<_StartScheduledBar> {
  bool _busy = false;

  Future<void> _start() async {
    final l = widget.l;
    // Block the start when every student on the roster is absent —
    // there's nothing the bus would actually do, and the trip would
    // immediately have nobody to pick up / drop off. Empty rosters
    // are handled separately by the "delete empty trip" path.
    final students = widget.details.students;
    if (students.isNotEmpty && students.every((s) => s.isAbsent)) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.assistantStartAllAbsentTitle),
          content: Text(l.assistantStartAllAbsentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
          ],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.assistantStartTrip),
        content:
            Text(l.assistantStartTripBody(widget.details.students.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.assistantStartTripYes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(activateTripActionProvider)(widget.details.tripId);
      if (!mounted) return;
      // Re-fetch so the screen re-renders with the new status (InProgress
      // shows the end-trip bar + boarding actions).
      ref.invalidate(tripDetailsProvider(widget.details.tripId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l = widget.l;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.assistantDeleteScheduledTitle),
        content: Text(l.assistantDeleteScheduledBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.redDark),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.assistantDeleteScheduledYes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(deleteScheduledTripActionProvider)(widget.details.tripId);
      if (!mounted) return;
      // Trip is gone — pop back to the home where myTodayTripsProvider
      // (also invalidated by the action) will refetch the live list.
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Delete + Edit sit on the left; Start fills the rest. Fixed
            // widths avoid the Row's intrinsic-width footgun.
            SizedBox(
              width: 72,
              child: OutlinedButton(
                onPressed: _busy ? null : _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.redDark,
                  side: const BorderSide(color: AppColors.redDark),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 88,
              child: OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => context.push(
                          AppRoute.assistantTripSetupForEdit(
                              widget.details.tripId),
                        ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.slate200),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l.commonEdit),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _start,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(l.assistantStartTrip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
