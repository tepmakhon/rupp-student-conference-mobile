import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rupp_student_conference_mobile/core/network/dio_client.dart';
import 'package:rupp_student_conference_mobile/features/auth/providers/session_provider.dart';
import 'package:rupp_student_conference_mobile/features/catalog/services/student_api.dart';

class ContractAdapter implements HttpClientAdapter {
  final dynamic Function(RequestOptions options) respond;
  ContractAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(respond(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}

Dio client(dynamic Function(RequestOptions) respond) =>
    Dio(BaseOptions(baseUrl: 'https://test.invalid/api'))
      ..httpClientAdapter = ContractAdapter(respond);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
    'authentication uses actual login envelope and securely persists token',
    () async {
      final session = SessionController(
        client: client((request) {
          expect(request.path, '/auth/login');
          expect(request.data, {
            'email': 'student@rupp.edu.kh',
            'password': 'secret',
          });
          return {
            'data': {
              'token': 'backend-issued-token',
              'user': {
                'role': {'roleName': 'STUDENT'},
              },
            },
          };
        }),
      );
      await session.restore();
      await session.authenticate({
        'email': 'student@rupp.edu.kh',
        'password': 'secret',
      });
      expect(session.state.valueOrNull, true);
      expect(
        await const FlutterSecureStorage().read(key: 'access_token'),
        'backend-issued-token',
      );
      session.dispose();
    },
  );
  test('organization login never persists a token', () async {
    final session = SessionController(
      client: client(
        (_) => {
          'data': {
            'token': 'other-role-token',
            'user': {
              'role': {'roleName': 'ORGANIZATION'},
            },
          },
        },
      ),
    );
    await session.restore();
    await expectLater(
      session.authenticate({'email': 'org@example.com', 'password': 'secret'}),
      throwsStateError,
    );
    expect(
      await const FlutterSecureStorage().read(key: 'access_token'),
      isNull,
    );
    expect(session.state.valueOrNull, false);
    session.dispose();
  });
  test(
    'student registration sends backend education hierarchy fields',
    () async {
      final session = SessionController(
        client: client((request) {
          expect(request.path, '/auth/register');
          expect(request.data['roleName'], 'STUDENT');
          expect(request.data['universityId'], '1');
          expect(request.data['facultyId'], '2');
          expect(request.data['majorId'], '3');
          return {
            'data': {
              'token': 'registered-token',
              'user': {
                'role': {'roleName': 'STUDENT'},
              },
            },
          };
        }),
      );
      await session.restore();
      await session.authenticate({
        'email': 'student@example.com',
        'password': 'password123',
        'roleName': 'STUDENT',
        'fullName': 'Student Name',
        'universityId': '1',
        'facultyId': '2',
        'majorId': '3',
      }, register: true);
      expect(session.state.valueOrNull, true);
      session.dispose();
    },
  );
  test(
    'discovery fetches every page using the documented data envelope',
    () async {
      final api = StudentApi(
        client: client((request) {
          expect(request.path, '/events/approved');
          final page = request.queryParameters['page'] as int;
          return {
            'data': {
              'events': [
                {'id': '$page'},
              ],
              'pagination': {'totalPages': 2},
            },
          };
        }),
      );
      expect(
        (await api.list('/events/approved', 'events')).map((e) => e['id']),
        ['1', '2'],
      );
    },
  );
  test(
    'offline and backend validation errors are readable and hide internals',
    () {
      expect(
        readableError(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        'Unable to connect. Check your connection and try again.',
      );
      expect(
        readableError(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 409,
              data: {'message': 'Already registered'},
            ),
          ),
        ),
        'Already registered',
      );
    },
  );
}
