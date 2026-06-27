// lib/enums.dart

enum Gender { male, female, other }

enum AuthState { idle, loading, success, error }

// Used by the course form's submit button (unchanged from before).
enum ApiState { idle, loading, success, error }

// Drives the course list UI through the Provider state manager.
// Covers the four states required by the assignment: loading, success,
// error, and empty.
enum CourseStatus { initial, loading, success, empty, error }
