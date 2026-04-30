import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/network/api_exception.dart';
import 'package:smart_bus/core/network/dio_client.dart';
import 'package:smart_bus/features/parent/data/models/child_trip_dto.dart';
import 'package:smart_bus/features/parent/data/models/parent_detail_dto.dart';

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
