import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../catalog/screens/browse_screen.dart';
import '../notifications/screens/notifications_screen.dart';
import '../profile/screens/profile_screen.dart';

class MainNavigation extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainNavigation({super.key, required this.shell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: (i) => shell.goBranch(i, initialLocation: false),
      destinations: [
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/figma_home.svg',
            width: 24,
            height: 24,
          ),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/figma_calendar.svg',
            width: 24,
            height: 24,
          ),
          selectedIcon: Icon(Icons.event),
          label: 'Events',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/figma_briefcase.svg',
            width: 24,
            height: 24,
          ),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/figma_bell.svg',
            width: 24,
            height: 24,
          ),
          selectedIcon: Icon(Icons.notifications),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/figma_user.svg',
            width: 24,
            height: 24,
          ),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class StudentTab extends StatelessWidget {
  final String path;
  const StudentTab({super.key, required this.path});
  @override
  Widget build(BuildContext context) => switch (path) {
    'home' => const DashboardScreen(),
    'events' => const BrowseScreen(event: true),
    'opportunities' => const BrowseScreen(event: false),
    'notifications' => const NotificationsScreen(),
    _ => const ProfileScreen(),
  };
}
