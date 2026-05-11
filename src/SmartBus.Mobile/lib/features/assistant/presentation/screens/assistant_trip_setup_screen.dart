import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/errors/failures.dart';
import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/assistant/data/models/bus_summary_dto.dart';
import 'package:smart_bus/features/assistant/data/models/driver_summary_dto.dart';
import 'package:smart_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:smart_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

/// State 2 (post-QR) and State 3 (manual) trip-setup screen.
/// In QR mode, the bus is locked to whatever the scan resolved (rendered as
/// a chip with "From QR"). In manual mode, the bus is selectable.
/// In both modes the assistant picks driver + trip type, and the students
/// are pulled live from the last trip on (bus, type).
class AssistantTripSetupScreen extends ConsumerStatefulWidget {
  const AssistantTripSetupScreen({super.key});

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
  bool _skipRoster = false;

  @override
  void initState() {
    super.initState();
    // In QR mode the bus is already in the controller — pick it up here so
    // the user can't change it. In manual mode it stays null until the user
    // picks one from the dropdown.
    final scanned = ref.read(scannedBusControllerProvider).valueOrNull;
    _selectedBus = scanned;
  }

  bool get _isQrMode => ref.read(scannedBusControllerProvider).valueOrNull != null;

  bool get _canStart =>
      !_starting && _selectedBus != null && _selectedDriver != null;

  Future<void> _start() async {
    if (!_canStart) return;
    setState(() => _starting = true);
    try {
      final action = ref.read(startTripActionProvider);
      final result = await action(
        busId: _selectedBus!.id,
        driverId: _selectedDriver!.id,
        tripType: _tripType,
        skipRoster: _skipRoster,
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
        title: Text(l.assistantTripSetupTitle),
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
                      onChanged: (b) => setState(() => _selectedBus = b),
                      l: l,
                    ),
                  const SizedBox(height: 14),
                  _SimpleLabel(text: l.assistantTripTypeLabel),
                  const SizedBox(height: 8),
                  _TripTypeRow(
                    selected: _tripType,
                    onChanged: (t) => setState(() => _tripType = t),
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
                    _StudentsStrip(
                      busId: _selectedBus!.id,
                      tripType: _tripType,
                      skip: _skipRoster,
                      onSkipChanged: (v) =>
                          setState(() => _skipRoster = v),
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

// ─── Trip type row ──────────────────────────────────────────────────────

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

// ─── Students strip (live last-roster) ──────────────────────────────────

class _StudentsStrip extends ConsumerWidget {
  const _StudentsStrip({
    required this.busId,
    required this.tripType,
    required this.skip,
    required this.onSkipChanged,
    required this.l,
  });
  final String busId;
  final String tripType;
  final bool skip;
  final ValueChanged<bool> onSkipChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(
      lastRosterProvider((busId: busId, tripType: tripType)),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: rosterAsync.when(
        loading: () => const SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (e, _) => Text(
          '$e',
          style: const TextStyle(color: AppColors.redDark, fontSize: 12),
        ),
        data: (students) {
          if (students.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                l.assistantNoLastRoster,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          // Dim the auto-roster preview while skipped so the toggle's
          // effect is immediately obvious without re-fetching. Tap the
          // preview to open a sheet showing the whole list.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _showRosterSheet(context, students, l),
                child: Opacity(
                  opacity: skip ? 0.45 : 1,
                  child:
                      _StudentsStripContent(students: students, l: l),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                  height: 1, thickness: 1, color: AppColors.slate100),
              const SizedBox(height: 6),
              _SkipRosterRow(
                value: skip,
                onChanged: onSkipChanged,
                l: l,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkipRosterRow extends StatelessWidget {
  const _SkipRosterRow({
    required this.value,
    required this.onChanged,
    required this.l,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.assistantSkipRoster,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.assistantSkipRosterHint,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.yellowDeep,
        ),
      ],
    );
  }
}

Future<void> _showRosterSheet(
  BuildContext context,
  List<RosterStudentDto> students,
  AppLocalizations l,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.assistantRosterSheetTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.yellowTint,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0x66F5C518)),
                  ),
                  child: Text(
                    '${students.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.yellowDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate100),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: students.length,
              separatorBuilder: (_, _) => const Divider(
                  height: 1, thickness: 1, color: AppColors.slate100),
              itemBuilder: (context, i) {
                final s = students[i];
                final initials = _rosterInitials(s.fullName);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.slate100,
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                  title: Text(
                    s.fullName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

String _rosterInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '·';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

class _StudentsStripContent extends StatelessWidget {
  const _StudentsStripContent({required this.students, required this.l});
  final List<RosterStudentDto> students;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final shown = students.take(4).toList();
    final extra = students.length - shown.length;
    final palette = const [
      [Color(0xFFFECACA), Color(0xFFF87171), Color(0xFF7F1D1D)],
      [Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF1E40AF)],
      [Color(0xFFFEF3C7), Color(0xFFFCD34D), Color(0xFF92400E)],
      [Color(0xFFDDD6FE), Color(0xFFA78BFA), Color(0xFF5B21B6)],
    ];
    final stackWidth = 32 +
        (shown.isEmpty ? 0 : (shown.length - 1) * 22) +
        (extra > 0 ? 22 : 0);

    return Row(
      children: [
        SizedBox(
          width: stackWidth.toDouble(),
          height: 32,
          child: Stack(
            children: [
              for (var i = 0; i < shown.length; i++)
                Positioned(
                  left: i * 22.0,
                  child: _Avatar(
                    text: _initials(shown[i].fullName),
                    bg1: palette[i % palette.length][0],
                    bg2: palette[i % palette.length][1],
                    fg: palette[i % palette.length][2],
                  ),
                ),
              if (extra > 0)
                Positioned(
                  left: shown.length * 22.0,
                  child: _Avatar(
                    text: '+$extra',
                    bg1: AppColors.slate100,
                    bg2: AppColors.slate200,
                    fg: AppColors.slate600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${students.length} ${l.assistantStudents}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.assistantStudentsAuto,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
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
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg1, bg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Sheet bar ──────────────────────────────────────────────────────────

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
              : const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(l.assistantStartTrip),
        ),
      ),
    );
  }
}
