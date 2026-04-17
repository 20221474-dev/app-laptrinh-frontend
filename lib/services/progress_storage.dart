import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorage {
  static const String _key = 'viewed_lessons';

  Future<Set<int>> getViewedLessonIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawIds = prefs.getStringList(_key) ?? <String>[];
    return rawIds.map(int.parse).toSet();
  }

  Future<void> markLessonViewed(int lessonId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<int> ids = await getViewedLessonIds();
    ids.add(lessonId);
    await prefs.setStringList(
      _key,
      ids.map((int id) => id.toString()).toList(),
    );
  }
}
