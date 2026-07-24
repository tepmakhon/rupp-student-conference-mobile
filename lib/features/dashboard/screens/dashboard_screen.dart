import 'package:flutter/material.dart';
import 'package:rupp_student_conference_mobile/features/dashboard/widgets/notifications_card.dart';
import 'package:rupp_student_conference_mobile/features/dashboard/widgets/opportunities_card.dart';
import 'package:rupp_student_conference_mobile/features/dashboard/widgets/upcoming_events_card.dart';

import '../widgets/greeting_card.dart';
import '../widgets/activity_score_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          GreetingCard(
            name: "Tep Makhon",
          ),

          SizedBox(height: 20),

          ActivityScoreCard(
            score: 1250,
          ),

          SizedBox(height: 20),

          UpcomingEventsCard(),

          SizedBox(height: 20),

          OpportunitiesCard(),

          SizedBox(height: 20),

          NotificationsCard(),
        ],
      ),
    );
  }
}