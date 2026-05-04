import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/network/api_exception.dart';
import 'package:smart_bus/core/network/dio_client.dart';
import 'package:smart_bus/features/notifications/data/models/notification_dto.dart';

part 'notifications_remote_datasource.g.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<NotificationsPageDto> getMine({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/me',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return NotificationsPageDto.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch<void>('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch<void>('/notifications/read-all');
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }
}

@Riverpod(keepAlive: true)
NotificationsRemoteDataSource notificationsRemoteDataSource(Ref ref) =>
    NotificationsRemoteDataSource(ref.watch(dioClientProvider));
