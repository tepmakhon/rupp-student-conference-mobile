enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;

  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error,
    );
  }
}