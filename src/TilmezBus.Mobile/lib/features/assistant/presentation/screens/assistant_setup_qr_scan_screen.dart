import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Camera scanner used while *setting up* a new trip — resolves the
/// scanned QR/URL to a [RosterStudentDto] and pops with it, so the
/// caller can append it to the in-memory roster. No tripId yet, so
/// nothing is persisted server-side; the live-trip flow's
/// AssistantStudentScanScreen handles boarding instead.
class AssistantSetupQrScanScreen extends ConsumerStatefulWidget {
  const AssistantSetupQrScanScreen({super.key});

  @override
  ConsumerState<AssistantSetupQrScanScreen> createState() =>
      _AssistantSetupQrScanScreenState();
}

class _AssistantSetupQrScanScreenState
    extends ConsumerState<AssistantSetupQrScanScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _busy = false;
  String? _lastSubmitted;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Mirrors AssistantStudentScanScreen._extractToken — URL stickers of
  /// shape /q/<token> get unwrapped, anything else passes through raw.
  static String _extractToken(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme) return t;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return t;
    final qIdx = segments.indexOf('q');
    if (qIdx >= 0 && qIdx + 1 < segments.length) return segments[qIdx + 1];
    return segments.last;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    final token = _extractToken(raw);
    if (token.isEmpty || token == _lastSubmitted) return;
    _lastSubmitted = token;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final student = await ref
          .read(assistantRemoteDataSourceProvider)
          .resolveStudentQr(token);
      if (!mounted) return;
      if (student == null) {
        setState(() {
          _error = l.assistantScanStudentNotFound;
          _busy = false;
        });
        // Reset debounce so re-aiming at a valid sticker fires again.
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        setState(() => _lastSubmitted = null);
        return;
      }
      Navigator.of(context).pop(student);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Failure ? e.message : '$e';
        _busy = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _lastSubmitted = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.30)),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.assistantScanStudentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_busy || _error != null)
            Positioned(
              left: 16, right: 16, bottom: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _error != null ? AppColors.red : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    if (_busy)
                      const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: AppColors.ink),
                      )
                    else
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _error ?? l.assistantScanLooking,
                        style: TextStyle(
                          color: _error != null
                              ? Colors.white
                              : AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
