import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("➡️ ${options.method} ${options.uri}");

          handler.next(options);
        },

        onResponse: (response, handler) {
          print("✅ ${response.statusCode}");

          handler.next(response);
        },

        onError: (error, handler) {
          print("❌ ${error.response?.statusCode}");

          handler.next(error);
        },
      ),
    );
}