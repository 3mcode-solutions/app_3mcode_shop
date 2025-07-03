import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/data/models/quiz_model.dart';
import 'package:app_3mcode_shop/data/models/assignment_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/lesson_comments_section.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/quiz_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/assignment_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    // Load lesson details
    context.read<CourseBloc>().add(LoadLessonById(widget.lessonId));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String videoUrl) async {
    if (_isVideoInitialized) return;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

    try {
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  'حدث خطأ أثناء تشغيل الفيديو: $errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الدرس',
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              context.read<CourseBloc>().add(CompleteLesson(widget.lessonId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تحديد الدرس كمكتمل'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CourseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حدث خطأ: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CourseBloc>().add(
                        LoadLessonById(widget.lessonId, forceRefresh: true),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is LessonLoaded) {
            final lesson = state.lesson;

            // Initialize video if needed
            if (lesson.type == LessonType.video &&
                lesson.videoUrl.isNotEmpty &&
                !_isVideoInitialized) {
              _initializeVideo(lesson.videoUrl);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson title
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Lesson content based on type
                  _buildLessonContent(lesson),

                  // Lesson content text
                  if (lesson.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Html(
                        data: lesson.content,
                        style: {
                          'body': Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.5),
                          ),
                        },
                      ),
                    ),

                  // Comments section
                  LessonCommentsSection(
                    lessonId: widget.lessonId,
                    courseId: widget.courseId,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is LessonLoaded) {
            return BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous lesson button
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate to previous lesson
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'سيتم تفعيل التنقل بين الدروس قريباً',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('السابق'),
                    ),
                    // Complete lesson button
                    ElevatedButton(
                      onPressed: () {
                        context.read<CourseBloc>().add(
                          CompleteLesson(widget.lessonId),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديد الدرس كمكتمل'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('إكمال الدرس'),
                    ),
                    // Next lesson button
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate to next lesson
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'سيتم تفعيل التنقل بين الدروس قريباً',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('التالي'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLessonContent(LessonModel lesson) {
    switch (lesson.type) {
      case LessonType.video:
        if (lesson.videoUrl.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا يوجد فيديو متاح لهذا الدرس',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        if (!_isVideoInitialized) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        );

      case LessonType.document:
        if (lesson.documentUrl.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا يوجد مستند متاح لهذا الدرس',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        if (lesson.documentUrl.toLowerCase().endsWith('.pdf')) {
          return SizedBox(
            height: 500,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'ملف PDF: ${lesson.documentUrl.split('/').last}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open PDF in browser
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم تفعيل عرض ملفات PDF قريباً'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('فتح ملف PDF'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مستند: ${lesson.documentUrl.split('/').last}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement document download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم تفعيل تحميل المستندات قريباً'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل المستند'),
                  ),
                ],
              ),
            ),
          );
        }

      case LessonType.quiz:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.quiz, size: 48, color: Colors.purple),
                const SizedBox(height: 8),
                const Text(
                  'اختبار',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Create a sample quiz for demonstration
                    final quiz = QuizModel(
                      id: 'sample_quiz_${lesson.id}',
                      lessonId: lesson.id,
                      title: 'اختبار: ${lesson.title}',
                      description: 'اختبار تجريبي للدرس ${lesson.title}',
                      timeLimit: 10, // 10 minutes
                      passingPercentage: 70,
                      questions: [
                        QuizQuestionModel(
                          id: 'q1',
                          question: 'ما هو Flutter؟',
                          options: [
                            'لغة برمجة',
                            'إطار عمل لتطوير واجهات المستخدم',
                            'قاعدة بيانات',
                            'نظام تشغيل',
                          ],
                          correctAnswerIndex: 1,
                          explanation:
                              'Flutter هو إطار عمل مفتوح المصدر لتطوير واجهات المستخدم من Google.',
                        ),
                        QuizQuestionModel(
                          id: 'q2',
                          question: 'أي من التالي ليس من مميزات Flutter؟',
                          options: [
                            'Hot Reload',
                            'أداء عالي',
                            'واجهة مستخدم جذابة',
                            'يحتاج إلى JVM للتشغيل',
                          ],
                          correctAnswerIndex: 3,
                          explanation:
                              'Flutter لا يحتاج إلى JVM للتشغيل، بل يستخدم محرك Dart.',
                        ),
                        QuizQuestionModel(
                          id: 'q3',
                          question: 'ما هي لغة البرمجة المستخدمة في Flutter؟',
                          options: ['Java', 'Kotlin', 'Dart', 'Swift'],
                          correctAnswerIndex: 2,
                          explanation:
                              'Flutter يستخدم لغة Dart التي طورتها Google.',
                        ),
                      ],
                    );

                    // Navigate to the quiz screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuizScreen(
                              quiz: quiz,
                              onComplete: (score) {
                                // Mark the lesson as completed when the quiz is completed
                                context.read<CourseBloc>().add(
                                  CompleteLesson(lesson.id),
                                );

                                // Show a success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم إكمال الاختبار بنتيجة: $score%',
                                    ),
                                    backgroundColor:
                                        score >= quiz.passingPercentage
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                );
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text('بدء الاختبار'),
                ),
              ],
            ),
          ),
        );

      case LessonType.assignment:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.assignment, size: 48, color: Colors.orange),
                const SizedBox(height: 8),
                const Text(
                  'واجب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Create a sample assignment for demonstration
                    final assignment = AssignmentModel(
                      id: 'sample_assignment_${lesson.id}',
                      lessonId: lesson.id,
                      title: 'واجب: ${lesson.title}',
                      description: '''
<h3>تعليمات الواجب</h3>
<p>هذا واجب تجريبي للدرس ${lesson.title}. يرجى إكمال المهام التالية:</p>
<ol>
  <li>قم بإنشاء تطبيق Flutter بسيط يعرض قائمة من العناصر.</li>
  <li>أضف وظيفة البحث في القائمة.</li>
  <li>قم بتنفيذ واجهة مستخدم جذابة باستخدام Material Design.</li>
  <li>قم بتوثيق الكود الخاص بك بشكل جيد.</li>
</ol>
<p>يمكنك تحميل ملفات المشروع أو كتابة وصف لما قمت به في مربع النص أدناه.</p>
''',
                      dueDate: DateTime.now().add(const Duration(days: 7)),
                      maxPoints: 100,
                      status: AssignmentStatus.notStarted,
                    );

                    // Navigate to the assignment screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AssignmentScreen(
                              assignment: assignment,
                              onSubmit: (text, files) {
                                // Mark the lesson as completed when the assignment is submitted
                                context.read<CourseBloc>().add(
                                  CompleteLesson(lesson.id),
                                );

                                // Show a success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم تسليم الواجب بنجاح'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text('تسليم الواجب'),
                ),
              ],
            ),
          ),
        );

      case LessonType.text:
      default:
        return const SizedBox.shrink();
    }
  }
}
