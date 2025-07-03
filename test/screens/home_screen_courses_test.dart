import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product.dart';
import 'package:app_3mcode_shop/presentation/blocs/category/category.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart.dart';
import 'package:app_3mcode_shop/presentation/screens/home/home_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/course_card.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

import 'home_screen_courses_test.mocks.dart';

// Generate mocks for the blocs
@GenerateMocks([
  CourseBloc,
  FavoriteBloc,
  ProductBloc,
  CategoryBloc,
  CartBloc,
])
void main() {
  group('HomeScreen Courses Section', () {
    late MockCourseBloc mockCourseBloc;
    late MockFavoriteBloc mockFavoriteBloc;
    late MockProductBloc mockProductBloc;
    late MockCategoryBloc mockCategoryBloc;
    late MockCartBloc mockCartBloc;
    
    setUp(() {
      mockCourseBloc = MockCourseBloc();
      mockFavoriteBloc = MockFavoriteBloc();
      mockProductBloc = MockProductBloc();
      mockCategoryBloc = MockCategoryBloc();
      mockCartBloc = MockCartBloc();
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
    
    testWidgets('renders courses section when courses are loaded', (WidgetTester tester) async {
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
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<CartBloc>.value(value: mockCartBloc),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.byType(CourseCard), findsNWidgets(2));
      expect(find.text('Test Course 1'), findsOneWidget);
      expect(find.text('Test Course 2'), findsOneWidget);
    });
    
    testWidgets('renders loading indicator when courses are loading', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<CartBloc>.value(value: mockCartBloc),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
    
    testWidgets('renders error message when courses fail to load', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseError('Failed to load courses'));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<CartBloc>.value(value: mockCartBloc),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.text('حدث خطأ: Failed to load courses'), findsOneWidget);
    });
    
    testWidgets('renders empty message when no courses are available', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CoursesLoaded(
        courses: [],
        page: 1,
        perPage: 10,
        hasReachedMax: true,
      ));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<CartBloc>.value(value: mockCartBloc),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.text('لا توجد كورسات متاحة'), findsOneWidget);
    });
    
    testWidgets('adds LoadCourses event when screen is initialized', (WidgetTester tester) async {
      // Arrange
      when(mockCourseBloc.state).thenReturn(const CourseLoading());
      when(mockFavoriteBloc.state).thenReturn(const FavoriteInitial());
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<CartBloc>.value(value: mockCartBloc),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
      
      // Assert
      verify(mockCourseBloc.add(const LoadCourses(perPage: 5))).called(1);
    });
  });
}
