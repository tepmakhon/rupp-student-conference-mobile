import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/session_provider.dart';

typedef Json = Map<String, dynamic>;
final studentApiProvider = Provider((ref) => StudentApi());

class StudentApi {
  StudentApi({Dio? client}) : _dio = client ?? DioClient.dio;
  final Dio _dio;
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      (await _dio.get(path, queryParameters: query)).data['data'];
  Future<dynamic> mutate(
    String path, {
    String method = 'POST',
    Json? data,
  }) async {
    final response = switch (method) {
      'PUT' => await _dio.put(path, data: data),
      'PATCH' => await _dio.patch(path, data: data),
      'DELETE' => await _dio.delete(path),
      _ => await _dio.post(path, data: data ?? {}),
    };
    return response.data['data'];
  }

  // Fetch all pages so local search and date filters never hide later matches.
  Future<List<Json>> list(String path, String key) async {
    final result = <Json>[];
    for (var page = 1; ; page++) {
      final data = await get(path, query: {'page': page, 'limit': 50});
      result.addAll(
        (data[key] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      if (page >= (data['pagination']?['totalPages'] ?? 1)) break;
    }
    return result;
  }
}

final resourceProvider = FutureProvider.family<dynamic, String>((
  ref,
  path,
) async {
  final session = ref.watch(sessionProvider);
  if (session.valueOrNull != true &&
      !['/universities', '/faculties', '/majors'].contains(path)) {
    return null;
  }
  final api = ref.watch(studentApiProvider);
  return switch (path) {
    '/events/approved' => api.list(path, 'events'),
    '/opportunities' => api.list(path, 'opportunities'),
    '/notifications' => api.list(path, 'userNotifications'),
    '/applications/me' => api.list(path, 'applications'),
    _ => api.get(path),
  };
});
String textValue(dynamic value, [String fallback = '']) =>
    value?.toString() ?? fallback;
String localDate(dynamic value, {bool time = false}) {
  final date = DateTime.tryParse(textValue(value))?.toLocal();
  if (date == null) return 'Not specified';
  return DateFormat(time ? 'd MMM yyyy · HH:mm' : 'd MMM yyyy').format(date);
}

Future<void> refreshResources(WidgetRef ref, List<String> paths) async {
  await Future.wait(
    paths.map((path) async {
      try {
        final _ = await ref.refresh(resourceProvider(path).future);
      } catch (_) {
        /* ResourceView renders the provider error and retry action. */
      }
    }),
  );
}
