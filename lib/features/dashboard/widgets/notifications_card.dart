import 'package:flutter/material.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

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
              "Recent Notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Registration Approved"),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("New Event Added"),
            ),
          ],
        ),
      ),
    );
  }
}