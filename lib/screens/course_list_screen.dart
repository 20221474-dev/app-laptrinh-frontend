import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import '../widgets/section_header.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Course>> _coursesFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Course> _searchCourses = <Course>[];
  List<Lesson> _searchLessons = <Lesson>[];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _apiService.fetchCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchCourses = <Course>[];
        _searchLessons = <Lesson>[];
      });
      return;
    }

    final SearchResult result = await _apiService.search(query);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSearching = true;
      _searchCourses = result.courses;
      _searchLessons = result.lessons;
    });
  }

  void _openCourse(int courseId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            CourseDetailScreen(courseId: courseId),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có kết quả',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử từ khóa khác hoặc xóa ô tìm kiếm để xem toàn bộ khóa học.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_searchCourses.isEmpty && _searchLessons.isEmpty) {
      return _buildEmptySearch();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        if (_searchCourses.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'Khóa học'),
          ..._searchCourses.map(_buildCourseCard),
        ],
        if (_searchCourses.isNotEmpty && _searchLessons.isNotEmpty)
          const SizedBox(height: 8),
        if (_searchLessons.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'Bài học'),
          ..._searchLessons.map(_buildLessonSearchTile),
        ],
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openCourse(course.id),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: scheme.onPrimaryContainer,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonSearchTile(Lesson lesson) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isVideo = lesson.lessonType == 'video';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            child: Icon(
              isVideo
                  ? Icons.play_circle_outline_rounded
                  : Icons.article_outlined,
            ),
          ),
          title: Text(
            lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            isVideo ? 'Video' : 'Tài liệu',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tải được danh sách',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Kiểm tra backend đang chạy và API_BASE_URL.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Khóa học')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Chọn khóa học để bắt đầu',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('search_input'),
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm khóa học hoặc bài học…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: scheme.primary,
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Tìm',
                      onPressed: _performSearch,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isSearching
                  ? _buildSearchResult()
                  : FutureBuilder<List<Course>>(
                      future: _coursesFuture,
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<Course>> snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return _buildErrorState();
                            }
                            final List<Course> courses = snapshot.data!;
                            if (courses.isEmpty) {
                              return const Center(
                                child: Text('Chưa có khóa học'),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: courses.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildCourseCard(courses[index]);
                              },
                            );
                          },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
