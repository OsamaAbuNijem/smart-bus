import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/data/models/bus_summary_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/driver_summary_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/features/assistant/presentation/screens/assistant_setup_nfc_scan_screen.dart';
import 'package:tilmez_bus/features/assistant/presentation/screens/assistant_setup_qr_scan_screen.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// State 2 (post-QR) and State 3 (manual) trip-setup screen.
/// In QR mode, the bus is locked to whatever the scan resolved (rendered as
/// a chip with "From QR"). In manual mode, the bus is selectable.
/// In both modes the assistant picks driver + trip type, and the students
/// are pulled live from the last trip on (bus, type).
/// When [editTripId] is non-null the screen is in "edit" mode: it preloads
/// the existing trip's bus / driver / tripType / roster and, on save,
/// deletes the old scheduled trip and creates a new one in its place.
class AssistantTripSetupScreen extends ConsumerStatefulWidget {
  const AssistantTripSetupScreen({super.key, this.editTripId});
  final String? editTripId;

  @override
  ConsumerState<AssistantTripSetupScreen> createState() =>
      _AssistantTripSetupScreenState();
}

class _AssistantTripSetupScreenState
    extends ConsumerState<AssistantTripSetupScreen> {
  BusSummaryDto? _selectedBus;
  DriverSummaryDto? _selectedDriver;
  String _tripType = 'Morning';
  bool _starting = false;
  // Unified roster for this trip — initially seeded from the last-trip
  // history (lastRosterProvider) and editable: add via search / QR-scan,
  // remove via the X on each row. Keyed by studentId so add/delete are
  // O(1) and LinkedHashMap preserves insertion order. The trip starts
  // with EXACTLY these students; empty list blocks Start.
  final Map<String, RosterStudentDto> _roster = {};
  // Remember the (bus, type) we already auto-seeded from history so the
  // user's edits don't get wiped when the screen rebuilds.
  String? _seededKey;

  // Edit mode: when the user came from the scheduled-trip details screen
  // via the Edit button, we preload the trip's bus/driver/tripType/roster
  // and replace the trip on save. Pure boolean derived from widget — the
  // _editLoaded flag prevents double-loading on hot reload / rebuild.
  bool get _isEditMode => widget.editTripId != null;
  bool _editLoaded = false;

  @override
  void initState() {
    super.initState();
    // Edit mode wins over QR mode — they're mutually exclusive entry paths.
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _preloadFromTrip(widget.editTripId!);
      });
      return;
    }
    // In QR mode the bus is already in the controller — pick it up here so
    // the user can't change it. In manual mode it stays null until the user
    // picks one from the dropdown.
    final scanned = ref.read(scannedBusControllerProvider).valueOrNull;
    _selectedBus = scanned;
    if (scanned != null) {
      // Pre-fetch history when entering via QR (post-frame because ref.read
      // shouldn't run mid-initState for autoDispose families).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadHistory(scanned.id, _tripType);
      });
    }
  }

  bool get _isQrMode => ref.read(scannedBusControllerProvider).valueOrNull != null;

  /// Fetch the trip details + the bus/driver lookup tables, then seed the
  /// form so the assistant sees the existing trip exactly as it was saved.
  /// Best-effort — if any fetch fails we leave the form blank and surface a
  /// snackbar, since a partial preload would be worse than a fresh start.
  Future<void> _preloadFromTrip(String tripId) async {
    if (_editLoaded) return;
    _editLoaded = true;
    try {
      final ds = ref.read(assistantRemoteDataSourceProvider);
      final details = await ds.getTripDetails(tripId);
      final buses = await ref.read(busesListProvider.future);
      final drivers = await ref.read(driversListProvider.future);
      if (!mounted) return;
      final bus = buses.where((b) => b.id == details.busId).cast<BusSummaryDto?>().firstOrNull;
      final driver = details.driverId == null
          ? null
          : drivers.where((d) => d.id == details.driverId).cast<DriverSummaryDto?>().firstOrNull;
      setState(() {
        _selectedBus = bus;
        _selectedDriver = driver;
        _tripType = details.tripType;
        // Mark this (bus, type) as "already seeded" so history fetch
        // doesn't overwrite the edit-mode roster with the last trip's.
        _seededKey = bus == null ? null : '${bus.id}|$_tripType';
        _roster
          ..clear()
          ..addEntries(details.students.map((s) => MapEntry(
                s.studentId,
                RosterStudentDto(
                  studentId: s.studentId,
                  fullName: s.fullName,
                  fullNameEn: s.fullNameEn,
                  grade: s.grade,
                ),
              )));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    }
  }

  bool get _canStart =>
      !_starting &&
      _selectedBus != null &&
      _selectedDriver != null &&
      _roster.isNotEmpty;

  Future<void> _start() async {
    if (!_canStart) return;
    final confirmed = await _confirmStart();
    if (confirmed != true) return;
    setState(() => _starting = true);
    try {
      // Edit flow: delete the existing scheduled trip first so the
      // "one pending trip per assistant" server lock doesn't block the
      // replacement. The old roster's boarding state is irrelevant — a
      // scheduled trip has no boarding history yet.
      if (_isEditMode) {
        await ref.read(deleteScheduledTripActionProvider)(widget.editTripId!);
      }
      // Step 1 of the two-step new-trip flow: materialise the trip in
      // Scheduled status. The assistant flips it to InProgress later from
      // the trip-details screen (server-side handles Return-trip auto-
      // boarding + driver push at that point).
      final action = ref.read(startTripActionProvider);
      final result = await action(
        busId: _selectedBus!.id,
        driverId: _selectedDriver!.id,
        tripType: _tripType,
        skipRoster: false,
        manualStudentIds: _roster.keys.toList(),
        scheduled: true,
      );
      if (!mounted) return;
      ref.read(scannedBusControllerProvider.notifier).clear();
      context.pushReplacement(
        AppRoute.assistantTripDetailsFor(result.tripId),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : '$e')),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Fetch the last-trip roster for the new (bus, tripType) and use it as
  /// the starting roster. Called explicitly when the user picks / changes
  /// either dropdown — pulling the side effect out of the editor's build
  /// avoids the rebuild-loop trap. Stale responses (user kept tapping
  /// faster than the network) are dropped via the (busId, tripType) check.
  Future<void> _loadHistory(String busId, String tripType) async {
    final key = '$busId|$tripType';
    if (_seededKey == key) return; // already seeded for this combo
    try {
      final ds = ref.read(assistantRemoteDataSourceProvider);
      final history =
          await ds.getLastRoster(busId: busId, tripType: tripType);
      if (!mounted) return;
      if (_selectedBus?.id != busId || _tripType != tripType) return;
      setState(() {
        _seededKey = key;
        _roster
          ..clear()
          ..addEntries(history.map((s) => MapEntry(s.studentId, s)));
      });
    } catch (_) {
      // History fetch is best-effort — the editor is still functional when
      // it fails (the assistant just builds the roster from scratch).
    }
  }

  Future<bool?> _confirmStart() {
    final l = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.assistantSaveTripTitle),
        content: Text(l.assistantSaveTripBody(_roster.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(scannedBusControllerProvider.notifier).clear();
            context.pop();
          },
        ),
        title: Text(_isEditMode ? l.commonEdit : l.assistantTripSetupTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                children: [
                  if (_isQrMode && _selectedBus != null)
                    _BusChipFromQr(bus: _selectedBus!, l: l)
                  else
                    _BusPicker(
                      selected: _selectedBus,
                      // Defer the bus-change side effects to the next frame
                      // so the DropdownButton overlay can dismiss cleanly
                      // before the parent rebuilds + the history fetch
                      // fires. Doing it synchronously inside onChanged was
                      // colliding with the dropdown's own animation and
                      // making the screen look frozen on some devices.
                      onChanged: (b) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _selectedBus = b;
                            // Clear the previously-picked driver so the
                            // auto-picker re-fires for the new bus's last
                            // trip; the user can still override after.
                            _selectedDriver = null;
                            _seededKey = null;
                            _roster.clear();
                          });
                          if (b != null) _loadHistory(b.id, _tripType);
                        });
                      },
                      l: l,
                    ),
                  const SizedBox(height: 14),
                  _SimpleLabel(text: l.assistantTripTypeLabel),
                  const SizedBox(height: 8),
                  _TripTypeRow(
                    selected: _tripType,
                    onChanged: (t) {
                      setState(() {
                        _tripType = t;
                        // Different trip type → different last-trip driver,
                        // so reset and let the auto-picker re-resolve.
                        _selectedDriver = null;
                        _seededKey = null;
                        _roster.clear();
                      });
                      final b = _selectedBus;
                      if (b != null) _loadHistory(b.id, t);
                    },
                    l: l,
                  ),
                  const SizedBox(height: 14),
                  _SimpleLabel(text: l.assistantDriverLabel),
                  const SizedBox(height: 8),
                  if (_selectedBus != null)
                    _DriverAutoPicker(
                      busId: _selectedBus!.id,
                      tripType: _tripType,
                      selected: _selectedDriver,
                      onChanged: (d) =>
                          setState(() => _selectedDriver = d),
                      l: l,
                    )
                  else
                    _DriverPicker(
                      selected: _selectedDriver,
                      onChanged: (d) =>
                          setState(() => _selectedDriver = d),
                      l: l,
                    ),
                  const SizedBox(height: 14),
                  if (_selectedBus != null)
                    _RosterEditor(
                      busId: _selectedBus!.id,
                      tripType: _tripType,
                      roster: _roster.values.toList(),
                      onAdd: (s) => setState(
                          () => _roster[s.studentId] = s),
                      onRemove: (id) =>
                          setState(() => _roster.remove(id)),
                      l: l,
                    ),
                ],
              ),
            ),
            _SheetBar(
              loading: _starting,
              enabled: _canStart,
              onTap: _start,
              l: l,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bus chip (QR mode) ─────────────────────────────────────────────────

class _BusChipFromQr extends StatelessWidget {
  const _BusChipFromQr({required this.bus, required this.l});
  final BusSummaryDto bus;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.yellowTint,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.yellow),
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: AppColors.yellowDeep,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.plateNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                if (bus.model != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    bus.model!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emeraldSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded,
                    size: 10, color: AppColors.emerald),
                const SizedBox(width: 4),
                Text(
                  l.assistantBusFromQr,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bus picker (manual mode) ───────────────────────────────────────────

class _BusPicker extends ConsumerWidget {
  const _BusPicker({
    required this.selected,
    required this.onChanged,
    required this.l,
  });
  final BusSummaryDto? selected;
  final ValueChanged<BusSummaryDto?> onChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(busesListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SimpleLabel(text: l.assistantBusLabel),
        const SizedBox(height: 8),
        busesAsync.when(
          loading: () => _DropdownSkeleton(),
          error: (e, _) => _DropdownError(message: '$e'),
          data: (buses) => _DropdownShell(
            child: DropdownButton<BusSummaryDto>(
              value: selected,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(
                l.assistantSelectBus,
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              items: [
                for (final b in buses)
                  DropdownMenuItem(
                    value: b,
                    child: Text(
                      _busLabel(b),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _busLabel(BusSummaryDto b) {
    if (b.model == null || b.model!.isEmpty) return b.plateNumber;
    return '${b.plateNumber} · ${b.model}';
  }
}

// ─── Trip type row (Morning / Return as full cards) ─────────────────────

class _TripTypeRow extends StatelessWidget {
  const _TripTypeRow({
    required this.selected,
    required this.onChanged,
    required this.l,
  });
  final String selected;
  final ValueChanged<String> onChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TripTypeOpt(
            active: selected == 'Morning',
            color: const Color(0xFFD97706),
            colorSoft: const Color(0xFFFEF3C7),
            colorBorder: const Color(0xFFFDE68A),
            icon: Icons.wb_sunny_outlined,
            title: l.assistantTripTypeMorning,
            subtitle: l.assistantTripTypeMorningSub,
            onTap: () => onChanged('Morning'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TripTypeOpt(
            active: selected == 'Return',
            color: AppColors.violet,
            colorSoft: AppColors.violetSoft,
            colorBorder: const Color(0xFFDDD6FE),
            icon: Icons.nightlight_outlined,
            title: l.assistantTripTypeAfternoon,
            subtitle: l.assistantTripTypeAfternoonSub,
            onTap: () => onChanged('Return'),
          ),
        ),
      ],
    );
  }
}

class _TripTypeOpt extends StatelessWidget {
  const _TripTypeOpt({
    required this.active,
    required this.color,
    required this.colorSoft,
    required this.colorBorder,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool active;
  final Color color, colorSoft, colorBorder;
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: active
              ? LinearGradient(
                  colors: [colorSoft.withValues(alpha: 0.7), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : AppColors.slate200,
            width: active ? 1.6 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colorSoft,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: colorBorder),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
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

// ─── Driver auto-picker (pre-fills from the bus schedule) ───────────────

class _DriverAutoPicker extends ConsumerStatefulWidget {
  const _DriverAutoPicker({
    required this.busId,
    required this.tripType,
    required this.selected,
    required this.onChanged,
    required this.l,
  });
  final String busId;
  final String tripType;
  final DriverSummaryDto? selected;
  final ValueChanged<DriverSummaryDto?> onChanged;
  final AppLocalizations l;

  @override
  ConsumerState<_DriverAutoPicker> createState() => _DriverAutoPickerState();
}

class _DriverAutoPickerState extends ConsumerState<_DriverAutoPicker> {
  // Track the (bus, type) we already auto-applied so the user's manual
  // override isn't clobbered if the schedule's default fetch resolves late.
  String? _appliedKey;

  String get _key => '${widget.busId}|${widget.tripType}';

  @override
  Widget build(BuildContext context) {
    final defaultAsync = ref.watch(busDefaultDriverProvider(
      (busId: widget.busId, tripType: widget.tripType),
    ));

    defaultAsync.whenData((driver) {
      if (driver != null && _appliedKey != _key && widget.selected == null) {
        _appliedKey = _key;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onChanged(driver);
        });
      }
    });

    // Reuse the manual dropdown so the user can still override the
    // schedule's default driver if needed.
    return _DriverPicker(
      selected: widget.selected,
      onChanged: widget.onChanged,
      l: widget.l,
    );
  }
}

// ─── Driver picker ──────────────────────────────────────────────────────

class _DriverPicker extends ConsumerWidget {
  const _DriverPicker({
    required this.selected,
    required this.onChanged,
    required this.l,
  });
  final DriverSummaryDto? selected;
  final ValueChanged<DriverSummaryDto?> onChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driversListProvider);
    return driversAsync.when(
      loading: () => _DropdownSkeleton(),
      error: (e, _) => _DropdownError(message: '$e'),
      data: (drivers) => _DropdownShell(
        child: DropdownButton<DriverSummaryDto>(
          value: selected,
          isExpanded: true,
          underline: const SizedBox(),
          hint: Text(
            l.assistantSelectDriver,
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: [
            for (final d in drivers)
              DropdownMenuItem(
                value: d,
                child: Text(
                  '${d.fullName} · ${d.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Dropdown shell + skeleton + error ──────────────────────────────────

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

class _DropdownSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _DropdownError extends StatelessWidget {
  const _DropdownError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.redDark,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Simple label ───────────────────────────────────────────────────────

class _SimpleLabel extends StatelessWidget {
  const _SimpleLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.slate600,
        letterSpacing: 0.4,
      ),
    );
  }
}


// ─── Unified roster editor ──────────────────────────────────────────────
// Single source of truth for "students on this trip". Auto-seeds from the
// last trip on (bus, tripType); the parent screen owns the resulting map
// and exposes add/remove callbacks. Edits survive bus / type changes
// (parent decides when to re-seed). Three add paths: search by name, paste
// a student QR token, or — once camera support is in — a barcode reader
// (handled the same as paste).
class _RosterEditor extends ConsumerStatefulWidget {
  const _RosterEditor({
    required this.busId,
    required this.tripType,
    required this.roster,
    required this.onAdd,
    required this.onRemove,
    required this.l,
  });

  final String busId;
  final String tripType;
  final List<RosterStudentDto> roster;
  final ValueChanged<RosterStudentDto> onAdd;
  final ValueChanged<String> onRemove;
  final AppLocalizations l;

  @override
  ConsumerState<_RosterEditor> createState() => _RosterEditorState();
}

class _RosterEditorState extends ConsumerState<_RosterEditor> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Open the camera-based QR scanner. Resolves the scanned token to a
  /// student via /students/resolve-qr and appends to the roster. The
  /// scan screen handles permission / not-found errors itself.
  Future<void> _openQrSheet() async {
    final picked = await Navigator.of(context).push<RosterStudentDto>(
      MaterialPageRoute(
        builder: (_) => const AssistantSetupQrScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (picked != null) widget.onAdd(picked);
  }

  /// Open the NFC scanner. Same resolve endpoint as QR — the API accepts
  /// any token string, so an NFC UID round-trips to a RosterStudentDto
  /// exactly like a QR sticker token would.
  Future<void> _openNfcScanner() async {
    final picked = await Navigator.of(context).push<RosterStudentDto>(
      MaterialPageRoute(
        builder: (_) => const AssistantSetupNfcScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (picked != null) widget.onAdd(picked);
  }

  /// Pick the right name field for the current locale — Arabic UI shows
  /// FullName, everything else prefers FullNameEn when present and falls
  /// back to FullName otherwise.
  String _displayName(RosterStudentDto s) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return s.fullName;
    final en = s.fullNameEn;
    return (en != null && en.trim().isNotEmpty) ? en : s.fullName;
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final rosterIds = widget.roster.map((e) => e.studentId).toSet();
    // Pass the current UI locale so the server scopes the LIKE to either
    // FullName (ar) or FullNameEn (en) — see GetAllStudentsQueryHandler.
    final lang = Localizations.localeOf(context).languageCode == 'ar'
        ? 'ar'
        : 'en';
    final searchAsync = ref.watch(
      studentSearchProvider((query: _query, lang: lang)),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_2_rounded,
                  size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.assistantRosterHeader,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.roster.isEmpty
                      ? AppColors.slate100
                      : AppColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.roster.length}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: widget.roster.isEmpty
                        ? AppColors.slate500
                        : AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Two tap-to-scan cards, gated by the SuperAdmin feature flags
          // on the school's active subscription. Hide either when the
          // corresponding flag is off; collapse the section entirely
          // when both are off so the name-search input sits flush.
          Builder(builder: (context) {
            final fleet = ref.watch(myFleetSchoolProvider).valueOrNull;
            final showQr  = fleet?.enableQr  ?? true;
            final showNfc = fleet?.enableNfc ?? true;
            if (!showQr && !showNfc) return const SizedBox.shrink();
            final qr = _ScanCard(
              icon: Icons.qr_code_scanner_rounded,
              label: l.assistantScanQr,
              color: AppColors.violet,
              colorSoft: AppColors.violetSoft,
              onTap: _openQrSheet,
            );
            final nfc = _ScanCard(
              icon: Icons.nfc_rounded,
              label: l.assistantScanNfc,
              color: const Color(0xFF0EA5E9),
              colorSoft: const Color(0xFFE0F2FE),
              onTap: _openNfcScanner,
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
          }),
          const SizedBox(height: 10),
          // Search by name — full-width input. Server-side LIKE matches
          // both FullName (Arabic) and FullNameEn so the same query works
          // for either UI language; the result row picks the right field
          // to display.
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.assistantSearchByName,
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.slate200),
              ),
            ),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (_query.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            searchAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 18,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '$e',
                  style: const TextStyle(
                      color: AppColors.redDark, fontSize: 12),
                ),
              ),
              data: (results) {
                final visible = results
                    .where((s) => !rosterIds.contains(s.studentId))
                    .toList();
                if (visible.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      l.assistantNoResults,
                      style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }
                // Plain Column instead of nested ListView.separated: an
                // inner ListView inside the outer page ListView trips
                // "RenderBox was not laid out" assertions and freezes the
                // screen on tap. The result list is short (≤20 rows) so a
                // Column is fine.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      if (i > 0)
                        const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.slate100),
                      InkWell(
                        onTap: () {
                          widget.onAdd(visible[i]);
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _displayName(visible[i]),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.add_rounded,
                                  size: 18,
                                  color: AppColors.emerald),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
          // Picked students list with delete X
          if (widget.roster.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(
                height: 1, thickness: 1, color: AppColors.slate100),
            const SizedBox(height: 8),
            ...widget.roster.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _displayName(s),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.redDark),
                      onPressed: () => widget.onRemove(s.studentId),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                l.assistantRosterEmpty,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Start-trip bottom bar ──────────────────────────────────────────────

class _SheetBar extends StatelessWidget {
  const _SheetBar({
    required this.loading,
    required this.enabled,
    required this.onTap,
    required this.l,
  });
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: enabled ? onTap : null,
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ink,
                  ),
                )
              : const Icon(Icons.save_rounded, size: 18),
          // Step 1 of the two-step flow saves the trip in Scheduled status;
          // the assistant taps Start later on the trip-details screen.
          label: Text(l.assistantSaveTripCta),
        ),
      ),
    );
  }
}

// ─── Scan card (tap-to-scan for QR or NFC) ──────────────────────────────
// Square-ish card sitting under the search field. Two of these go side by
// side (QR + NFC). Each card just renders an icon + label; the parent
// hooks up onTap with the appropriate action (open dialog / start NFC /
// surface "not supported" snackbar).
class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.colorSoft,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color colorSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── QR / NFC add dialog (separate stateful widget) ──────────────────────
// Owning the TextEditingController + busy/error inside a StatefulWidget
// guarantees they're disposed when the dialog unmounts, and setState fires
// the rebuild properly (the previous closure-over-locals + StatefulBuilder
// approach disposed the controller too early and didn't trigger rebuilds).
class _QrAddDialog extends ConsumerStatefulWidget {
  const _QrAddDialog();

  @override
  ConsumerState<_QrAddDialog> createState() => _QrAddDialogState();
}

class _QrAddDialogState extends ConsumerState<_QrAddDialog> {
  final TextEditingController _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _ctrl.text.trim();
    if (token.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ds = ref.read(assistantRemoteDataSourceProvider);
      final student = await ds.resolveStudentQr(token);
      if (!mounted) return;
      if (student == null) {
        setState(() {
          _error = 'لا يوجد طالب لهذا الرمز';
          _busy = false;
        });
        return;
      }
      Navigator.of(context).pop(student);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Failure ? e.message : '$e';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طالب برمز QR / NFC'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctrl,
            enabled: !_busy,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'الصق رمز QR / NFC هنا',
              isDense: true,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.redDark, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.ink),
                )
              : const Text('إضافة'),
        ),
      ],
    );
  }
}
