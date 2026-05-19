import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/network/api_exception.dart';
import 'package:tilmez_bus/core/network/dio_client.dart';
import 'package:tilmez_bus/features/auth/data/models/otp_login_response.dart';
import 'package:tilmez_bus/features/auth/data/models/otp_request_request.dart';
import 'package:tilmez_bus/features/auth/data/models/otp_request_response.dart';
import 'package:tilmez_bus/features/auth/data/models/otp_verify_request.dart';

part 'auth_remote_datasource.g.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<OtpRequestResponse> requestOtp(OtpRequestRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/request',
        data: request.toJson(),
      );
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return OtpRequestResponse.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }

  Future<OtpLoginResponse> verifyOtp(OtpVerifyRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: request.toJson(),
      );
      final data = response.data;
      if (data == null) throw const FormatException('empty body');
      return OtpLoginResponse.fromJson(data);
    } on DioException catch (e) {
      throw mapDioErrorToFailure(e);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(dioClientProvider));
