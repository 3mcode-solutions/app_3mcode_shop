import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/presentation/widgets/course_card.dart';

void main() {
  group('CourseCard', () {
    final testCourse = CourseModel(
      id: '1',
      title: 'Test Course',
      description: 'Course description',
      image: 'https://example.com/image.jpg',
      price: '99.99',
      isFree: false,
      duration: '10 weeks',
      level: 'Beginner',
      category: 'Programming',
      categoryId: '1',
      instructor: const InstructorModel(
        id: '1',
        name: 'John Doe',
        bio: 'Instructor bio',
        avatar: 'https://example.com/avatar.jpg',
      ),
      totalLessons: 10,
      totalStudents: 100,
      rating: 4.5,
      ratingCount: 50,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );
    
    testWidgets('renders course information correctly', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      bool favoriteTapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {
                tapped = true;
              },
              isFavorite: false,
              onToggleFavorite: () {
                favoriteTapped = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Test Course'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('4.5 (50)'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
    });
    
    testWidgets('shows free label for free courses', (WidgetTester tester) async {
      // Arrange
      final freeCourse = testCourse.copyWith(price: '0', isFree: true);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: freeCourse,
              onTap: () {},
              isFavorite: false,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('مجاني'), findsOneWidget);
    });
    
    testWidgets('shows filled heart icon when course is favorite', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {},
              isFavorite: true,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
    
    testWidgets('shows outline heart icon when course is not favorite', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {},
              isFavorite: false,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });
    
    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {
                tapped = true;
              },
              isFavorite: false,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(InkWell));
      
      // Assert
      expect(tapped, true);
    });
    
    testWidgets('calls onToggleFavorite when favorite icon is tapped', (WidgetTester tester) async {
      // Arrange
      bool favoriteTapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {},
              isFavorite: false,
              onToggleFavorite: () {
                favoriteTapped = true;
              },
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.favorite_border));
      
      // Assert
      expect(favoriteTapped, true);
    });
    
    testWidgets('shows progress bar for enrolled courses with progress', (WidgetTester tester) async {
      // Arrange
      final enrolledCourse = testCourse.copyWith(isEnrolled: true, progress: 50);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: enrolledCourse,
              onTap: () {},
              isFavorite: false,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Progress: 50%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
    
    testWidgets('does not show progress bar for non-enrolled courses', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: testCourse,
              onTap: () {},
              isFavorite: false,
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Progress: 0%'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
