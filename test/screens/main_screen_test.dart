import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product.dart';
import 'package:app_3mcode_shop/presentation/blocs/category/category.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/screens/main_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/courses_screen.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

import 'main_screen_test.mocks.dart';

// Generate mocks for the blocs
@GenerateMocks([
  CartBloc,
  ProductBloc,
  CategoryBloc,
  FavoriteBloc,
  CourseBloc,
])
void main() {
  group('MainScreen', () {
    late MockCartBloc mockCartBloc;
    late MockProductBloc mockProductBloc;
    late MockCategoryBloc mockCategoryBloc;
    late MockFavoriteBloc mockFavoriteBloc;
    late MockCourseBloc mockCourseBloc;
    
    setUp(() {
      mockCartBloc = MockCartBloc();
      mockProductBloc = MockProductBloc();
      mockCategoryBloc = MockCategoryBloc();
      mockFavoriteBloc = MockFavoriteBloc();
      mockCourseBloc = MockCourseBloc();
    });
    
    testWidgets('renders courses tab in bottom navigation bar', (WidgetTester tester) async {
      // Arrange
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteLoaded(items: [], favoriteIds: []));
      when(mockCourseBloc.state).thenReturn(const CoursesLoaded(courses: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CartBloc>.value(value: mockCartBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
            ],
            child: const MainScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });
    
    testWidgets('navigates to courses screen when courses tab is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockCartBloc.state).thenReturn(const CartLoaded(items: []));
      when(mockProductBloc.state).thenReturn(const ProductLoaded(products: []));
      when(mockCategoryBloc.state).thenReturn(const CategoryLoaded(categories: []));
      when(mockFavoriteBloc.state).thenReturn(const FavoriteLoaded(items: [], favoriteIds: []));
      when(mockCourseBloc.state).thenReturn(const CoursesLoaded(courses: []));
      
      // Mock the localization
      AppLocalizations.delegate.load(const Locale('en'));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CartBloc>.value(value: mockCartBloc),
              BlocProvider<ProductBloc>.value(value: mockProductBloc),
              BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
              BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
              BlocProvider<CourseBloc>.value(value: mockCourseBloc),
            ],
            child: const MainScreen(),
          ),
        ),
      );
      
      // Tap on the courses tab
      await tester.tap(find.text('الكورسات'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(CoursesScreen), findsOneWidget);
    });
  });
}
