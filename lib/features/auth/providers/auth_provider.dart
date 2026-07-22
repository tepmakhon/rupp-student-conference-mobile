import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import 'auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _repository = AuthRepository();

  Future<void> login(
    String email,
    String password,
  ) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );

    try {
      final response = await _repository.login(
        email,
        password,
      );

      print(response.token);

      print(response.user);

      state = state.copyWith(
        status: AuthStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }
}