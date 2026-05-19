import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

class AssistantQrScanScreen extends ConsumerStatefulWidget {
  const AssistantQrScanScreen({super.key});

  @override
  ConsumerState<AssistantQrScanScreen> createState() =>
      _AssistantQrScanScreenState();
}

class _AssistantQrScanScreenState
    extends ConsumerState<AssistantQrScanScreen> {
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  final TextEditingController _manualCtrl = TextEditingController();
  bool _busy = false;
  bool _manualMode = false;
  String? _error;
  String? _lastSubmitted;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String token) async {
    final t = token.trim();
    if (t.isEmpty || _busy) return;
    // Guard against the scanner firing the same code twice in a row.
    if (t == _lastSubmitted) return;
    _lastSubmitted = t;
    setState(() {
      _busy = true;
      _error = null;
    });
    await _scannerCtrl.stop();
    final scanned = await ref
        .read(scannedBusControllerProvider.notifier)
        .resolveQr(t);
    if (!mounted) return;
    if (scanned != null) {
      context.pushReplacement(AppRoute.assistantTripSetup);
      return;
    }
    final err = ref.read(scannedBusControllerProvider).error;
    setState(() {
      _busy = false;
      _error = _humaniseError(err);
      _lastSubmitted = null;
    });
    // Restart the camera so the user can try another code.
    await _scannerCtrl.start();
  }

  String _humaniseError(Object? err) {
    if (err is NotFoundFailure) return 'Bus not found for that token.';
    if (err is ForbiddenFailure) return 'You are not assigned to this bus.';
    if (err is NetworkFailure) return 'Network error.';
    if (err is Failure) return err.message;
    return 'Could not register scan.';
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) _submit(code);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l.assistantScanBusQr),
        actions: [
          IconButton(
            tooltip: _manualMode ? 'Use camera' : 'Enter manually',
            icon: Icon(
              _manualMode
                  ? Icons.qr_code_scanner_rounded
                  : Icons.keyboard_rounded,
            ),
            onPressed: () => setState(() => _manualMode = !_manualMode),
          ),
          if (!_manualMode)
            IconButton(
              tooltip: 'Toggle torch',
              icon: const Icon(Icons.flash_on_rounded),
              onPressed: () => _scannerCtrl.toggleTorch(),
            ),
        ],
      ),
      body: SafeArea(
        child: _manualMode ? _buildManualEntry(l) : _buildScanner(),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(controller: _scannerCtrl, onDetect: _onDetect),
        // Translucent frame overlay
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.yellow, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        if (_error != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.redDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_busy)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildManualEntry(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _manualCtrl,
            enabled: !_busy,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-_]')),
            ],
            decoration: InputDecoration(
              hintText: l.assistantQrEntryHint,
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.redDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: _busy ? null : () => _submit(_manualCtrl.text),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ink,
                    ),
                  )
                : Text(l.assistantQrEntryConfirm),
          ),
        ],
      ),
    );
  }
}
