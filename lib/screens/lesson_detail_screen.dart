import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/lesson.dart';
import '../services/progress_storage.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.onViewed,
  });

  final Lesson lesson;
  final VoidCallback onViewed;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  Player? _mediaPlayer;
  VideoController? _mediaController;
  Future<void>? _mediaOpenFuture;

  @override
  void initState() {
    super.initState();
    _setupVideoPlayer(widget.lesson.videoUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) => _persistViewed());
  }

  Future<void> _persistViewed() async {
    await ProgressStorage().markLessonViewed(widget.lesson.id);
    if (mounted) {
      widget.onViewed();
    }
  }

  @override
  void dispose() {
    _mediaPlayer?.dispose();
    super.dispose();
  }

  void _setupVideoPlayer(String url) {
    if (url.isEmpty) {
      return;
    }
    _mediaPlayer = Player();
    _mediaController = VideoController(_mediaPlayer!);
    _mediaOpenFuture = _mediaPlayer!.open(Media(url), play: false);
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return MarkdownStyleSheet(
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
      h1: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.5,
        backgroundColor: scheme.surfaceContainerHighest,
        color: scheme.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockSpacing: 14,
      listIndent: 22,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Lesson lesson = widget.lesson;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: lesson.isVideo
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: _buildVideoWidget(scheme),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: _buildDocumentBody(scheme),
            ),
    );
  }

  bool get _isHtmlDocument =>
      widget.lesson.documentFormat.toLowerCase() == 'html';

  Widget _buildDocumentBody(ColorScheme scheme) {
    final String content = widget.lesson.documentContent.trim();
    if (content.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          'Bài học này chưa có nội dung tài liệu. Vui lòng cập nhật trong Admin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: _isHtmlDocument
          ? Html(
              data: content,
              style: <String, Style>{
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.55),
                  color: scheme.onSurface,
                ),
                'pre': Style(
                  backgroundColor: scheme.surfaceContainerHighest,
                  padding: HtmlPaddings.all(14),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                'code': Style(
                  backgroundColor: scheme.surfaceContainerHighest,
                  fontFamily: 'monospace',
                  fontSize: FontSize(13.5),
                ),
                'h1': Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.w700,
                  margin: Margins.only(bottom: 12),
                ),
                'h2': Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.w700,
                  margin: Margins.only(bottom: 10),
                ),
                'h3': Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.w600,
                  margin: Margins.only(bottom: 8),
                ),
              },
            )
          : Markdown(
              data: content,
              selectable: true,
              styleSheet: _markdownStyle(context),
            ),
    );
  }

  Widget _buildVideoWidget(ColorScheme scheme) {
    if (_mediaController != null) {
      return _buildDirectVideoPlayer(scheme);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.ondemand_video_rounded,
                size: 44,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Video chưa sẵn sàng',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Bài học video chỉ hỗ trợ từ file upload trên hệ thống. Vui lòng upload video trong trang Admin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectVideoPlayer(ColorScheme scheme) {
    final VideoController controller = _mediaController!;
    return FutureBuilder<void>(
      future: _mediaOpenFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Đang tải video…',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildCannotPlayVideoWidget(
            'Không phát được video trong app.',
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(controller: controller),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCannotPlayVideoWidget(String message) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Gợi ý: MP4 (H.264 + AAC) tương thích tốt nhất.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
