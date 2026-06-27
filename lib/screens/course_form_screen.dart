// lib/screens/course_form_screen.dart
//
// UI LAYER ONLY. The form collects input and hands it to CourseProvider.
// The provider (via the repository) handles the API call, the cache update,
// and — for edits — the optimistic update + rollback. The widget tree below
// is unchanged from before.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../enums.dart';

class CourseFormScreen extends StatefulWidget {
  @override
  _CourseFormScreenState createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {

  final _formKey         = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController  = TextEditingController();

  Course? _existingCourse;
  bool _isEditMode = false;
  ApiState _state  = ApiState.idle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args != null && args is Course && !_isEditMode) {
      _existingCourse       = args;
      _isEditMode           = true;
      _titleController.text = _existingCourse!.title;
      _bodyController.text  = _existingCourse!.body;
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

    final provider = context.read<CourseProvider>();
    bool ok;

    if (_isEditMode) {
      ok = await provider.updateCourse(
        course: _existingCourse!,
        title:  _titleController.text.trim(),
        body:   _bodyController.text.trim(),
      );
    } else {
      ok = await provider.createCourse(
        title: _titleController.text.trim(),
        body:  _bodyController.text.trim(),
      );
    }

    if (!mounted) return;

    if (ok) {
      setState(() => _state = ApiState.success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Course updated!' : 'Course added!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _state = ApiState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Update failed. Changes were rolled back.'
              : 'Could not add course.'),
          backgroundColor: Colors.red,
        ),
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
                  hintText:  'e.g. Mobile App Development',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText:  'Enter course description...',
                ),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Description is required' : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
                  child: isLoading
                      ? SizedBox(
                          height: 20, width: 20,
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
