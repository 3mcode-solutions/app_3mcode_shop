import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/data/repositories/course_repository.dart';
import 'package:app_3mcode_shop/data/services/tutor_lms_service.dart';
import 'package:app_3mcode_shop/data/services/cache_service.dart';

import 'course_repository_test.mocks.dart';

// Generate mocks for the services
@GenerateMocks([TutorLmsService, CacheService])
void main() {
  group('CourseRepository', () {
    late MockTutorLmsService mockTutorLmsService;
    late MockCacheService mockCacheService;
    late CourseRepository courseRepository;
    
    setUp(() {
      // Create mock services
      mockTutorLmsService = MockTutorLmsService();
      mockCacheService = MockCacheService();
      
      // Create the repository
      courseRepository = CourseRepository();
      
      // Note: This would require modifying the CourseRepository to accept mock services
      // courseRepository = CourseRepository(
      //   tutorLmsService: mockTutorLmsService,
      //   cacheService: mockCacheService,
      // );
    });
    
    test('getCourses returns a list of courses', () async {
      // Arrange
      final coursesJson = [
        {
          "id": 1,
          "title": {"rendered": "Test Course 1"},
          "content": {"rendered": "Course content"},
          "tutor_course_img": "https://example.com/image1.jpg",
          "price": "99.99",
          "duration": "10 weeks",
          "level": "Beginner",
          "categories_name": ["Programming"],
          "categories": [1],
          "instructor": {
            "ID": "1",
            "display_name": "John Doe",
            "tutor_profile_bio": "Instructor bio",
            "tutor_avatar": "https://example.com/avatar.jpg"
          },
          "total_lessons": 10,
          "total_enrolled": 100,
          "average_rating": "4.5",
          "rating_count": 50,
          "date": "2023-01-01T00:00:00",
          "modified": "2023-01-02T00:00:00"
        },
        {
          "id": 2,
          "title": {"rendered": "Test Course 2"},
          "content": {"rendered": "Course content 2"},
          "tutor_course_img": "https://example.com/image2.jpg",
          "price": "0",
          "duration": "5 weeks",
          "level": "Intermediate",
          "categories_name": ["Design"],
          "categories": [2],
          "instructor": {
            "ID": "2",
            "display_name": "Jane Smith",
            "tutor_profile_bio": "Instructor bio 2",
            "tutor_avatar": "https://example.com/avatar2.jpg"
          },
          "total_lessons": 5,
          "total_enrolled": 50,
          "average_rating": "4.0",
          "rating_count": 20,
          "date": "2023-02-01T00:00:00",
          "modified": "2023-02-02T00:00:00"
        }
      ];
      
      // Mock the service response
      when(mockTutorLmsService.getCourses(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        search: anyNamed('search'),
        category: anyNamed('category'),
        instructor: anyNamed('instructor'),
        orderBy: anyNamed('orderBy'),
        order: anyNamed('order'),
      )).thenAnswer((_) async => coursesJson);
      
      // Mock the cache service
      when(mockCacheService.getOrFetchData(
        cacheKey: anyNamed('cacheKey'),
        fetchFunction: anyNamed('fetchFunction'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => coursesJson);
      
      // Act
      // final courses = await courseRepository.getCourses();
      
      // Assert
      // expect(courses, isA<List<CourseModel>>());
      // expect(courses.length, 2);
      // expect(courses[0].title, 'Test Course 1');
      // expect(courses[1].title, 'Test Course 2');
      
      // Skip this test for now since we can't easily mock the services
      skip('Implement when CourseRepository accepts mock services');
    });
    
    test('getCourseById returns a course', () async {
      // Arrange
      final courseJson = {
        "id": 1,
        "title": {"rendered": "Test Course 1"},
        "content": {"rendered": "Course content"},
        "tutor_course_img": "https://example.com/image1.jpg",
        "price": "99.99",
        "duration": "10 weeks",
        "level": "Beginner",
        "categories_name": ["Programming"],
        "categories": [1],
        "instructor": {
          "ID": "1",
          "display_name": "John Doe",
          "tutor_profile_bio": "Instructor bio",
          "tutor_avatar": "https://example.com/avatar.jpg"
        },
        "total_lessons": 10,
        "total_enrolled": 100,
        "average_rating": "4.5",
        "rating_count": 50,
        "date": "2023-01-01T00:00:00",
        "modified": "2023-01-02T00:00:00"
      };
      
      final lessonsJson = [
        {
          "id": 1,
          "title": "Lesson 1",
          "content": "Lesson content",
          "excerpt": "Lesson summary",
          "video": "https://example.com/video1.mp4",
          "thumbnail": "https://example.com/thumbnail1.jpg",
          "video_duration_sec": 300,
          "is_completed": false,
          "is_preview": true,
          "order": 1,
          "course_id": "1"
        }
      ];
      
      // Mock the service responses
      when(mockTutorLmsService.getCourse(any))
          .thenAnswer((_) async => courseJson);
      
      when(mockTutorLmsService.getCourseLessons(any))
          .thenAnswer((_) async => lessonsJson);
      
      // Mock the cache service
      when(mockCacheService.getOrFetchData(
        cacheKey: anyNamed('cacheKey'),
        fetchFunction: anyNamed('fetchFunction'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => {...courseJson, 'lessons': lessonsJson});
      
      // Act
      // final course = await courseRepository.getCourseById('1');
      
      // Assert
      // expect(course, isA<CourseModel>());
      // expect(course!.title, 'Test Course 1');
      // expect(course.lessons.length, 1);
      // expect(course.lessons[0].title, 'Lesson 1');
      
      // Skip this test for now since we can't easily mock the services
      skip('Implement when CourseRepository accepts mock services');
    });
    
    test('getCourseLessons returns a list of lessons', () async {
      // Arrange
      final lessonsJson = [
        {
          "id": 1,
          "title": "Lesson 1",
          "content": "Lesson content",
          "excerpt": "Lesson summary",
          "video": "https://example.com/video1.mp4",
          "thumbnail": "https://example.com/thumbnail1.jpg",
          "video_duration_sec": 300,
          "is_completed": false,
          "is_preview": true,
          "order": 1,
          "course_id": "1"
        },
        {
          "id": 2,
          "title": "Lesson 2",
          "content": "Lesson content 2",
          "excerpt": "Lesson summary 2",
          "video": "",
          "attachments": [{"url": "https://example.com/document.pdf"}],
          "thumbnail": "https://example.com/thumbnail2.jpg",
          "video_duration_sec": 0,
          "is_completed": false,
          "is_preview": false,
          "order": 2,
          "course_id": "1"
        }
      ];
      
      // Mock the service response
      when(mockTutorLmsService.getCourseLessons(any))
          .thenAnswer((_) async => lessonsJson);
      
      // Mock the cache service
      when(mockCacheService.getOrFetchData(
        cacheKey: anyNamed('cacheKey'),
        fetchFunction: anyNamed('fetchFunction'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => lessonsJson);
      
      // Act
      // final lessons = await courseRepository.getCourseLessons('1');
      
      // Assert
      // expect(lessons, isA<List<LessonModel>>());
      // expect(lessons.length, 2);
      // expect(lessons[0].title, 'Lesson 1');
      // expect(lessons[1].title, 'Lesson 2');
      
      // Skip this test for now since we can't easily mock the services
      skip('Implement when CourseRepository accepts mock services');
    });
    
    test('getLessonById returns a lesson', () async {
      // Arrange
      final lessonJson = {
        "id": 1,
        "title": "Lesson 1",
        "content": "Lesson content",
        "excerpt": "Lesson summary",
        "video": "https://example.com/video1.mp4",
        "thumbnail": "https://example.com/thumbnail1.jpg",
        "video_duration_sec": 300,
        "is_completed": false,
        "is_preview": true,
        "order": 1,
        "course_id": "1"
      };
      
      // Mock the service response
      when(mockTutorLmsService.getLesson(any))
          .thenAnswer((_) async => lessonJson);
      
      // Mock the cache service
      when(mockCacheService.getOrFetchData(
        cacheKey: anyNamed('cacheKey'),
        fetchFunction: anyNamed('fetchFunction'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => lessonJson);
      
      // Act
      // final lesson = await courseRepository.getLessonById('1');
      
      // Assert
      // expect(lesson, isA<LessonModel>());
      // expect(lesson!.title, 'Lesson 1');
      
      // Skip this test for now since we can't easily mock the services
      skip('Implement when CourseRepository accepts mock services');
    });
  });
}
