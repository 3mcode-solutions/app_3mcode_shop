import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_drawer.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/courses_screen.dart';

import 'custom_drawer_test.mocks.dart';

// Generate mock for the bloc
@GenerateMocks([AuthBloc])
void main() {
  group('CustomDrawer', () {
    late MockAuthBloc mockAuthBloc;
    
    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });
    
    testWidgets('renders courses option in drawer', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const Unauthenticated());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Text('Open Drawer'),
                ),
              ),
            ),
            drawer: const CustomDrawer(),
          ),
        ),
      );
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('الكورسات'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });
    
    testWidgets('navigates to courses screen when courses option is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const Unauthenticated());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Text('Open Drawer'),
                ),
              ),
            ),
            drawer: const CustomDrawer(),
          ),
        ),
      );
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      // Tap on the courses option
      await tester.tap(find.text('الكورسات'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(CoursesScreen), findsOneWidget);
    });
  });
}
