import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/assistant_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Stand-in for a camera-based QR scanner. The iOS simulator can't access a
/// camera, so we accept manual token entry. On real devices we'd swap in
/// `mobile_scanner` and call the same [_submit] flow on detection.
class AssistantQrScanScreen extends ConsumerStatefulWidget {
  const AssistantQrScanScreen({super.key});

  @override
  ConsumerState<AssistantQrScanScreen> createState() =>
      _AssistantQrScanScreenState();
}

class _AssistantQrScanScreenState
    extends ConsumerState<AssistantQrScanScreen> {
  final _ctrl = TextEditingController();
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
    final scanned = await ref
        .read(scannedBusControllerProvider.notifier)
        .resolveQr(token);
    if (!mounted) return;
    if (scanned != null) {
      context.pushReplacement(AppRoute.assistantTripSetup);
      return;
    }
    final err = ref.read(scannedBusControllerProvider).error;
    setState(() {
      _busy = false;
      _error = _humaniseError(err);
    });
  }

  String _humaniseError(Object? err) {
    if (err is NotFoundFailure) return 'Bus not found for that token.';
    if (err is ForbiddenFailure) return 'You are not assigned to this bus.';
    if (err is NetworkFailure) return 'Network error.';
    if (err is Failure) return err.message;
    return 'Could not register scan.';
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.yellow, AppColors.yellowDeep],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.ink,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.assistantQrSimulatorTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.assistantQrSimulatorBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
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
                onPressed: _busy ? null : _submit,
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
        ),
      ),
    );
  }
}
