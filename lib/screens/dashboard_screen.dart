// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'course_list_screen.dart'; // needed for MaterialPageRoute fix

class DashboardScreen extends StatelessWidget {
  // Subjects list — same as your old dashboard
  static const List<Map<String, String>> _subjects = [
    {
      'name': 'Mobile App Development',
      'schedule': 'Mon & Wed  |  10:00 AM – 11:30 AM  |  Room 301',
      'color': '3F51B5',
    },
    {
      'name': 'Software Re-engineering',
      'schedule': 'Tue & Thu  |  12:00 PM – 1:30 PM  |  Room 204',
      'color': '4CAF50',
    },
    {
      'name': 'MIS',
      'schedule': 'Fri  |  9:00 AM – 12:00 PM  |  Room 105',
      'color': '9C27B0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get the logged in user's email passed from LoginScreen
    final String userEmail =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'User';

    // Get first letter of email for avatar
    final String avatarLetter = userEmail[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User info card (same as your old dashboard) ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo.shade200,
                    child: Text(avatarLetter,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${userEmail.split('@')[0]}! 👋',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(userEmail,
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ── Manage Courses button (NEW) ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.library_books),
                label: Text('Manage Courses (CRUD)'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                // ✅ Using push + MaterialPageRoute so screen stays alive
                // This means edits are preserved when you come back
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CourseListScreen()),
                ),
              ),
            ),

            SizedBox(height: 24),

            // ── Your Subjects (same as your old dashboard) ──
            Text('Your Subjects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Tap a subject to view details',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final color =
                      Color(int.parse('FF${subject['color']}', radix: 16));

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Text(subject['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(subject['schedule']!,
                          style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: subject,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
