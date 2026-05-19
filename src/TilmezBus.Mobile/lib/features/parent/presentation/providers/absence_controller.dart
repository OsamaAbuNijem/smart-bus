import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/parent/data/repositories/parent_repository.dart';
import 'package:smart_bus/features/parent/presentation/providers/parent_controllers.dart';

part 'absence_controller.g.dart';

enum AbsenceTripType { fullDay, morningOnly, returnOnly }

extension AbsenceTripTypeApi on AbsenceTripType {
  String get apiValue => switch (this) {
        AbsenceTripType.fullDay => 'FullDay',
        AbsenceTripType.morningOnly => 'MorningOnly',
        AbsenceTripType.returnOnly => 'ReturnOnly',
      };
}

enum AbsenceReason { illness, medicalAppointment, familyMatter, other }

extension AbsenceReasonApi on AbsenceReason {
  String get apiValue => switch (this) {
        AbsenceReason.illness => 'Illness',
        AbsenceReason.medicalAppointment => 'MedicalAppointment',
        AbsenceReason.familyMatter => 'FamilyMatter',
        AbsenceReason.other => 'Other',
      };
}

/// One-shot submit controller for the Report Absence screen.
@riverpod
class AbsenceController extends _$AbsenceController {
  @override
  AsyncValue<void> build(String studentId) => const AsyncData(null);

  Future<bool> submit({
    required DateTime date,
    required AbsenceTripType tripType,
    required AbsenceReason reason,
    String? driverNote,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(() async {
      await ref.read(parentRepositoryProvider).submitAbsenceRequest(
            studentId: studentId,
            date: date,
            tripType: tripType.apiValue,
            reason: reason.apiValue,
            driverNote: driverNote,
          );
    });
    state = result;
    if (!result.hasError) {
      // Trip history may now show the absence; refresh the cached trips.
      ref.invalidate(tripHistoryProvider(studentId));
      ref.invalidate(childTripsProvider(studentId));
    }
    return !result.hasError;
  }
}
