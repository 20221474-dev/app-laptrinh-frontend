import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../models/lesson.dart';

class SearchResult {
  const SearchResult({required this.courses, required this.lessons});

  final List<Course> courses;
  final List<Lesson> lessons;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.0.2.2:8000/api",
  );
  final http.Client _client;

  Future<List<Course>> fetchCourses() async {
    final response = await _client.get(Uri.parse("$_baseUrl/courses/"));
    if (response.statusCode != 200) {
      throw Exception("Khong tai duoc danh sach khoa hoc");
    }

    final List<dynamic> payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map((dynamic item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Course> fetchCourseDetail(int courseId) async {
    final response = await _client.get(
      Uri.parse("$_baseUrl/courses/$courseId/"),
    );
    if (response.statusCode != 200) {
      throw Exception("Khong tai duoc chi tiet khoa hoc");
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Course.fromJson(payload);
  }

  Future<SearchResult> search(String query) async {
    final Uri uri = Uri.parse(
      "$_baseUrl/search/",
    ).replace(queryParameters: <String, String>{"q": query});

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Khong the tim kiem");
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<Course> courses = (payload["courses"] as List<dynamic>)
        .map((dynamic item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
    final List<Lesson> lessons = (payload["lessons"] as List<dynamic>)
        .map((dynamic item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResult(courses: courses, lessons: lessons);
  }
}
