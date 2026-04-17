import 'lesson.dart';

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.lessons = const <Lesson>[],
  });

  final int id;
  final String name;
  final String shortDescription;
  final List<Lesson> lessons;

  factory Course.fromJson(Map<String, dynamic> json) {
    final dynamic rawLessons = json["lessons"];
    final List<Lesson> parsedLessons = rawLessons is List
        ? rawLessons
              .map(
                (dynamic item) => Lesson.fromJson(item as Map<String, dynamic>),
              )
              .toList()
        : <Lesson>[];

    return Course(
      id: json["id"] as int,
      name: json["name"] as String? ?? "",
      shortDescription: json["short_description"] as String? ?? "",
      lessons: parsedLessons,
    );
  }
}
