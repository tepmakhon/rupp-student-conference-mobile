import 'package:flutter/material.dart';

class OpportunitiesCard extends StatelessWidget {
  const OpportunitiesCard({super.key});

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
              "Recommended Opportunities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: Icon(Icons.work),
              title: Text("Software Engineering Internship"),
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.school),
              title: Text("Scholarship 2026"),
            ),
          ],
        ),
      ),
    );
  }
}