import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart' as nfca;
import 'package:nfc_manager/nfc_manager_ios.dart' as nfci;

import 'package:tilmez_bus/core/errors/failures.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/assistant/presentation/providers/trip_details_controllers.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Full-screen NFC reader for student pickup attendance. Opens an NFC
/// session, reads the tag UID, formats it as colon-separated uppercase
/// hex (matching the shape the back-end stores), and POSTs the same
/// /students/scan endpoint the QR camera uses — so an NFC card and a
/// QR sticker resolve interchangeably to the same student.
class AssistantNfcScanScreen extends ConsumerStatefulWidget {
  const AssistantNfcScanScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<AssistantNfcScanScreen> createState() =>
      _AssistantNfcScanScreenState();
}

class _AssistantNfcScanScreenState
    extends ConsumerState<AssistantNfcScanScreen> {
  NfcAvailability? _availability;
  bool _busy = false;
  String? _lastUid;
  // True while we're between our own `stopSession` and the next
  // `startSession`. iOS reports both user-cancel and our intentional
  // invalidation with the same error code, so we use this flag to tell
  // them apart: user cancels close the screen; our cycle does not.
  bool _intentionalStop = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    // Best-effort stop in case the user navigated away mid-session.
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
      invalidateAfterFirstReadIos: false,
      onSessionErrorIos: (err) {
        if (!mounted) return;
        // Ignore the invalidation that comes from our own `stopSession`
        // call inside the scan handler — we re-open a fresh session right
        // after the native ✓ animation completes.
        if (_intentionalStop) return;
        // User dismissed the popup OR iOS timed it out → close the
        // scan screen so the assistant returns to the trip details.
        const closeCodes = {
          nfci.NfcReaderErrorCodeIos
              .readerSessionInvalidationErrorUserCanceled,
          nfci.NfcReaderErrorCodeIos
              .readerSessionInvalidationErrorSessionTimeout,
        };
        if (closeCodes.contains(err.code)) {
          if (context.canPop()) context.pop();
          return;
        }
      },
      onDiscovered: _onDiscovered,
    );
  }

  Future<void> _onDiscovered(NfcTag tag) async {
    if (_busy) return;
    final uid = _extractUid(tag);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NFC] discovered tag → uid=$uid');
    }
    if (uid == null || uid.isEmpty) {
      // Android has no native success/error popup, so without this the
      // user just hears the OS beep and assumes the scanner is broken.
      // iOS gets the same feedback via the system NFC popup.
      if (Platform.isAndroid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).assistantScanStudentNotFound)),
        );
        unawaited(HapticFeedback.heavyImpact());
      }
      return;
    }
    if (uid == _lastUid) return;
    _lastUid = uid;
    // Immediate haptic so the assistant feels the tap landed even before
    // iOS plays its native session-end chime.
    unawaited(HapticFeedback.heavyImpact());
    _busy = true;
    final l = AppLocalizations.of(context);
    String? successMsg;
    String? errorMsg;
    try {
      final name = await ref
          .read(tripActionsProvider(widget.tripId))
          .scanStudent(uid);
      successMsg = name != null && name.isNotEmpty
          ? '${l.assistantScanStudentOk} — $name'
          : l.assistantScanStudentOk;
    } catch (e) {
      errorMsg = e is Failure ? e.message : '$e';
    }

    // Success: close the scan screen with the message so the parent
    // trip-details screen renders the confirmation snackbar. Failure:
    // stay on this screen so the assistant can retry without backing
    // out of the flow.
    if (successMsg != null) {
      if (Platform.isIOS) {
        // iOS: play the native ✓ animation + chime on the system popup
        // before navigating away. The intentional flag stops the error
        // callback from racing the pop.
        _intentionalStop = true;
        await NfcManager.instance.stopSession(alertMessageIos: successMsg);
      }
      // Android: leave Reader Mode running until dispose() — calling
      // stopSession here while the card is still in range is what was
      // firing the "No supported application for this NFC tag" toast.
      if (!mounted) {
        _intentionalStop = false;
        return;
      }
      context.pop(successMsg);
      return;
    }

    // Error path. Same idea — on iOS show the native ✗ first, on
    // Android show an inline snackbar — then leave the scanner open
    // for another attempt.
    if (Platform.isIOS) {
      _intentionalStop = true;
      await NfcManager.instance.stopSession(errorMessageIos: errorMsg);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) {
        _intentionalStop = false;
        return;
      }
      _busy = false;
      _lastUid = null;
      await _startSession();
      _intentionalStop = false;
    } else {
      if (mounted && errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      _busy = false;
      _lastUid = null;
    }
  }

  /// Extract the tag UID as colon-separated uppercase hex
  /// (e.g. `04:11:8D:AA:36:67:81`). Platform-gated: calling an iOS
  /// extractor on Android throws TypeError on the underlying
  /// `tag.data as TagPigeon?` cast — the Android plugin emits its own
  /// `TagPigeon` class which doesn't satisfy the iOS-side cast — so we
  /// only invoke extractors matching the current platform.
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
            alignment: const Alignment(0, -0.35),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _NfcPulse(),
                  const SizedBox(height: 28),
                  Text(
                    unsupported
                        ? l.assistantNfcUnsupported
                        : disabled
                            ? l.assistantNfcDisabled
                            : l.assistantScanStudentHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.5,
                    ),
                  ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                      ],
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

/// Animated NFC chip with two outward-rippling halos so the assistant
/// has visual confirmation that the scanner is live and listening.
class _NfcPulse extends StatefulWidget {
  const _NfcPulse();
  @override
  State<_NfcPulse> createState() => _NfcPulseState();
}

class _NfcPulseState extends State<_NfcPulse>
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        Widget ring(double phase) {
          final t = (_ctrl.value + phase) % 1.0;
          final size = 96 + 100 * t;
          final opacity = (1 - t).clamp(0.0, 1.0) * 0.55;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.yellow.withValues(alpha: opacity),
            ),
          );
        }
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ring(0),
              ring(0.5),
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.yellow, AppColors.yellowDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.yellow.withValues(alpha: 0.55),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.nfc, size: 44, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
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

