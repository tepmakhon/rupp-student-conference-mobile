import 'package:flutter/material.dart';
import '../../catalog/screens/browse_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});
  @override
  Widget build(BuildContext context) => const BrowseScreen(event: true);
}
