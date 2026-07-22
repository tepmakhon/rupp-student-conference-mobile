import '../models/login_request.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<LoginResponse> login(
    String email,
    String password,
  ) {
    return _service.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );
  }
}