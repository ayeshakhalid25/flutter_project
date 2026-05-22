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

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title':  title,
      'body':   body,
    };
  }
}
