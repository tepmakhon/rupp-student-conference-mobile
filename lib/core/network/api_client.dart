import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

import 'dio_provider.dart';

class ApiClient {
  static Future<Response> get(
    String path,
  ) async {
    final token = await TokenStorage.getToken();

    return dio.get(
      path,

      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  static Future<Response> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final token = await TokenStorage.getToken();

    return dio.post(
      path,

      data: data,

      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}