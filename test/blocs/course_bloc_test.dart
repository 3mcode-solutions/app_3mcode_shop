import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/data/repositories/course_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';

import 'course_bloc_test.mocks.dart';

// Generate mock for the repository
@GenerateMocks([CourseRepository])
void main() {
  group('CourseBloc', () {
    late MockCourseRepository mockCourseRepository;
    late CourseBloc courseBloc;
    
    setUp(() {
      mockCourseRepository = MockCourseRepository();
      courseBloc = CourseBloc(courseRepository: mockCourseRepository);
    });
    
    tearDown(() {
      courseBloc.close();
    });
    
    test('initial state is CourseInitial', () {
      expect(courseBloc.state, isA<CourseInitial>());
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
        isCompleted: false,
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
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, CoursesLoaded] when LoadCourses is added',
      build: () {
        when(mockCourseRepository.getCourses(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          search: anyNamed('search'),
          category: anyNamed('category'),
          instructor: anyNamed('instructor'),
          orderBy: anyNamed('orderBy'),
          order: anyNamed('order'),
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => testCourses);
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadCourses()),
      expect: () => [
        const CourseLoading(),
        CoursesLoaded(
          courses: testCourses,
          page: 1,
          perPage: 10,
          hasReachedMax: true,
        ),
      ],
    );
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, CourseLoaded] when LoadCourseById is added',
      build: () {
        when(mockCourseRepository.getCourseById(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => testCourses[0]);
        
        when(mockCourseRepository.getCourseLessons(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => testLessons);
        
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadCourseById('1')),
      expect: () => [
        const CourseLoading(),
        CourseLoaded(
          course: testCourses[0],
          lessons: testLessons,
        ),
      ],
    );
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, CourseLessonsLoaded] when LoadCourseLessons is added',
      build: () {
        when(mockCourseRepository.getCourseLessons(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => testLessons);
        
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadCourseLessons('1')),
      expect: () => [
        const CourseLoading(),
        CourseLessonsLoaded(
          courseId: '1',
          lessons: testLessons,
        ),
      ],
    );
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, LessonLoaded] when LoadLessonById is added',
      build: () {
        when(mockCourseRepository.getLessonById(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => testLessons[0]);
        
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadLessonById('1')),
      expect: () => [
        const CourseLoading(),
        LessonLoaded(lesson: testLessons[0]),
      ],
    );
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, CourseError] when LoadCourseById fails',
      build: () {
        when(mockCourseRepository.getCourseById(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => null);
        
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadCourseById('999')),
      expect: () => [
        const CourseLoading(),
        const CourseError('Course not found'),
      ],
    );
    
    blocTest<CourseBloc, CourseState>(
      'emits [CourseLoading, CourseError] when LoadLessonById fails',
      build: () {
        when(mockCourseRepository.getLessonById(
          any,
          forceRefresh: anyNamed('forceRefresh'),
        )).thenAnswer((_) async => null);
        
        return courseBloc;
      },
      act: (bloc) => bloc.add(const LoadLessonById('999')),
      expect: () => [
        const CourseLoading(),
        const CourseError('Lesson not found'),
      ],
    );
  });
}
