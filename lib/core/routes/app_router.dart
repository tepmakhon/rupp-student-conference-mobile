import 'package:go_router/go_router.dart';
import 'package:rupp_student_conference_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:rupp_student_conference_mobile/features/splash/pages/splash_screen.dart';

import '../../features/auth/screens/login_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: "/",

      builder: (context, state) =>
          const SplashScreen(),
    ),

    GoRoute(
      path: "/login",

      builder: (context, state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: "/dashboard",

      builder: (context, state) =>
          const DashboardScreen(),
    ),
  ],
);