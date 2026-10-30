import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

final sessionProvider =
    StateNotifierProvider<SessionController, AsyncValue<bool>>(
      (ref) => SessionController(),
    );

class SessionController extends StateNotifier<AsyncValue<bool>> {
  SessionController({Dio? client})
    : _client = client ?? DioClient.dio,
      super(const AsyncLoading()) {
    DioClient.onUnauthorized = expire;
    restore();
  }
  final Dio _client;
  String? message;
  Future<void> restore() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        state = const AsyncData(false);
        return;
      }
      final payload =
          jsonDecode(
                utf8.decode(
                  base64Url.decode(base64Url.normalize(token.split('.')[1])),
                ),
              )
              as Map;
      if (payload['roleName'] != 'STUDENT' ||
          payload['exp'] is! num ||
          DateTime.fromMillisecondsSinceEpoch(
            (payload['exp'] as num).toInt() * 1000,
          ).isBefore(DateTime.now())) {
        await expire();
        return;
      }
      state = const AsyncData(true);
    } catch (_) {
      await expire();
    }
  }

  Future<void> authenticate(
    Map<String, dynamic> fields, {
    bool register = false,
  }) async {
    final response = await _client.post(
      register ? '/auth/register' : '/auth/login',
      data: fields,
    );
    final data = response.data['data'] as Map;
    if (data['user']['role']['roleName'] != 'STUDENT') {
      throw StateError(
        'This app is for students. Organization and Admin accounts use the web platform.',
      );
    }
    await TokenStorage.saveToken(data['token'] as String);
    message = null;
    state = const AsyncData(true);
  }

  Future<void> expire() async {
    message = 'Your session has expired. Please sign in again.';
    await logout();
  }

  Future<void> logout() async {
    try {
      await TokenStorage.clearToken();
    } finally {
      if (mounted) state = const AsyncData(false);
    }
  }
}
