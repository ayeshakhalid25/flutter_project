// lib/api_services.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/course_model.dart';   // ✅ FIXED: models/ not screens/

class ApiService {

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // READ — GET /posts
  static Future<List<Course>> getCourses() async {
    final url = Uri.parse('$_baseUrl/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.take(10).map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses. Status: ${response.statusCode}');
    }
  }

  // CREATE — POST /posts
  static Future<Course> createCourse({
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$_baseUrl/posts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': 1, 'title': title, 'body': body}),
    );

    if (response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create course. Status: ${response.statusCode}');
    }
  }

  // UPDATE — PUT /posts/{id}
  static Future<Course> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$_baseUrl/posts/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'id': id, 'userId': 1, 'title': title, 'body': body}),
    );

    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course. Status: ${response.statusCode}');
    }
  }

  // DELETE — DELETE /posts/{id}
  static Future<void> deleteCourse(int id) async {
    final url = Uri.parse('$_baseUrl/posts/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course. Status: ${response.statusCode}');
    }
  }
}
