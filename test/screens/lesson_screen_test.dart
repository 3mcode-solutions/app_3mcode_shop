import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/lesson_screen.dart';

import 'lesson_screen_test.mocks.dart';

// Generate mock for the bloc
@GenerateMocks([CourseBloc])
void main() {
  group('LessonScreen', () {
    late MockCourseBloc mockCourseBloc;
    
    setUp(() {
      mockCourseBloc = MockCourseBloc();
    });
    
    final testVideoLesson = LessonModel(
      id: '1',
      title: 'Video Lesson',
      content: '<p>Lesson content</p>',
      summary: 'Lesson summary',
      type: LessonType.video,
      videoUrl: 'https://example.com/video1.mp4',
      thumbnailUrl: 'https://example.com/thumbnail1.jpg',
      duration: 300,
      isCompleted: false,
      isPreviewable: true,
      order: 1,
      courseId: '1',
    );
    
    final testDocumentLesson = LessonModel(
      id: '2',
      title: 'Document Lesson',
      content: '<p>Lesson content 2</p>',
      summary: 'Lesson summary 2',
      type: LessonType.document,
      documentUrl: 'https://example.com/document.pdf',
      thumbnailUrl: 'https://example.com/thumbnail2.jpg',
      duration: 0,
      isCompleted: false,
      isPreviewable: false,
      order: 2,
      courseId: '1',
    );
    
    final testTextLesson = LessonModel(
      id: '3',
      title: 'Text Lesson',
      content: '<p>This is a text lesson with <strong>formatted</strong> content.</p>',
      summary: 'Text lesson summary',
      type: LessonType.text,
      duration: 0,
      isCompleted: true,
      isPreviewable: true,
      order: 3,
      courseId: '1',
    );
    
    testWidgets('renders loading indicator when state is CourseLoading', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '1'),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('renders video lesson when state is LessonLoaded with video type', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(LessonLoaded(lesson: testVideoLesson));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '1'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Video Lesson'), findsOneWidget);
      // Note: We can't test video player initialization in widget tests
      // But we can check if the content is rendered
      expect(find.text('Lesson content'), findsOneWidget);
    });
    
    testWidgets('renders document lesson when state is LessonLoaded with document type', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(LessonLoaded(lesson: testDocumentLesson));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '2'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Document Lesson'), findsOneWidget);
      // Note: We can't test PDF viewer initialization in widget tests
      // But we can check if the content is rendered
      expect(find.text('Lesson content 2'), findsOneWidget);
    });
    
    testWidgets('renders text lesson when state is LessonLoaded with text type', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(LessonLoaded(lesson: testTextLesson));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '3'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Text Lesson'), findsOneWidget);
      // Note: We can't test HTML rendering in widget tests
      // But we can check if the title is rendered
    });
    
    testWidgets('renders error message when state is CourseError', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseError('Failed to load lesson'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '1'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('حدث خطأ: Failed to load lesson'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
    
    testWidgets('adds LoadLessonById event when screen is initialized', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '1'),
          ),
        ),
      );
      
      // Assert
      verify(mockCourseBloc.add(const LoadLessonById('1'))).called(1);
    });
    
    testWidgets('adds CompleteLesson event when complete button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(LessonLoaded(lesson: testVideoLesson));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseBloc>.value(
            value: mockCourseBloc,
            child: const LessonScreen(courseId: '1', lessonId: '1'),
          ),
        ),
      );
      
      // Find and tap the complete button in the bottom app bar
      await tester.tap(find.text('إكمال الدرس'));
      
      // Assert
      verify(mockCourseBloc.add(const CompleteLesson('1'))).called(1);
    });
  });
}
