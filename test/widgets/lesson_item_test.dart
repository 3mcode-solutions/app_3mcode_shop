import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/presentation/widgets/lesson_item.dart';

void main() {
  group('LessonItem', () {
    final testVideoLesson = LessonModel(
      id: '1',
      title: 'Video Lesson',
      content: 'Lesson content',
      summary: 'Video lesson summary',
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
      content: 'Lesson content 2',
      summary: 'Document lesson summary',
      type: LessonType.document,
      documentUrl: 'https://example.com/document.pdf',
      thumbnailUrl: 'https://example.com/thumbnail2.jpg',
      duration: 0,
      isCompleted: true,
      isPreviewable: false,
      order: 2,
      courseId: '1',
    );
    
    final testQuizLesson = LessonModel(
      id: '3',
      title: 'Quiz Lesson',
      content: 'Quiz content',
      summary: 'Quiz lesson summary',
      type: LessonType.quiz,
      duration: 0,
      isCompleted: false,
      isPreviewable: false,
      order: 3,
      courseId: '1',
    );
    
    testWidgets('renders lesson information correctly', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Video Lesson'), findsOneWidget);
      expect(find.text('Video lesson summary'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget); // 300 seconds = 5 minutes
    });
    
    testWidgets('shows video icon for video lessons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });
    
    testWidgets('shows document icon for document lessons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testDocumentLesson,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
    });
    
    testWidgets('shows quiz icon for quiz lessons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testQuizLesson,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.quiz), findsOneWidget);
    });
    
    testWidgets('shows completed status for completed lessons', (WidgetTester tester) async {
      // Arrange
      final completedLesson = testVideoLesson.copyWith(isCompleted: true);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: completedLesson,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
    
    testWidgets('shows preview label for previewable lessons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Preview'), findsOneWidget);
    });
    
    testWidgets('shows lock icon for locked lessons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {},
              isLocked: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
    
    testWidgets('calls onTap when item is tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(InkWell));
      
      // Assert
      expect(tapped, true);
    });
    
    testWidgets('does not call onTap when locked item is tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItem(
              lesson: testVideoLesson,
              onTap: () {
                tapped = true;
              },
              isLocked: true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(InkWell));
      
      // Assert
      expect(tapped, false);
    });
  });
}
