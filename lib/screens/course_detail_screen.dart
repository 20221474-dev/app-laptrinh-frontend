import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import '../services/progress_storage.dart';
import '../widgets/section_header.dart';
import 'lesson_detail_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _apiService = ApiService();
  final ProgressStorage _progressStorage = ProgressStorage();
  late Future<Course> _courseFuture;
  Set<int> _viewedLessonIds = <int>{};

  @override
  void initState() {
    super.initState();
    _courseFuture = _apiService.fetchCourseDetail(widget.courseId);
    _loadViewedLessons();
  }

  Future<void> _loadViewedLessons() async {
    final Set<int> ids = await _progressStorage.getViewedLessonIds();
    if (!mounted) {
      return;
    }
    setState(() {
      _viewedLessonIds = ids;
    });
  }

  Future<void> _openLesson(Lesson lesson) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            LessonDetailScreen(lesson: lesson, onViewed: _loadViewedLessons),
      ),
    );
    await _loadViewedLessons();
  }

  Widget _lessonTile(Lesson lesson) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isVideo = lesson.lessonType == 'video';
    final bool viewed = _viewedLessonIds.contains(lesson.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openLesson(lesson),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isVideo
                        ? scheme.primaryContainer
                        : scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isVideo
                        ? Icons.play_circle_outline_rounded
                        : Icons.article_outlined,
                    color: isVideo
                        ? scheme.onPrimaryContainer
                        : scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: <Widget>[
                          _TypeChip(
                            label: isVideo ? 'Video' : 'Tài liệu',
                            isVideo: isVideo,
                          ),
                          if (viewed) _DoneChip(colorScheme: scheme),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (viewed) ...<Widget>[
                      Icon(
                        Icons.check_circle_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(Icons.chevron_right_rounded, color: scheme.outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết khóa học')),
      body: FutureBuilder<Course>(
        future: _courseFuture,
        builder: (BuildContext context, AsyncSnapshot<Course> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: scheme.outline,
                    ),
                    const SizedBox(height: 16),
                    const Text('Không tải được khóa học'),
                  ],
                ),
              ),
            );
          }

          final Course course = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      scheme.primaryContainer,
                      scheme.secondaryContainer.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.school_rounded,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tổng quan',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      course.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Danh sách bài học',
                subtitle: '${course.lessons.length} bài',
              ),
              ...course.lessons.map(_lessonTile),
            ],
          );
        },
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.isVideo});

  final String label;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_rounded,
            size: 14,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Đã học',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
