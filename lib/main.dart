import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/course_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const CourseListScreen(),
    );
  }
}
