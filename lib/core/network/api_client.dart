import 'package:dio/dio.dart';
import 'dio_client.dart';

class ApiClient {
  static Future<Response<dynamic>> get(String path) => DioClient.dio.get(path);
  static Future<Response<dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) => DioClient.dio.post(path, data: data);
}
