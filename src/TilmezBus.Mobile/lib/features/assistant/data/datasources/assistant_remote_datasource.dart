import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tilmez_bus/core/network/api_exception.dart';
import 'package:tilmez_bus/core/network/dio_client.dart';
import 'package:tilmez_bus/features/assistant/data/models/bus_summary_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/driver_summary_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/my_today_trip_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/start_trip_response_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_details_dto.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_student_dto.dart';

class AssistantRemoteDataSource {
  AssistantRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<MyTodayTripDto>> getMyTodayTrips() async {
    try {
      final response = await _dio.get<List<dynamic>>('/trips/my-today');
      final list = response.data ?? const [];
      return list
          .map((e) => MyTodayTripDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Resolve a bus by its QR token. Does NOT create a trip.
  Future<BusSummaryDto> getBusByQr(String qrToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/buses/by-qr',
        data: {'qrToken': qrToken},
      );
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return BusSummaryDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// All buses (paginated; first page is enough for the dropdown).
  Future<List<BusSummaryDto>> getBuses() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/buses',
        queryParameters: {'pageSize': 100},
      );
      final items = (response.data?['items'] as List<dynamic>?) ?? const [];
      return items
          .map((e) => BusSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Drivers (filtered to DriverType=Driver — assistants are excluded).
  Future<List<DriverSummaryDto>> getDrivers() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/drivers',
        queryParameters: {'pageSize': 100, 'driverType': 0}, // 0 = Driver
      );
      final items = (response.data?['items'] as List<dynamic>?) ?? const [];
      return items
          .map((e) => DriverSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Default driver assigned to this bus + trip type via the bus schedule.
  /// Returns null when no schedule entry exists for the requested leg.
  Future<DriverSummaryDto?> getDefaultDriver({
    required String busId,
    required String tripType,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/buses/$busId/default-driver',
        queryParameters: {'tripType': tripType},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return DriverSummaryDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Students from the most recent trip on this bus + trip type.
  Future<List<RosterStudentDto>> getLastRoster({
    required String busId,
    required String tripType, // "Morning" | "Return"
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/buses/$busId/last-roster',
        queryParameters: {'tripType': tripType},
      );
      final list = response.data ?? const [];
      return list
          .map((e) => RosterStudentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Create + start a new trip. Pass [skipRoster] = true to materialise an
  /// empty trip; students get attached as their QR/NFC is scanned. Pass
  /// [manualStudentIds] (non-empty) to hand-pick the roster — the server
  /// uses it instead of the last-trip / schedule auto-fill.
  Future<StartTripResponseDto> startTrip({
    required String busId,
    required String driverId,
    required String tripType,
    bool skipRoster = false,
    List<String>? manualStudentIds,
    // When true the API materialises the trip in Scheduled status and the
    // assistant flips it to InProgress later via [activateTrip].
    bool scheduled = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'busId': busId,
        'driverId': driverId,
        'tripType': tripType,
        'skipRoster': skipRoster,
        'scheduled': scheduled,
      };
      if (manualStudentIds != null && manualStudentIds.isNotEmpty) {
        data['manualStudentIds'] = manualStudentIds;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/trips/start',
        data: data,
      );
      final body = response.data;
      if (body == null) throw const FormatException('empty body');
      return StartTripResponseDto.fromJson(body);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Flip a Scheduled trip to InProgress (step 2 of the two-step new-trip
  /// flow). Server-side handles Return-trip auto-boarding + driver notify.
  Future<void> activateTrip(String tripId) async {
    try {
      await _dio.post<void>('/trips/$tripId/start');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Soft-delete a Scheduled trip. Server enforces "only Scheduled" when
  /// the caller isn't an Admin — used by the assistant's "cancel before
  /// starting" path on trip-details.
  Future<void> deleteScheduledTrip(String tripId) async {
    try {
      await _dio.delete<void>('/trips/$tripId');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Resolve a student-QR token to the linked student (no side effects).
  /// Returns null when the token is unknown / unregistered / its student is
  /// soft-deleted. Used by the trip-setup screen to preview a scan before
  /// the trip itself has been created.
  Future<RosterStudentDto?> resolveStudentQr(String token) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/students/resolve-qr',
        data: {'token': token.trim()},
      );
      final data = response.data;
      if (data == null) return null;
      return RosterStudentDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return null; // unregistered / unknown
      throw mapDioErrorToFailure(e);
    }
  }

  /// Search students by name (active subscription only — scoped to the
  /// caller's school server-side). Used by the trip-setup manual roster.
  /// [lang] scopes the LIKE filter to one name field: "en" → FullNameEn,
  /// "ar" → FullName. Omit for the legacy "either field" admin behavior.
  Future<List<RosterStudentDto>> searchStudents(
    String query, {
    String? lang,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/students',
        queryParameters: {
          'pageSize': 20,
          if (query.trim().isNotEmpty) 'name': query.trim(),
          if (lang != null && lang.isNotEmpty) 'lang': lang,
        },
      );
      final items = (response.data?['items'] as List<dynamic>?) ?? const [];
      return items
          .map((e) => RosterStudentDto.fromJson({
                // /students returns 'id' rather than 'studentId'; remap so the
                // existing RosterStudentDto factory works without a new model.
                'studentId': (e as Map<String, dynamic>)['id'],
                'fullName': e['fullName'],
                'fullNameEn': e['fullNameEn'],
                'grade': e['grade'],
              }))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Rich trip view (header + students with parent + absence + location).
  Future<TripDetailsDto> getTripDetails(String tripId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/trips/$tripId/details');
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return TripDetailsDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Toggle a student's boarding status. The PATCH lives on /student-trips.
  /// Pass [latitude]/[longitude] from the assistant's GPS at boarding time —
  /// the server uses them as the home pickup point on Morning trips.
  Future<void> updateBoarding({
    required String tripId,
    required String studentId,
    required String status, // "Waiting" | "Boarded" | "Absent"
    DateTime? boardingTime,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _dio.patch<void>(
        '/student-trips/boarding',
        data: {
          'tripId': tripId,
          'studentId': studentId,
          'status': status,
          if (boardingTime != null)
            'boardingTime': boardingTime.toUtc().toIso8601String(),
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Scan a student QR on the active trip. Marks them as boarded; adds them
  /// to the roster if they weren't already on the trip.
  Future<void> scanStudent({
    required String tripId,
    required String qrToken,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _dio.post<void>(
        '/trips/$tripId/scan-student',
        data: {
          'qrToken': qrToken,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// End the trip — sets status=Completed and records ActualArrival.
  Future<void> completeTrip(String tripId) async {
    try {
      await _dio.post<void>('/trips/$tripId/complete');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Cancel a trip that still has zero students. Server enforces the
  /// empty-roster guard, so this is rejected as soon as anyone is on board.
  Future<void> cancelEmptyTrip(String tripId) async {
    try {
      await _dio.delete<void>('/trips/$tripId/empty');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Cancel an absence the parent submitted earlier. Used by the assistant
  /// trip-details sheet to undo an absent flag mid-trip when the student
  /// shows up after all. Server rejects once the matching trip is completed.
  /// Goes through the crew-only "force" endpoint so the in-progress guard
  /// the parent flow uses doesn't block this path.
  Future<void> cancelAbsenceRequest(String absenceRequestId) async {
    try {
      await _dio.delete<void>('/absence-requests/$absenceRequestId/force');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Update my (the current driver/assistant's) profile.
  Future<void> updateMyProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        '/drivers/me',
        data: {'fullName': fullName, 'phoneNumber': phoneNumber},
      );
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Send a "bus arrived at home" push to the parent of a given student.
  Future<void> notifyParentArrived(String studentId) async {
    try {
      await _dio.post<void>(
        '/notifications/students/$studentId/push',
        data: {
          'title': 'Bus arrived',
          'body': 'The bus has arrived at the student\'s home.',
        },
      );
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  /// Roster of an existing trip (used after Start trip lands you on the live view).
  Future<List<TripStudentDto>> getTripStudents(String tripId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/trips/$tripId/students');
      final list = response.data ?? const [];
      return list
          .map((e) => TripStudentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }
}

final assistantRemoteDataSourceProvider =
    Provider<AssistantRemoteDataSource>(
  (ref) => AssistantRemoteDataSource(ref.watch(dioClientProvider)),
);
