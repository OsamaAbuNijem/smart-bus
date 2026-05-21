import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/parent/domain/entities/student_info.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/parent_controllers.dart';
import 'package:tilmez_bus/features/parent/presentation/providers/student_edit_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

class StudentInfoScreen extends ConsumerWidget {
  const StudentInfoScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final infoAsync = ref.watch(studentInfoProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (info) => _Form(info: info, studentId: studentId, l: l),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({
    required this.info,
    required this.studentId,
    required this.l,
  });
  final StudentInfo info;
  final String studentId;
  final AppLocalizations l;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.info.notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = widget.l;
    final info = widget.info;
    FocusScope.of(context).unfocus();
    // Only the note is editable on this screen — every other field is read
    // from the persisted info, so we pass them through unchanged.
    final ok = await ref
        .read(studentEditControllerProvider(widget.studentId).notifier)
        .save(
          fullName: info.fullName,
          grade: info.grade,
          className: info.className,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          parentName: info.parent?.name ?? '',
          parentPhone: info.parent?.phoneNumber ?? '',
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.studentEditSaved)));
      return;
    }
    final err =
        ref.read(studentEditControllerProvider(widget.studentId)).error;
    final msg = switch (err) {
      ValidationFailure(:final message) when message.isNotEmpty => message,
      Failure() => l.studentEditFailed,
      _ => l.studentEditFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final info = widget.info;
    final saving =
        ref.watch(studentEditControllerProvider(widget.studentId)).isLoading;

    return Column(
      children: [
        _Hero(l: l, onBack: () => context.pop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            children: [
              _AvatarBanner(name: info.fullName),
              const SizedBox(height: 14),
              _SectionTitle(text: l.studentEditBasicInfo),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _ReadOnlyField(
                    icon: Icons.person_outline,
                    label: l.studentEditFullName,
                    value: info.fullName,
                  ),
                  _ReadOnlyField(
                    icon: Icons.badge_outlined,
                    label: l.studentEditStudentId,
                    value: info.nationalNumber,
                  ),
                  // Always show the student's home address. Cascade:
                  //   1. full "street, building, area" if present
                  //   2. just the area name
                  //   3. reverse-geocoded label from the saved coordinates
                  //   4. "—"
                  _HomeAddressField(info: info, label: l.studentInfoHomeAddress),
                ],
              ),
              if (info.homeLatitude != null && info.homeLongitude != null) ...[
                const SizedBox(height: 14),
                _HomeMap(
                  latitude: info.homeLatitude!,
                  longitude: info.homeLongitude!,
                ),
              ],
              const SizedBox(height: 14),
              _SectionTitle(text: l.studentInfoSchool),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _ReadOnlyField(
                    icon: Icons.account_balance_outlined,
                    label: l.studentInfoSchool,
                    value: info.schoolName == null || info.schoolName!.isEmpty
                        ? '—'
                        : info.schoolName!,
                  ),
                  _ReadOnlyField(
                    icon: Icons.place_outlined,
                    label: l.studentInfoSchoolAddress,
                    value: info.schoolAddress == null || info.schoolAddress!.isEmpty
                        ? '—'
                        : info.schoolAddress!,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionTitle(text: l.studentEditNotes),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _TextAreaField(
                    icon: Icons.description_outlined,
                    label: l.studentEditDriverNote,
                    controller: _notesCtrl,
                    enabled: !saving,
                    hint: l.studentEditNotesHint,
                  ),
                ],
              ),
            ],
          ),
        ),
        _SaveBar(
          saveText: l.studentEditSave,
          saving: saving,
          onSave: saving ? null : _save,
        ),
      ],
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.l, required this.onBack});
  final AppLocalizations l;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
              onTap: onBack,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.studentInfoTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
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

// ─── Avatar banner ──────────────────────────────────────────────────

class _AvatarBanner extends StatelessWidget {
  const _AvatarBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.yellowTint,
              border: Border.all(color: const Color(0x66F5C518)),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.yellowDeep,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name.isEmpty ? '—' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppColors.slate500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─── Card + fields (mirrors edit screen but flatter) ───────────────

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.slate100,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.icon,
    required this.label,
    required this.child,
    this.labelTag,
    this.borderRight = false,
  });
  final IconData icon;
  final String label;
  final Widget child;
  final String? labelTag;
  final bool borderRight;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 42,
            decoration: BoxDecoration(
              border: Border(
                right: isRtl
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.slate100),
                left: isRtl
                    ? const BorderSide(color: AppColors.slate100)
                    : BorderSide.none,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.slate400),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 8),
              decoration: BoxDecoration(
                border: Border(
                  right: borderRight && !isRtl
                      ? const BorderSide(color: AppColors.slate100)
                      : BorderSide.none,
                  left: borderRight && isRtl
                      ? const BorderSide(color: AppColors.slate100)
                      : BorderSide.none,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate500,
                          letterSpacing: 0.7,
                        ),
                      ),
                      if (labelTag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            labelTag!,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
    this.labelTag,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? labelTag;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      labelTag: labelTag,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.slate500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  const _TextAreaField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.hint,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      icon: icon,
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.45,
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.slate400,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          filled: false,
        ),
      ),
    );
  }
}

// ─── Save bar ──────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saveText,
    required this.saving,
    required this.onSave,
  });
  final String saveText;
  final bool saving;
  final VoidCallback? onSave;

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
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
              disabledBackgroundColor:
                  AppColors.yellow.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            child: saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.ink,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.ink),
                      const SizedBox(width: 7),
                      Text(saveText),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────

// ─── Home address with reverse-geocode fallback ─────────────────────────────
//
// When the student's address text is empty but lat/lng are saved we ask
// Nominatim (OpenStreetMap's free reverse-geocoder) for a human-readable
// label. The result is cached for the app's lifetime so we don't re-query
// every time the parent re-opens the screen.

class _HomeAddressField extends StatefulWidget {
  const _HomeAddressField({required this.info, required this.label});
  final StudentInfo info;
  final String label;

  @override
  State<_HomeAddressField> createState() => _HomeAddressFieldState();
}

class _HomeAddressFieldState extends State<_HomeAddressField> {
  String? _resolved;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _maybeReverseGeocode();
  }

  Future<void> _maybeReverseGeocode() async {
    final info = widget.info;
    // Skip if we already have a usable address from the API.
    final hasText = info.homeAddress.trim().isNotEmpty ||
        (info.homeArea?.trim().isNotEmpty ?? false);
    if (hasText) return;
    final lat = info.homeLatitude;
    final lng = info.homeLongitude;
    if (lat == null || lng == null) return;

    setState(() => _loading = true);
    try {
      final label = await _reverseGeocode(lat, lng);
      if (!mounted) return;
      setState(() {
        _resolved = label;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (kDebugMode) {
        // ignore: avoid_print
        print('[reverse-geocode] failed: $e');
      }
    }
  }

  String _displayValue() {
    final info = widget.info;
    if (info.homeAddress.trim().isNotEmpty) return info.homeAddress;
    final area = info.homeArea?.trim();
    if (area != null && area.isNotEmpty) return area;
    if (_resolved != null && _resolved!.isNotEmpty) return _resolved!;
    if (_loading) return '…';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return _ReadOnlyField(
      icon: Icons.location_on_outlined,
      label: widget.label,
      value: _displayValue(),
    );
  }
}

// In-memory cache so each session only hits Nominatim once per coord pair.
final Map<String, String> _reverseGeocodeCache = {};
Dio? _geocodeDio;

Future<String> _reverseGeocode(double lat, double lng) async {
  // Round to 4 decimals (~11m) for the cache key — same building hits the
  // same key regardless of GPS jitter.
  final key = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
  final cached = _reverseGeocodeCache[key];
  if (cached != null) return cached;

  _geocodeDio ??= Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      // Nominatim's usage policy requires a unique User-Agent identifying
      // the application; otherwise requests are silently throttled.
      'User-Agent': 'TilmezBusMobile/1.0 (https://tilmezbus.com)',
    },
  ));

  final res = await _geocodeDio!.get<dynamic>(
    'https://nominatim.openstreetmap.org/reverse',
    queryParameters: {
      'lat': lat,
      'lon': lng,
      'format': 'json',
      'zoom': '14',
      'addressdetails': '1',
      'accept-language': 'ar,en',
    },
  );

  final data = res.data is Map<String, dynamic>
      ? res.data as Map<String, dynamic>
      : (res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : <String, dynamic>{});
  final addr = (data['address'] as Map<String, dynamic>?) ?? const {};
  // Prefer the most specific neighbourhood label we can find before falling
  // back to the full display_name.
  String? pick(String k) {
    final v = addr[k];
    return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
  }
  final label = pick('neighbourhood') ??
      pick('suburb') ??
      pick('quarter') ??
      pick('village') ??
      pick('town') ??
      pick('city') ??
      (data['display_name'] as String?) ??
      '';
  _reverseGeocodeCache[key] = label;
  return label;
}

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

// ─── Home location map preview ──────────────────────────────────────────────

class _HomeMap extends StatelessWidget {
  const _HomeMap({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 15,
          // Read-only preview — disable all gestures so it doesn't fight
          // the parent ListView scroll.
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.smartbus.tilmez_bus',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 36,
                height: 36,
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.yellowDeep,
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
