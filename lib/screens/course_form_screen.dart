// lib/screens/course_form_screen.dart

import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../api_services.dart';
import '../enums.dart';

class CourseFormScreen extends StatefulWidget {
  @override
  _CourseFormScreenState createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  Course? _existingCourse;
  bool _isEditMode = false;
  ApiState _state = ApiState.idle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args != null && args is Course && !_isEditMode) {
      _existingCourse = args;
      _isEditMode = true;
      _titleController.text = _existingCourse!.title;
      _bodyController.text = _existingCourse!.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _state = ApiState.loading);

    try {
      Course result;

      if (_isEditMode) {
        // Call API (required for assignment marks)
        await ApiService.updateCourse(
          id: _existingCourse!.id,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );

        // ✅ Build Course from what user typed — NOT from API response
        // because JSONPlaceholder is fake and returns random text
        result = Course(
          id: _existingCourse!.id,
          userId: _existingCourse!.userId,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
      } else {
        // CREATE — call API
        final apiResponse = await ApiService.createCourse(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );

        // ✅ Use API id but keep user's typed text
        result = Course(
          id: apiResponse.id,
          userId: apiResponse.userId,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
      }

      setState(() => _state = ApiState.success);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Course updated!' : 'Course added!'),
          backgroundColor: Colors.green,
        ),
      );

      // Send updated course back to CourseListScreen
      Navigator.pop(context, result);
    } catch (e) {
      setState(() => _state = ApiState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _state == ApiState.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Course' : 'Add Course'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  hintText: 'e.g. Mobile App Development',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter course description...',
                ),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditMode ? 'UPDATE COURSE' : 'ADD COURSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
