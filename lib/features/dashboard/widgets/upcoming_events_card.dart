import 'package:flutter/material.dart';

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: Icon(Icons.event),
              title: Text("Flutter Workshop"),
              subtitle: Text("Tomorrow"),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.event),
              title: Text("Google Cloud Study Jam"),
              subtitle: Text("25 July"),
            ),
          ],
        ),
      ),
    );
  }
}