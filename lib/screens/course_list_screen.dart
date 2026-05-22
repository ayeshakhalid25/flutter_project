// lib/screens/course_list_screen.dart

import 'package:flutter/material.dart';
import '../models/course_model.dart';   // ✅ FIXED: was '../screens/course_model.dart'
import '../api_services.dart';
import '../enums.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {

  List<Course> _courses  = [];
  ApiState _state        = ApiState.idle;
  String _errorMessage   = '';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // READ — GET
  Future<void> _fetchCourses() async {
    setState(() => _state = ApiState.loading);
    try {
      final courses = await ApiService.getCourses();
      setState(() {
        _courses = courses;
        _state   = ApiState.success;
      });
    } catch (e) {
      setState(() {
        _state        = ApiState.error;
        _errorMessage = e.toString();
      });
    }
  }

  // DELETE
  Future<void> _deleteCourse(Course course) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteCourse(course.id);
        setState(() {
          _courses.removeWhere((c) => c.id == course.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course deleted'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Navigate to ADD
  Future<void> _goToAddCourse() async {
    final Course? newCourse = await Navigator.pushNamed(context, '/course-form') as Course?;
    if (newCourse != null) {
      setState(() => _courses.insert(0, newCourse));
    }
  }

  // Navigate to EDIT
  Future<void> _goToEditCourse(Course course) async {
    final Course? updatedCourse = await Navigator.pushNamed(
      context,
      '/course-form',
      arguments: course,
    ) as Course?;

    if (updatedCourse != null) {
      setState(() {
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index != -1) _courses[index] = updatedCourse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchCourses),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddCourse,
        child: Icon(Icons.add),
        tooltip: 'Add Course',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_state == ApiState.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_state == ApiState.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 12),
              Text('Something went wrong', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchCourses, child: Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(child: Text('No courses found. Tap + to add one.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(course.id.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800)),
            ),
            title: Text(course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(course.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _goToEditCourse(course),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCourse(course),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
