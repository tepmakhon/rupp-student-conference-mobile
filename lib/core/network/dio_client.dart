import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_constants.dart';

class DioClient {
  static void Function()? onUnauthorized;
  static final Dio dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              try {
                options.baseUrl = ApiConstants.validatedBaseUrl;
                final token = await TokenStorage.getToken();
                if (token != null && !options.path.startsWith('/auth/')) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                handler.next(options);
              } catch (_) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    error:
                        'Configure API_BASE_URL before connecting. Production requires HTTPS.',
                  ),
                );
              }
            },
            onError: (error, handler) {
              if (error.response?.statusCode == 401 &&
                  !error.requestOptions.path.startsWith('/auth/')) {
                onUnauthorized?.call();
              }
              handler.next(error);
            },
          ),
        );
}

String readableError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.error is String) return error.error as String;
    if (error.response?.statusCode == 404) {
      return 'This item is no longer available.';
    }
    return 'Unable to connect. Check your connection and try again.';
  }
  if (error is StateError) return error.message.toString();
  return 'Something went wrong. Please try again.';
}
