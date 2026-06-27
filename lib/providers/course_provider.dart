// lib/providers/course_provider.dart
//
// STATE MANAGEMENT LAYER (Provider / ChangeNotifier).
// Holds the UI state (loading / success / empty / error) and the course list.
// All business logic for updating that state lives here, so the screens stay
// "dumb" and only render what the provider exposes.
//
// Optimistic updates: delete and update change the in-memory list immediately
// (instant UI), then call the repository. If the request fails, the change is
// rolled back to the previous value.

import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';
import '../enums.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider(this._repository);

  // ---- State exposed to the UI ----
  CourseStatus _status = CourseStatus.initial;
  List<Course> _courses = [];
  String _errorMessage = '';
  bool _isOffline = false; // true when the list was loaded from the cache

  CourseStatus get status => _status;
  List<Course> get courses => List.unmodifiable(_courses);
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  bool get isLoading => _status == CourseStatus.loading;

  // ---- READ ----
  Future<void> loadCourses() async {
    _status = CourseStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.fromCache; // came from local storage?
      _status =
          _courses.isEmpty ? CourseStatus.empty : CourseStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = CourseStatus.error;
    }
    notifyListeners();
  }

  // Used by pull-to-refresh.
  Future<void> refresh() => loadCourses();

  // ---- CREATE (not optimistic: we need the server-assigned id) ----
  Future<bool> createCourse({
    required String title,
    required String body,
  }) async {
    try {
      final created =
          await _repository.createCourse(title: title, body: body);
      _courses.insert(0, created);
      _status = CourseStatus.success;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- UPDATE (optimistic) ----
  Future<bool> updateCourse({
    required Course course,
    required String title,
    required String body,
  }) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index == -1) return false;

    final Course previous = _courses[index];

    // 1. Optimistically show the new values right away.
    _courses[index] = previous.copyWith(title: title, body: body);
    _status = CourseStatus.success;
    notifyListeners();

    try {
      // 2. Confirm with the server.
      final updated = await _repository.updateCourse(
        id: course.id,
        title: title,
        body: body,
      );
      final confirmIndex = _courses.indexWhere((c) => c.id == updated.id);
      if (confirmIndex != -1) _courses[confirmIndex] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      // 3. Roll back on failure.
      final rollbackIndex = _courses.indexWhere((c) => c.id == previous.id);
      if (rollbackIndex != -1) _courses[rollbackIndex] = previous;
      notifyListeners();
      return false;
    }
  }

  // ---- DELETE (optimistic) ----
  Future<bool> deleteCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index == -1) return false;

    final Course removed = _courses[index];

    // 1. Remove immediately so the UI feels instant.
    _courses.removeAt(index);
    if (_courses.isEmpty) _status = CourseStatus.empty;
    notifyListeners();

    try {
      // 2. Confirm with the server.
      await _repository.deleteCourse(course.id);
      return true;
    } catch (_) {
      // 3. Put it back exactly where it was on failure.
      _courses.insert(index, removed);
      _status = CourseStatus.success;
      notifyListeners();
      return false;
    }
  }
}
