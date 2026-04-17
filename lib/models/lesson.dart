class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.lessonType,
    required this.videoUrl,
    required this.documentFormat,
    required this.documentContent,
  });

  final int id;
  final String title;
  final String lessonType;
  final String videoUrl;
  final String documentFormat;
  final String documentContent;

  bool get isVideo => lessonType == "video";

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json["id"] as int,
      title: json["title"] as String? ?? "",
      lessonType: json["lesson_type"] as String? ?? "",
      videoUrl: json["video_url"] as String? ?? "",
      documentFormat: json["document_format"] as String? ?? "",
      documentContent: json["document_content"] as String? ?? "",
    );
  }
}
