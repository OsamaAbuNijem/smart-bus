import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Full-screen camera scanner used by the assistant on a live trip to
/// mark a student as picked up. Reads any QR; if the value looks like
/// the `/q/<token>` URL the public sticker encodes, the trailing
/// segment is treated as the token. Anything else is passed through
/// as a raw token so future shapes (NFC, manual barcode) still work.
///
/// Camera stays running between scans — assistant can swing the bus
/// from kid to kid without re-opening the screen. Each successful
/// scan flashes a green snackbar; errors show in red and the scanner
/// resumes after a moment.
class AssistantStudentScanScreen extends ConsumerStatefulWidget {
  const AssistantStudentScanScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<AssistantStudentScanScreen> createState() =>
      _AssistantStudentScanScreenState();
}

class _AssistantStudentScanScreenState
    extends ConsumerState<AssistantStudentScanScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _busy = false;
  String? _lastSubmitted;
  String? _lastResult;
  bool _lastOk = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Extract the trailing /q/<token> segment from a URL, or return the
  /// raw input when it isn't a URL (legacy sticker tokens, manual
  /// entries from a future input mode).
  static String _extractToken(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme) return t;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return t;
    final qIdx = segments.indexOf('q');
    if (qIdx >= 0 && qIdx + 1 < segments.length) {
      return segments[qIdx + 1];
    }
    return segments.last;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    final token = _extractToken(raw);
    if (token.isEmpty || token == _lastSubmitted) return;
    _lastSubmitted = token;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    try {
      await ref
          .read(tripActionsProvider(widget.tripId))
          .scanStudent(token);
      if (!mounted) return;
      setState(() {
        _lastOk = true;
        _lastResult = l.assistantScanStudentOk;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastOk = false;
        _lastResult = e is Failure ? e.message : '$e';
      });
    }
    // Brief debounce so the assistant sees the result before another
    // QR in view fires a second scan.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastSubmitted = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          // Dim everything except a center square so the assistant has a
          // clear target zone for the QR.
          const _ScannerOverlay(),

          // Top bar: back + title
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  children: [
                    _GlassBtn(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
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
                    _GlassBtn(
                      icon: Icons.flash_on_rounded,
                      onTap: () => _ctrl.toggleTorch(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom status pill — green when last scan landed, red on
          // error, neutral guidance otherwise.
          Positioned(
            left: 16, right: 16, bottom: 32,
            child: SafeArea(
              top: false,
              child: _StatusPill(
                ok: _lastOk,
                result: _lastResult,
                busy: _busy,
                hint: l.assistantScanStudentHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final size = c.maxWidth * 0.7;
      return Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 60,
                spreadRadius: 200,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _GlassBtn extends StatelessWidget {
  const _GlassBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.ok,
    required this.result,
    required this.busy,
    required this.hint,
  });
  final bool ok;
  final String? result;
  final bool busy;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final showResult = result != null;
    final bg = showResult
        ? (ok ? AppColors.emerald : AppColors.red)
        : Colors.white;
    final fg = showResult ? Colors.white : AppColors.ink;
    final icon = showResult
        ? (ok ? Icons.check_rounded : Icons.error_outline_rounded)
        : Icons.qr_code_scanner_rounded;
    final text = showResult ? result! : hint;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (busy)
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: fg,
              ),
            )
          else
            Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
