import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart' as nfca;
import 'package:nfc_manager/nfc_manager_ios.dart' as nfci;

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// NFC scanner used while setting up a new trip — reads a student's
/// card UID, resolves it server-side to a [RosterStudentDto] (same
/// `/students/resolve-qr` endpoint that the QR sticker scanner uses;
/// the API accepts any token string), and pops with the student so
/// the trip-setup screen can append it to the in-memory roster.
class AssistantSetupNfcScanScreen extends ConsumerStatefulWidget {
  const AssistantSetupNfcScanScreen({super.key});

  @override
  ConsumerState<AssistantSetupNfcScanScreen> createState() =>
      _AssistantSetupNfcScanScreenState();
}

class _AssistantSetupNfcScanScreenState
    extends ConsumerState<AssistantSetupNfcScanScreen> {
  NfcAvailability? _availability;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    unawaited(NfcManager.instance.stopSession());
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final a = await NfcManager.instance.checkAvailability();
      if (!mounted) return;
      setState(() => _availability = a);
      if (a == NfcAvailability.enabled) {
        await _startSession();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _availability = NfcAvailability.unsupported);
    }
  }

  Future<void> _startSession() async {
    final l = AppLocalizations.of(context);
    await NfcManager.instance.startSession(
      pollingOptions: const {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      alertMessageIos: l.assistantScanStudentHint,
      invalidateAfterFirstReadIos: true,
      onSessionErrorIos: (err) {
        if (!mounted) return;
        // Closing the sheet (user cancel / timeout) returns us to the
        // setup screen with no selection — that's the right behaviour.
        if (err.code == nfci.NfcReaderErrorCodeIos
                .readerSessionInvalidationErrorUserCanceled ||
            err.code == nfci.NfcReaderErrorCodeIos
                .readerSessionInvalidationErrorSessionTimeout) {
          if (context.canPop()) context.pop();
        }
      },
      onDiscovered: _onDiscovered,
    );
  }

  Future<void> _onDiscovered(NfcTag tag) async {
    if (_busy) return;
    final uid = _extractUid(tag);
    if (uid == null || uid.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final student = await ref
          .read(assistantRemoteDataSourceProvider)
          .resolveStudentQr(uid);
      await NfcManager.instance.stopSession(
        alertMessageIos: student != null
            ? l.assistantScanStudentOk
            : l.assistantScanStudentNotFound,
        errorMessageIos: student == null ? l.assistantScanStudentNotFound : null,
      );
      if (!mounted) return;
      if (student == null) {
        setState(() {
          _error = l.assistantScanStudentNotFound;
          _busy = false;
        });
        return;
      }
      Navigator.of(context).pop(student);
    } catch (e) {
      await NfcManager.instance.stopSession();
      if (!mounted) return;
      setState(() {
        _error = e is Failure ? e.message : '$e';
        _busy = false;
      });
    }
  }

  /// See assistant_nfc_scan_screen.dart for why this is platform-gated:
  /// iOS extractors throw TypeError on the Android-side TagPigeon.
  static String? _extractUid(NfcTag tag) {
    Uint8List? bytes;
    if (Platform.isIOS) {
      bytes ??= nfci.MiFareIos.from(tag)?.identifier;
      bytes ??= nfci.Iso7816Ios.from(tag)?.identifier;
      bytes ??= nfci.Iso15693Ios.from(tag)?.identifier;
    } else if (Platform.isAndroid) {
      bytes ??= nfca.NfcTagAndroid.from(tag)?.id;
    }
    if (bytes == null || bytes.isEmpty) return null;
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unsupported = _availability == NfcAvailability.unsupported;
    final disabled = _availability == NfcAvailability.disabled;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.yellow, AppColors.yellowDeep],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.nfc, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    unsupported
                        ? l.assistantNfcUnsupported
                        : disabled
                            ? l.assistantNfcDisabled
                            : (_error ?? l.assistantScanStudentHint),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.5,
                    ),
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 18),
                    const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    ),
                  ],
                ],
              ),
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
        ],
      ),
    );
  }
}
