import 'package:flutter/foundation.dart';

class ApiConstants {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static String get validatedBaseUrl {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !['https', 'http'].contains(uri.scheme)) {
      throw StateError('Set API_BASE_URL to your backend URL ending in /api.');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Production builds require an HTTPS API_BASE_URL.');
    }
    return baseUrl.replaceFirst(RegExp(r'/$'), '');
  }

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const profile = '/profile/me';
  static const events = '/events/approved';
  static const notifications = '/notifications';
  static const opportunities = '/opportunities';
}
