import 'package:dio/dio.dart';

import 'api_constants.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: ApiConstants.baseUrl,

    connectTimeout: const Duration(seconds: 15),

    receiveTimeout: const Duration(seconds: 15),

    headers: {
      "Content-Type": "application/json",
    },
  ),
);