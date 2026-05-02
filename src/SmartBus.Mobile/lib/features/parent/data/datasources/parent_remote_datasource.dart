import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/network/api_exception.dart';
import 'package:smart_bus/core/network/dio_client.dart';
import 'package:smart_bus/features/parent/data/models/child_trip_dto.dart';
import 'package:smart_bus/features/parent/data/models/parent_detail_dto.dart';
import 'package:smart_bus/features/parent/data/models/student_info_dto.dart';

part 'parent_remote_datasource.g.dart';

class ParentRemoteDataSource {
  ParentRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ParentDetailDto> getParent(String parentId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/parents/$parentId');
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return ParentDetailDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<StudentInfoDto> getStudent({
    required String parentId,
    required String studentId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/parents/$parentId/students/$studentId',
      );
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return StudentInfoDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<String> submitAbsenceRequest({
    required String studentId,
    required DateTime date,
    required String tripType, // FullDay | MorningOnly | ReturnOnly
    required String reason,    // Illness | MedicalAppointment | FamilyMatter | Other
    String? driverNote,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/absence-requests',
        data: {
          'studentId': studentId,
          'date': _dateOnly(date),
          'tripType': tripType,
          'reason': reason,
          'driverNote': driverNote,
          'notifyDriver': true,
          'notifySchool': true,
        },
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  static String _dateOnly(DateTime d) {
    final local = d.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$day';
  }

  Future<void> updateChildProfile({
    required String parentId,
    required String studentId,
    required String fullName,
    required String grade,
    String? className,
    String? notes,
    required String parentName,
    required String parentPhone,
  }) async {
    try {
      await _dio.put<void>(
        '/parents/$parentId/students/$studentId/profile',
        data: {
          'fullName': fullName,
          'grade': grade,
          'class': className,
          'notes': notes,
          'parentName': parentName,
          'parentPhone': parentPhone,
        },
      );
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<List<ChildTripDto>> getChildTrips({
    required String parentId,
    required String studentId,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/parents/$parentId/students/$studentId/trips',
        queryParameters: {'pageSize': pageSize},
      );
      final list = response.data ?? const [];
      return list
          .map((e) => ChildTripDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }
}

@Riverpod(keepAlive: true)
ParentRemoteDataSource parentRemoteDataSource(Ref ref) =>
    ParentRemoteDataSource(ref.watch(dioClientProvider));
