// lib/models/course_model.dart

class Course {
  final int id;
  final int userId;
  final String title;
  final String body;

  Course({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id:     json['id'],
      userId: json['userId'],
      title:  json['title'],
      body:   json['body'],
    );
  }

  // Includes `id` so the object can be restored exactly from local cache.
  // The API service builds its own request bodies, so this is cache-safe.
  Map<String, dynamic> toJson() {
    return {
      'id':     id,
      'userId': userId,
      'title':  title,
      'body':   body,
    };
  }

  // Used for optimistic UI updates (build the "new" object before the
  // server confirms, then roll back to the old one on failure).
  Course copyWith({int? id, int? userId, String? title, String? body}) {
    return Course(
      id:     id     ?? this.id,
      userId: userId ?? this.userId,
      title:  title  ?? this.title,
      body:   body   ?? this.body,
    );
  }
}
