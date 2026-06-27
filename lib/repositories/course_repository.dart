// lib/repositories/course_repository.dart
//
// REPOSITORY LAYER.
// The only place that decides WHERE data comes from.
//   UI -> Provider -> Repository -> (ApiService | LocalStorageService)
//
// Offline-first read strategy:
//   * Try the API.
//       - success -> cache the result and return it (fromCache = false).
//       - failure (no internet / server down) -> return the cached copy
//         (fromCache = true) so the UI can show an "offline" banner.
//   * If the cache is also empty, rethrow so the UI shows its error state.

import '../models/course_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

// Small result holder so the provider knows if the data came from the
// cache (offline) or fresh from the API.
class CoursesResult {
  final List<Course> courses;
  final bool fromCache;
  CoursesResult(this.courses, {required this.fromCache});
}

class CourseRepository {
  final LocalStorageService _local;

  CourseRepository({LocalStorageService? localStorage})
      : _local = localStorage ?? LocalStorageService();

  // READ — decides between API and local storage.
  Future<CoursesResult> getCourses() async {
    try {
      final courses = await ApiService.getCourses();
      await _local.saveCourses(courses); // keep the cache in sync
      return CoursesResult(courses, fromCache: false);
    } catch (e) {
      final cached = await _local.getCourses();
      if (cached.isNotEmpty) {
        return CoursesResult(cached, fromCache: true);
      }
      rethrow; // nothing online and nothing cached
    }
  }

  // CREATE — API first, then update cache.
  Future<Course> createCourse({
    required String title,
    required String body,
  }) async {
    final created = await ApiService.createCourse(title: title, body: body);
    final cached = await _local.getCourses();
    cached.insert(0, created);
    await _local.saveCourses(cached);
    return created;
  }

  // UPDATE — API first, then update cache.
  Future<Course> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    final updated =
        await ApiService.updateCourse(id: id, title: title, body: body);
    final cached = await _local.getCourses();
    final index = cached.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      cached[index] = updated;
    } else {
      cached.insert(0, updated);
    }
    await _local.saveCourses(cached);
    return updated;
  }

  // DELETE — API first, then update cache.
  Future<void> deleteCourse(int id) async {
    await ApiService.deleteCourse(id);
    final cached = await _local.getCourses();
    cached.removeWhere((c) => c.id == id);
    await _local.saveCourses(cached);
  }
}
