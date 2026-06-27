// lib/services/local_storage_service.dart
//
// LOCAL DATABASE LAYER (offline persistence).
// Uses SharedPreferences to cache the course list as a JSON string.
// The assignment allows SharedPreferences "for simple cases" — caching a
// small list of courses is exactly that. Swapping this for Hive/Sqflite
// later only requires changing this one file (the repository is unaware
// of how data is stored).

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';

class LocalStorageService {
  static const String _coursesKey = 'cached_courses';

  // Save the full list (called after every successful API call -> keeps the
  // cache in sync with the server).
  Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString(_coursesKey, jsonString);
  }

  // Read the cached list (used when offline or when the API fails).
  Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_coursesKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted cache -> behave like an empty cache.
      return [];
    }
  }

  Future<bool> hasCache() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_coursesKey);
    return value != null && value.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesKey);
  }
}
