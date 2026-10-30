import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/navigation/main_navigation.dart';
import '../../features/catalog/screens/detail_screen.dart';
import '../../features/catalog/screens/ticket_screen.dart';
import '../../features/catalog/screens/search_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/catalog/screens/collection_screen.dart';
import '../widgets/app_logo.dart';

String? sessionRedirect(AsyncValue<bool> session, String path) {
  if (session.isLoading) return path == '/' ? null : '/';
  final signedIn = session.valueOrNull == true;
  final public = path == '/login' || path == '/register';
  if (!signedIn) return public ? null : '/login';
  return public || path == '/' ? '/home' : null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, next) {
    refresh.value++;
  });
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (_, state) =>
        sessionRedirect(ref.read(sessionProvider), state.uri.path),
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(),
                  SizedBox(height: 24),
                  Text('RUPP CONNECT'),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const LoginScreen(register: true),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainNavigation(shell: shell),
        branches: [
          for (final path in [
            'home',
            'events',
            'opportunities',
            'notifications',
            'profile',
          ])
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/$path',
                  builder: (_, _) => StudentTab(path: path),
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: '/events/:id/ticket',
        builder: (_, s) => TicketScreen(eventId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (_, s) =>
            DetailScreen(id: s.pathParameters['id']!, event: true),
      ),
      GoRoute(
        path: '/opportunities/:id',
        builder: (_, s) =>
            DetailScreen(id: s.pathParameters['id']!, event: false),
      ),
      GoRoute(
        path: '/search',
        builder: (_, s) =>
            SearchScreen(initialQuery: s.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: '/my-events',
        builder: (_, _) => const CollectionScreen(events: true),
      ),
      GoRoute(
        path: '/saved',
        builder: (_, _) => const CollectionScreen(events: false),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, _) => const EditProfileScreen(),
      ),
    ],
    errorBuilder: (context, _) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/home'),
          child: const Text('Page not found · Go home'),
        ),
      ),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
