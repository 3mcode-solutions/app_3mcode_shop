import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/courses_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/course_card.dart';

import 'courses_screen_test.mocks.dart';

// Generate mocks for the blocs
@GenerateMocks([CourseBloc, FavoriteBloc])
void main() {
  group('CoursesScreen', () {
    late MockCourseBloc mockCourseBloc;
    late MockFavoriteBloc mockFavoriteBloc;
    
    setUp(() {
      mockCourseBloc = MockCourseBloc();
      mockFavoriteBloc = MockFavoriteBloc();
    });
    
    final testCourses = [
      CourseModel(
        id: '1',
        title: 'Test Course 1',
        description: 'Course description 1',
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
        ),
        totalLessons: 10,
        totalStudents: 100,
        rating: 4.5,
        ratingCount: 50,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      ),
      CourseModel(
        id: '2',
        title: 'Test Course 2',
        description: 'Course description 2',
        image: 'https://example.com/image2.jpg',
        price: '0',
        isFree: true,
        duration: '5 weeks',
        level: 'Intermediate',
        category: 'Design',
        categoryId: '2',
        instructor: const InstructorModel(
          id: '2',
          name: 'Jane Smith',
          bio: 'Instructor bio 2',
          avatar: 'https://example.com/avatar2.jpg',
        ),
        totalLessons: 5,
        totalStudents: 50,
        rating: 4.0,
        ratingCount: 20,
        createdAt: DateTime(2023, 2, 1),
        updatedAt: DateTime(2023, 2, 2),
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
            child: const CoursesScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('renders courses when state is CoursesLoaded', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(CoursesLoaded(
        courses: testCourses,
        page: 1,
        perPage: 10,
        hasReachedMax: true,
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
            child: const CoursesScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CourseCard), findsNWidgets(2));
      expect(find.text('Test Course 1'), findsOneWidget);
      expect(find.text('Test Course 2'), findsOneWidget);
    });
    
    testWidgets('renders error message when state is CourseError', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseError('Failed to load courses'));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CoursesScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('حدث خطأ: Failed to load courses'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
    
    testWidgets('renders empty message when courses list is empty', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CoursesLoaded(
        courses: [],
        page: 1,
        perPage: 10,
        hasReachedMax: true,
      ));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
            ],
            child: const CoursesScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('لا توجد كورسات متاحة'), findsOneWidget);
    });
    
    testWidgets('adds LoadCourses event when screen is initialized', (WidgetTester tester) async {
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
            child: const CoursesScreen(),
          ),
        ),
      );
      
      // Assert
      verify(mockCourseBloc.add(const LoadCourses())).called(1);
      verify(mockCourseBloc.add(const LoadCourseCategories())).called(1);
    });
    
    testWidgets('adds LoadCourses event when pull to refresh', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(CoursesLoaded(
        courses: testCourses,
        page: 1,
        perPage: 10,
        hasReachedMax: true,
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
            child: const CoursesScreen(),
          ),
        ),
      );
      
      await tester.drag(find.byType(GridView), const Offset(0, 300));
      
      // Assert
      verify(mockCourseBloc.add(const LoadCourses(forceRefresh: true))).called(1);
    });
  });
}
