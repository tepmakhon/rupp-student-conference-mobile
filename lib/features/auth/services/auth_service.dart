import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      "/auth/login",
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data);
  }
}