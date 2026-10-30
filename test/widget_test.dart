import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rupp_student_conference_mobile/app.dart';
import 'package:rupp_student_conference_mobile/core/routes/app_router.dart';
import 'package:rupp_student_conference_mobile/features/auth/providers/session_provider.dart';
import 'package:rupp_student_conference_mobile/features/catalog/screens/ticket_screen.dart';
import 'package:rupp_student_conference_mobile/features/catalog/services/student_api.dart';

class TestSession extends SessionController {
  static bool signedIn = true;
  bool reject = false;
  @override
  Future<void> restore() async {
    state = AsyncData(signedIn);
  }

  @override
  Future<void> authenticate(
    Map<String, dynamic> fields, {
    bool register = false,
  }) async {
    if (reject) throw StateError('Invalid credentials');
    state = const AsyncData(true);
  }
}

class TestApi extends StudentApi {
  bool profileFails = false;
  bool empty = false;
  bool registrationFails = false;
  final List<String> mutations = [];
  final List<Json> registrations = [];
  final List<Json> saved = [];
  final List<Json> applications = [];
  final List<Json> notifications = [
    {
      'id': '8',
      'isRead': false,
      'notification': {
        'title': 'Registration confirmed',
        'message': 'Your registration is confirmed.',
        'type': 'EVENT',
        'createdAt': '2026-10-30T02:00:00Z',
      },
    },
  ];
  Json? lastPayload;
  final Json event = {
    'id': '1',
    'title': 'Student Tech Conference',
    'description': 'Meet researchers and discover new ideas.',
    'location': 'RUPP Building A',
    'eventDate': '2099-11-18T01:30:00Z',
    'status': 'APPROVED',
    'capacity': 100,
    '_count': {'registrations': 1},
    'organization': {'organizationName': 'GDG RUPP'},
    'category': {'categoryName': 'Conference'},
  };
  final Json opportunity = {
    'id': '2',
    'title': 'Student Research Scholarship',
    'description': 'Support for undergraduate research.',
    'requirements': 'Current university students',
    'deadline': '2099-11-22T00:00:00Z',
    'status': 'APPROVED',
    'organization': {'organizationName': 'Education Cambodia'},
    'type': {'typeName': 'Scholarship'},
  };
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    if (path == '/profile/me') {
      if (profileFails) throw StateError('Profile unavailable');
      return {
        'email': 'student@rupp.edu.kh',
        'profile': {'fullName': 'Sokhom', 'bio': 'Student researcher'},
        'student': {},
        'statistics': {},
      };
    }
    if (path == '/events/my-registrations') return registrations;
    if (path == '/opportunities/saved/list') return saved;
    if (path == '/events/1') return event;
    if (path == '/events/1/ticket') {
      return {
        'registrationId': '5',
        'studentName': 'Sokhom',
        'eventTitle': event['title'],
        'eventDate': event['eventDate'],
        'qrCode': jsonEncode({
          'registrationId': '5',
          'studentId': '2',
          'eventId': '1',
        }),
      };
    }
    if (path == '/opportunities/2') return opportunity;
    if (path == '/universities') {
      return [
        {'id': '1', 'universityName': 'RUPP'},
      ];
    }
    if (path == '/faculties') {
      return [
        {'id': '2', 'universityId': '1', 'facultyName': 'Science'},
      ];
    }
    if (path == '/majors') {
      return [
        {'id': '3', 'facultyId': '2', 'majorName': 'Computer Science'},
      ];
    }
    return [];
  }

  @override
  Future<List<Json>> list(String path, String key) async {
    if (empty) return [];
    return switch (path) {
      '/events/approved' => [event],
      '/opportunities' => [opportunity],
      '/applications/me' => applications,
      '/notifications' => notifications,
      _ => [],
    };
  }

  @override
  Future<dynamic> mutate(
    String path, {
    String method = 'POST',
    Json? data,
  }) async {
    mutations.add(path);
    lastPayload = data;
    if (path == '/opportunities/2/save') {
      if (method == 'DELETE') {
        saved.clear();
      } else {
        saved.add({'opportunityId': '2', 'opportunity': opportunity});
      }
    }
    if (path == '/opportunities/2/apply') {
      applications.add({'opportunityId': '2', 'applicationStatus': 'PENDING'});
    }
    if (path.startsWith('/notifications/')) {
      notifications.first['isRead'] = true;
    }
    if (registrationFails) throw StateError('Event is full');
    if (path.endsWith('/register')) {
      registrations.add({
        'id': '5',
        'eventId': '1',
        'registrationStatus': 'APPROVED',
        'event': event,
      });
    }
    return {'id': '5'};
  }
}

Future<ProviderContainer> start(
  WidgetTester tester,
  TestApi api, {
  bool signedIn = true,
  Size size = const Size(440, 956),
  double scale = 1,
}) async {
  TestSession.signedIn = signedIn;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWith((ref) => TestSession()),
      studentApiProvider.overrideWithValue(api),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      child: UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (_, _) => MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
            ),
            child: const MyApp(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> snapshot(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_SCREENS')) return;
  final RenderObject render = tester.renderObject(
    find.byType(RepaintBoundary).first,
  );
  if (render is RenderRepaintBoundary) {
    await tester.runAsync(() async {
      final image = await render.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('build/review');
      await directory.create(recursive: true);
      await File(
        '${directory.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Optional SDK font directory makes review captures readable; ordinary tests
    // stay independent of the machine's Flutter installation path.
    final fonts = Platform.environment['REVIEW_FONT_DIR'];
    if (fonts != null) {
      for (final entry in {
        'Roboto': 'Roboto-Regular.ttf',
        'MaterialIcons': 'MaterialIcons-Regular.otf',
      }.entries) {
        final loader = FontLoader(entry.key);
        loader.addFont(
          Future.value(
            ByteData.sublistView(
              await File('$fonts/${entry.value}').readAsBytes(),
            ),
          ),
        );
        await loader.load();
      }
    }
  });
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('session routing protects details and resolves splash', () {
    expect(sessionRedirect(const AsyncLoading(), '/events/1'), '/');
    expect(sessionRedirect(const AsyncData(false), '/events/1'), '/login');
    expect(sessionRedirect(const AsyncData(true), '/login'), '/home');
    expect(sessionRedirect(const AsyncData(true), '/events/1'), null);
  });
  test('restores valid student JWT and clears expired session', () async {
    String token(int expiry) =>
        'header.${base64Url.encode(utf8.encode(jsonEncode({'roleName': 'STUDENT', 'exp': expiry}))).replaceAll('=', '')}.signature';
    FlutterSecureStorage.setMockInitialValues({
      'access_token': token(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      ),
    });
    final session = SessionController();
    await session.restore();
    expect(session.state.valueOrNull, true);
    await session.logout();
    expect(session.state.valueOrNull, false);
    FlutterSecureStorage.setMockInitialValues({'access_token': token(1)});
    await session.restore();
    expect(session.state.valueOrNull, false);
    session.dispose();
  });
  test('ticket requires backend registration and matching QR event', () {
    final data = {
      'registrationId': '3',
      'qrCode': jsonEncode({
        'registrationId': '3',
        'studentId': '2',
        'eventId': '1',
      }),
    };
    expect(validTicket(data, '1'), true);
    expect(validTicket(data, '2'), false);
    expect(
      validTicket({'registrationId': '3', 'qrCode': 'invalid'}, '1'),
      false,
    );
  });
  testWidgets('login validates and surfaces rejected credentials', (
    tester,
  ) async {
    final container = await start(tester, TestApi(), signedIn: false);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@rupp.edu.kh',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    (container.read(sessionProvider.notifier) as TestSession).reject = true;
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid credentials'), findsOneWidget);
    (container.read(sessionProvider.notifier) as TestSession).reject = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('RUPP CONNECT'), findsOneWidget);
  });
  testWidgets('profile failure leaves home event section visible', (
    tester,
  ) async {
    await start(tester, TestApi()..profileFails = true);
    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.text('Student Tech Conference'), findsOneWidget);
  });
  testWidgets('event navigation confirms only after API success', (
    tester,
  ) async {
    final api = TestApi();
    final container = await start(tester, api);
    container.read(routerProvider).go('/events');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student Tech Conference'));
    await tester.pumpAndSettle();
    expect(find.text('Event details'), findsOneWidget);
    await tester.ensureVisible(find.text('Register for event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register for event'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();
    expect(api.mutations, contains('/events/1/register'));
    expect(
      find.text('Registration confirmed. View your registration in My events.'),
      findsOneWidget,
    );
  });
  testWidgets('failed registration never claims success', (tester) async {
    final api = TestApi()..registrationFails = true;
    final container = await start(tester, api);
    container.read(routerProvider).go('/events/1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Register for event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register for event'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.text('Event is full'), findsOneWidget);
    expect(find.textContaining('Registration confirmed.'), findsNothing);
  });
  testWidgets('event search persists across tabs and empty states are useful', (
    tester,
  ) async {
    final container = await start(tester, TestApi());
    container.read(routerProvider).go('/events');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'No match');
    await tester.pumpAndSettle();
    expect(
      find.text('No matches. Try another search or filter.'),
      findsOneWidget,
    );
    container.read(routerProvider).go('/profile');
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/events');
    await tester.pumpAndSettle();
    expect(find.text('No match'), findsOneWidget);
  });
  testWidgets('save and apply update only after supported API mutations', (
    tester,
  ) async {
    final api = TestApi();
    final container = await start(tester, api);
    container.read(routerProvider).go('/opportunities/2');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save opportunity'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save opportunity'));
    await tester.pumpAndSettle();
    expect(api.mutations, contains('/opportunities/2/save'));
    expect(find.text('Remove saved opportunity'), findsOneWidget);
    await tester.ensureVisible(find.text('Apply now'));
    await tester.tap(find.text('Apply now'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'invalid-url');
    await tester.tap(find.widgetWithText(FilledButton, 'Submit application'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid HTTP or HTTPS URL'), findsOneWidget);
    expect(api.mutations, isNot(contains('/opportunities/2/apply')));
    await tester.enterText(
      find.byType(TextFormField),
      'https://example.com/cv.pdf',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Submit application'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(api.mutations, contains('/opportunities/2/apply'));
    expect(api.lastPayload, {'cvUrl': 'https://example.com/cv.pdf'});
    expect(find.text('Application submitted'), findsOneWidget);
  });
  testWidgets('notification read action uses user-notification ID', (
    tester,
  ) async {
    final api = TestApi();
    final container = await start(tester, api);
    container.read(routerProvider).go('/notifications');
    await tester.pumpAndSettle();
    expect(find.text('Mark as read'), findsOneWidget);
    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();
    expect(api.mutations, contains('/notifications/8/read'));
    expect(find.text('Mark as read'), findsNothing);
    await tester.tap(find.text('Browse events'));
    await tester.pumpAndSettle();
    expect(find.text('Discover events'), findsOneWidget);
  });
  testWidgets('expired and full events cannot submit registrations', (
    tester,
  ) async {
    final api = TestApi();
    api.event['capacity'] = 1;
    final container = await start(tester, api);
    container.read(routerProvider).go('/events/1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Register for event'));
    await tester.pumpAndSettle();
    expect(find.text('Event is full'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Register for event'),
          )
          .onPressed,
      isNull,
    );
    api.event['eventDate'] = '2000-01-01T00:00:00Z';
    container.invalidate(resourceProvider('/events/1'));
    await tester.pumpAndSettle();
    expect(find.text('Event has ended'), findsOneWidget);
    expect(api.mutations, isEmpty);
  });
  testWidgets('Home search opens matching results across both catalogs', (
    tester,
  ) async {
    await start(tester, TestApi());
    await tester.enterText(find.byType(TextField), 'Research');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Search campus opportunities'), findsOneWidget);
    expect(find.text('Student Research Scholarship'), findsOneWidget);
    expect(find.text('Student Tech Conference'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Research',
    );
  });
  testWidgets('cancelled registrations never display a ticket QR', (
    tester,
  ) async {
    final api = TestApi();
    api.registrations.add({
      'id': '5',
      'eventId': '1',
      'registrationStatus': 'CANCELLED',
      'event': api.event,
    });
    final container = await start(tester, api);
    container.read(routerProvider).go('/events/1/ticket');
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This registration is not approved or the event is unavailable. A ticket cannot be displayed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Registration #5'), findsNothing);
    container.read(routerProvider).go('/events/1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Registration cancelled'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Registration cancelled'),
          )
          .onPressed,
      isNull,
    );
    container.read(routerProvider).go('/events/1/ticket');
    await tester.pumpAndSettle();
    api.registrations.first['registrationStatus'] = 'APPROVED';
    container.invalidate(resourceProvider('/events/my-registrations'));
    await tester.pumpAndSettle();
    expect(find.text('Registration #5'), findsOneWidget);
  });
  for (final size in [const Size(320, 568), const Size(440, 956)]) {
    testWidgets('representative screens fit ${size.width} at larger text', (
      tester,
    ) async {
      final container = await start(tester, TestApi(), size: size, scale: 1.5);
      for (final path in [
        '/home',
        '/events',
        '/opportunities',
        '/notifications',
        '/profile',
        '/events/1',
        '/opportunities/2',
        '/edit-profile',
        '/my-events',
        '/saved',
        '/search?q=Student',
      ]) {
        container.read(routerProvider).go(path);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: path);
        await snapshot(
          tester,
          '${size.width.toInt()}-${path.replaceAll('/', '_')}',
        );
      }
      await container.read(sessionProvider.notifier).logout();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await snapshot(tester, '${size.width.toInt()}-login');
    });
  }
}
