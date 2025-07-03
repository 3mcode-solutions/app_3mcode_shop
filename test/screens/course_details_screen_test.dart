import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/course_details_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/lesson_item.dart';

import 'course_details_screen_test.mocks.dart';

// Generate mocks for the blocs
@GenerateMocks([CourseBloc, FavoriteBloc])
void main() {
  group('CourseDetailsScreen', () {
    late MockCourseBloc mockCourseBloc;
    late MockFavoriteBloc mockFavoriteBloc;
    
    setUp(() {
      mockCourseBloc = MockCourseBloc();
      mockFavoriteBloc = MockFavoriteBloc();
    });
    
    final testCourse = CourseModel(
      id: '1',
      title: 'Test Course 1',
      description: '<p>Course description 1</p>',
      image: 'https://example.com/image1.jpg',
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
        designation: 'Senior Instructor',
      ),
      totalLessons: 10,
      totalStudents: 100,
      rating: 4.5,
      ratingCount: 50,
      isEnrolled: true,
      progress: 30,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );
    
    final testLessons = [
      LessonModel(
        id: '1',
        title: 'Lesson 1',
        content: 'Lesson content',
        summary: 'Lesson summary',
        type: LessonType.video,
        videoUrl: 'https://example.com/video1.mp4',
        thumbnailUrl: 'https://example.com/thumbnail1.jpg',
        duration: 300,
        isCompleted: true,
        isPreviewable: true,
        order: 1,
        courseId: '1',
      ),
      LessonModel(
        id: '2',
        title: 'Lesson 2',
        content: 'Lesson content 2',
        summary: 'Lesson summary 2',
        type: LessonType.document,
        documentUrl: 'https://example.com/document.pdf',
        thumbnailUrl: 'https://example.com/thumbnail2.jpg',
        duration: 0,
        isCompleted: false,
        isPreviewable: false,
        order: 2,
        courseId: '1',
      ),
    ];
    
    testWidgets('renders loading indicator when state is CourseLoading', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('renders course details when state is CourseLoaded', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(CourseLoaded(
        course: testCourse,
        lessons: testLessons,
      ));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteLoaded(
        items: [],
        favoriteIds: [],
      ));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Wait for the widget to build completely
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Test Course 1'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Senior Instructor'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('مسجل بالفعل'), findsOneWidget);
      expect(find.text('التقدم: 30%'), findsOneWidget);
      
      // Check if tabs are rendered
      expect(find.text('نظرة عامة'), findsOneWidget);
      expect(find.text('المحتوى'), findsOneWidget);
      expect(find.text('التقييمات'), findsOneWidget);
      
      // Tap on the content tab
      await tester.tap(find.text('المحتوى'));
      await tester.pumpAndSettle();
      
      // Check if lessons are rendered
      expect(find.byType(LessonItem), findsNWidgets(2));
      expect(find.text('Lesson 1'), findsOneWidget);
      expect(find.text('Lesson 2'), findsOneWidget);
    });
    
    testWidgets('renders error message when state is CourseError', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseError('Failed to load course'));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('حدث خطأ: Failed to load course'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
    
    testWidgets('adds LoadCourseById event when screen is initialized', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Assert
      verify(mockCourseBloc.add(const LoadCourseById('1'))).called(1);
    });
    
    testWidgets('adds EnrollCourse event when enroll button is tapped', (WidgetTester tester) async {
      // Arrange
      final unenrolledCourse = testCourse.copyWith(isEnrolled: false);
      
      when(mockCourseBloc.state).thenReturn(CourseLoaded(
        course: unenrolledCourse,
        lessons: testLessons,
      ));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteLoaded(
        items: [],
        favoriteIds: [],
      ));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Wait for the widget to build completely
      await tester.pumpAndSettle();
      
      // Find and tap the enroll button
      await tester.tap(find.text('التسجيل الآن'));
      
      // Assert
      verify(mockCourseBloc.add(const EnrollCourse('1'))).called(1);
    });
    
    testWidgets('adds AddToFavorites event when favorite button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(CourseLoaded(
        course: testCourse,
        lessons: testLessons,
      ));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteLoaded(
        items: [],
        favoriteIds: [],
      ));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CourseDetailsScreen(courseId: '1'),
          ),
        ),
      );
      
      // Wait for the widget to build completely
      await tester.pumpAndSettle();
      
      // Find and tap the favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      
      // Assert
      verify(mockFavoriteBloc.add(const AddToFavorites('1'))).called(1);
    });
  });
}
