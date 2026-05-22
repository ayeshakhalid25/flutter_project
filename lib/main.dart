// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/course_list_screen.dart';
import 'screens/course_form_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      initialRoute: '/register',
      routes: {
        '/register':    (context) => RegisterScreen(),    // ✅ FIXED: was RegistrationScreen()
        '/login':       (context) => LoginScreen(),
        '/dashboard':   (context) => DashboardScreen(),
        '/courses':     (context) => CourseListScreen(),
        '/course-form': (context) => CourseFormScreen(),
      },
    );
  }
}
