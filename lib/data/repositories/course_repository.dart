import 'package:flutter/foundation.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';
import 'package:app_3mcode_shop/data/services/tutor_lms_service.dart';
import 'package:app_3mcode_shop/data/services/cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

/// Repository class for managing course data
class CourseRepository {
  // Singleton pattern
  static final CourseRepository _instance = CourseRepository._internal();

  factory CourseRepository() {
    return _instance;
  }

  CourseRepository._internal();

  // Services
  final TutorLmsService _tutorLmsService = TutorLmsService();
  final CacheService _cacheService = CacheService();

  // Hive box names
  final String _coursesBoxName = 'courses';
  final String _lessonsBoxName = 'lessons';
  final String _instructorsBoxName = 'instructors';
  final String _categoriesBoxName = 'course_categories';
  final String _reviewsBoxName = 'course_reviews';
  final String _commentsBoxName = 'lesson_comments';

  /// Get all courses
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
    String? instructor,
    String? orderBy = 'date',
    String? order = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key based on the parameters
      final cacheKey =
          'courses_${page}_${perPage}_${search ?? ''}_${category ?? ''}_${instructor ?? ''}_${orderBy ?? ''}_${order ?? ''}';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch courses from Tutor LMS API
          final courses = await _tutorLmsService.getCourses(
            page: page,
            perPage: perPage,
            search: search,
            category: category,
            instructor: instructor,
            orderBy: orderBy,
            order: order,
          );

          // Save courses locally for offline use
          await _saveCoursesLocally(
            courses.map((course) => CourseModel.fromJson(course)).toList(),
          );

          return courses;
        },
      );

      // Convert to CourseModel list
      if (data is List) {
        return data.map((course) => CourseModel.fromJson(course)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching courses: $e');

      // Fallback to local data in case of error
      return await _getLocalCourses();
    }
  }

  /// Get a specific course by ID
  Future<CourseModel?> getCourseById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'course_$id';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch course from Tutor LMS API
          final course = await _tutorLmsService.getCourse(id);

          // Fetch lessons for this course
          final lessons = await _tutorLmsService.getCourseLessons(id);

          // Add lessons to the course data
          course['lessons'] = lessons;

          // Save course locally for offline use
          await _saveCourseLocally(CourseModel.fromJson(course));

          return course;
        },
      );

      // Convert to CourseModel
      if (data != null) {
        return CourseModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching course: $e');

      // Fallback to local data in case of error
      return await _getLocalCourse(id);
    }
  }

  /// Get lessons for a specific course
  Future<List<LessonModel>> getCourseLessons(
    String courseId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'course_${courseId}_lessons';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch lessons from Tutor LMS API
          final lessons = await _tutorLmsService.getCourseLessons(courseId);

          // Save lessons locally for offline use
          await _saveLessonsLocally(
            lessons.map((lesson) => LessonModel.fromJson(lesson)).toList(),
          );

          return lessons;
        },
      );

      // Convert to LessonModel list
      if (data is List) {
        return data.map((lesson) => LessonModel.fromJson(lesson)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching lessons: $e');

      // Fallback to local data in case of error
      return await _getLocalLessons(courseId);
    }
  }

  /// Get a specific lesson by ID
  Future<LessonModel?> getLessonById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'lesson_$id';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch lesson from Tutor LMS API
          final lesson = await _tutorLmsService.getLesson(id);

          // Save lesson locally for offline use
          await _saveLessonLocally(LessonModel.fromJson(lesson));

          return lesson;
        },
      );

      // Convert to LessonModel
      if (data != null) {
        return LessonModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching lesson: $e');

      // Fallback to local data in case of error
      return await _getLocalLesson(id);
    }
  }

  /// Get course categories
  Future<List<Map<String, dynamic>>> getCourseCategories({
    int page = 1,
    int perPage = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'course_categories_${page}_${perPage}';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch categories from Tutor LMS API
          final categories = await _tutorLmsService.getCourseCategories(
            page: page,
            perPage: perPage,
          );

          // Save categories locally for offline use
          await _saveCategoriesLocally(categories);

          return categories;
        },
      );

      // Return categories
      if (data is List) {
        return data
            .map((category) => category as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching course categories: $e');

      // Fallback to local data in case of error
      return await _getLocalCategories();
    }
  }

  /// Save courses locally for offline use
  Future<void> _saveCoursesLocally(List<CourseModel> courses) async {
    try {
      final box = await Hive.openBox<Map>(_coursesBoxName);

      // Save each course
      for (final course in courses) {
        await box.put(course.id, {
          'id': course.id,
          'title': course.title,
          'description': course.description,
          'image': course.image,
          'price': course.price,
          'isFree': course.isFree,
          'duration': course.duration,
          'level': course.level,
          'category': course.category,
          'categoryId': course.categoryId,
          'instructor': {
            'id': course.instructor.id,
            'name': course.instructor.name,
            'avatar': course.instructor.avatar,
          },
          'totalLessons': course.totalLessons,
          'totalStudents': course.totalStudents,
          'rating': course.rating,
          'ratingCount': course.ratingCount,
          'createdAt': course.createdAt.toIso8601String(),
          'updatedAt': course.updatedAt.toIso8601String(),
        });
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving courses locally: $e');
    }
  }

  /// Save a single course locally for offline use
  Future<void> _saveCourseLocally(CourseModel course) async {
    try {
      final box = await Hive.openBox<Map>(_coursesBoxName);

      // Save the course
      await box.put(course.id, {
        'id': course.id,
        'title': course.title,
        'description': course.description,
        'image': course.image,
        'price': course.price,
        'isFree': course.isFree,
        'duration': course.duration,
        'level': course.level,
        'category': course.category,
        'categoryId': course.categoryId,
        'instructor': {
          'id': course.instructor.id,
          'name': course.instructor.name,
          'avatar': course.instructor.avatar,
        },
        'lessons':
            course.lessons
                .map(
                  (lesson) => {
                    'id': lesson.id,
                    'title': lesson.title,
                    'type': lesson.type.index,
                    'videoUrl': lesson.videoUrl,
                    'documentUrl': lesson.documentUrl,
                    'duration': lesson.duration,
                    'isPreviewable': lesson.isPreviewable,
                    'order': lesson.order,
                    'courseId': lesson.courseId,
                  },
                )
                .toList(),
        'totalLessons': course.totalLessons,
        'totalStudents': course.totalStudents,
        'rating': course.rating,
        'ratingCount': course.ratingCount,
        'isEnrolled': course.isEnrolled,
        'progress': course.progress,
        'createdAt': course.createdAt.toIso8601String(),
        'updatedAt': course.updatedAt.toIso8601String(),
      });

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving course locally: $e');
    }
  }

  /// Save lessons locally for offline use
  Future<void> _saveLessonsLocally(List<LessonModel> lessons) async {
    try {
      final box = await Hive.openBox<Map>(_lessonsBoxName);

      // Save each lesson
      for (final lesson in lessons) {
        await box.put(lesson.id, {
          'id': lesson.id,
          'title': lesson.title,
          'content': lesson.content,
          'summary': lesson.summary,
          'type': lesson.type.index,
          'videoUrl': lesson.videoUrl,
          'documentUrl': lesson.documentUrl,
          'thumbnailUrl': lesson.thumbnailUrl,
          'duration': lesson.duration,
          'isCompleted': lesson.isCompleted,
          'isPreviewable': lesson.isPreviewable,
          'order': lesson.order,
          'courseId': lesson.courseId,
          'parentId': lesson.parentId,
        });
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving lessons locally: $e');
    }
  }

  /// Save a single lesson locally for offline use
  Future<void> _saveLessonLocally(LessonModel lesson) async {
    try {
      final box = await Hive.openBox<Map>(_lessonsBoxName);

      // Save the lesson
      await box.put(lesson.id, {
        'id': lesson.id,
        'title': lesson.title,
        'content': lesson.content,
        'summary': lesson.summary,
        'type': lesson.type.index,
        'videoUrl': lesson.videoUrl,
        'documentUrl': lesson.documentUrl,
        'thumbnailUrl': lesson.thumbnailUrl,
        'duration': lesson.duration,
        'isCompleted': lesson.isCompleted,
        'isPreviewable': lesson.isPreviewable,
        'order': lesson.order,
        'courseId': lesson.courseId,
        'parentId': lesson.parentId,
      });

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving lesson locally: $e');
    }
  }

  /// Save categories locally for offline use
  Future<void> _saveCategoriesLocally(List<dynamic> categories) async {
    try {
      final box = await Hive.openBox<Map>(_categoriesBoxName);

      // Save each category
      for (final category in categories) {
        await box.put(category['id'].toString(), {
          'id': category['id'].toString(),
          'name': category['name'] ?? '',
          'slug': category['slug'] ?? '',
          'count': category['count'] ?? 0,
          'parent': category['parent'] ?? 0,
        });
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving categories locally: $e');
    }
  }

  /// Get courses from local storage
  Future<List<CourseModel>> _getLocalCourses() async {
    try {
      final box = await Hive.openBox<Map>(_coursesBoxName);

      // Get all courses
      final courses =
          box.values.map((courseMap) {
            return CourseModel(
              id: courseMap['id'] as String,
              title: courseMap['title'] as String,
              description: courseMap['description'] as String,
              image: courseMap['image'] as String,
              price: courseMap['price'] as String,
              isFree: courseMap['isFree'] as bool,
              duration: courseMap['duration'] as String,
              level: courseMap['level'] as String,
              category: courseMap['category'] as String,
              categoryId: courseMap['categoryId'] as String,
              instructor: InstructorModel(
                id: (courseMap['instructor'] as Map)['id'] as String,
                name: (courseMap['instructor'] as Map)['name'] as String,
                avatar: (courseMap['instructor'] as Map)['avatar'] as String,
              ),
              totalLessons: courseMap['totalLessons'] as int,
              totalStudents: courseMap['totalStudents'] as int,
              rating: (courseMap['rating'] as num).toDouble(),
              ratingCount: courseMap['ratingCount'] as int,
              createdAt: DateTime.parse(courseMap['createdAt'] as String),
              updatedAt: DateTime.parse(courseMap['updatedAt'] as String),
            );
          }).toList();

      await box.close();
      return courses;
    } catch (e) {
      debugPrint('❌ Error getting courses from local storage: $e');
      return [];
    }
  }

  /// Get a specific course from local storage
  Future<CourseModel?> _getLocalCourse(String id) async {
    try {
      final box = await Hive.openBox<Map>(_coursesBoxName);

      // Get the course
      final courseMap = box.get(id);

      await box.close();

      if (courseMap == null) {
        return null;
      }

      // Convert lessons if available
      List<LessonModel> lessons = [];
      if (courseMap['lessons'] != null) {
        lessons =
            (courseMap['lessons'] as List).map((lessonMap) {
              return LessonModel(
                id: lessonMap['id'] as String,
                title: lessonMap['title'] as String,
                type: LessonType.values[lessonMap['type'] as int],
                videoUrl: lessonMap['videoUrl'] as String,
                documentUrl: lessonMap['documentUrl'] as String,
                duration: lessonMap['duration'] as int,
                isPreviewable: lessonMap['isPreviewable'] as bool,
                order: lessonMap['order'] as int,
                courseId: lessonMap['courseId'] as String,
              );
            }).toList();
      }

      return CourseModel(
        id: courseMap['id'] as String,
        title: courseMap['title'] as String,
        description: courseMap['description'] as String,
        image: courseMap['image'] as String,
        price: courseMap['price'] as String,
        isFree: courseMap['isFree'] as bool,
        duration: courseMap['duration'] as String,
        level: courseMap['level'] as String,
        category: courseMap['category'] as String,
        categoryId: courseMap['categoryId'] as String,
        instructor: InstructorModel(
          id: (courseMap['instructor'] as Map)['id'] as String,
          name: (courseMap['instructor'] as Map)['name'] as String,
          avatar: (courseMap['instructor'] as Map)['avatar'] as String,
        ),
        lessons: lessons,
        totalLessons: courseMap['totalLessons'] as int,
        totalStudents: courseMap['totalStudents'] as int,
        rating: (courseMap['rating'] as num).toDouble(),
        ratingCount: courseMap['ratingCount'] as int,
        isEnrolled: courseMap['isEnrolled'] as bool? ?? false,
        progress: courseMap['progress'] as int? ?? 0,
        createdAt: DateTime.parse(courseMap['createdAt'] as String),
        updatedAt: DateTime.parse(courseMap['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('❌ Error getting course from local storage: $e');
      return null;
    }
  }

  /// Get lessons for a specific course from local storage
  Future<List<LessonModel>> _getLocalLessons(String courseId) async {
    try {
      final box = await Hive.openBox<Map>(_lessonsBoxName);

      // Get lessons for the specified course
      final lessons =
          box.values
              .where((lessonMap) => lessonMap['courseId'] == courseId)
              .map((lessonMap) {
                return LessonModel(
                  id: lessonMap['id'] as String,
                  title: lessonMap['title'] as String,
                  content: lessonMap['content'] as String,
                  summary: lessonMap['summary'] as String,
                  type: LessonType.values[lessonMap['type'] as int],
                  videoUrl: lessonMap['videoUrl'] as String,
                  documentUrl: lessonMap['documentUrl'] as String,
                  thumbnailUrl: lessonMap['thumbnailUrl'] as String,
                  duration: lessonMap['duration'] as int,
                  isCompleted: lessonMap['isCompleted'] as bool,
                  isPreviewable: lessonMap['isPreviewable'] as bool,
                  order: lessonMap['order'] as int,
                  courseId: lessonMap['courseId'] as String,
                  parentId: lessonMap['parentId'] as String,
                );
              })
              .toList();

      await box.close();

      // Sort lessons by order
      lessons.sort((a, b) => a.order.compareTo(b.order));

      return lessons;
    } catch (e) {
      debugPrint('❌ Error getting lessons from local storage: $e');
      return [];
    }
  }

  /// Get a specific lesson from local storage
  Future<LessonModel?> _getLocalLesson(String id) async {
    try {
      final box = await Hive.openBox<Map>(_lessonsBoxName);

      // Get the lesson
      final lessonMap = box.get(id);

      await box.close();

      if (lessonMap == null) {
        return null;
      }

      return LessonModel(
        id: lessonMap['id'] as String,
        title: lessonMap['title'] as String,
        content: lessonMap['content'] as String,
        summary: lessonMap['summary'] as String,
        type: LessonType.values[lessonMap['type'] as int],
        videoUrl: lessonMap['videoUrl'] as String,
        documentUrl: lessonMap['documentUrl'] as String,
        thumbnailUrl: lessonMap['thumbnailUrl'] as String,
        duration: lessonMap['duration'] as int,
        isCompleted: lessonMap['isCompleted'] as bool,
        isPreviewable: lessonMap['isPreviewable'] as bool,
        order: lessonMap['order'] as int,
        courseId: lessonMap['courseId'] as String,
        parentId: lessonMap['parentId'] as String,
      );
    } catch (e) {
      debugPrint('❌ Error getting lesson from local storage: $e');
      return null;
    }
  }

  /// Get categories from local storage
  Future<List<Map<String, dynamic>>> _getLocalCategories() async {
    try {
      final box = await Hive.openBox<Map>(_categoriesBoxName);

      // Get all categories
      final categories =
          box.values
              .map(
                (categoryMap) => {
                  'id': categoryMap['id'],
                  'name': categoryMap['name'],
                  'slug': categoryMap['slug'],
                  'count': categoryMap['count'],
                  'parent': categoryMap['parent'],
                },
              )
              .toList();

      await box.close();
      return categories;
    } catch (e) {
      debugPrint('❌ Error getting categories from local storage: $e');
      return [];
    }
  }

  /// Enroll in a course
  Future<bool> enrollCourse(String courseId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot enroll in offline mode
        return false;
      }

      // Enroll in the course
      await _tutorLmsService.enrollCourse(courseId);

      // Update local course data
      final course = await getCourseById(courseId, forceRefresh: true);

      return course?.isEnrolled ?? false;
    } catch (e) {
      debugPrint('❌ Error enrolling in course: $e');
      return false;
    }
  }

  /// Complete a lesson
  Future<bool> completeLesson(String lessonId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot complete lesson in offline mode
        return false;
      }

      // Complete the lesson
      await _tutorLmsService.completeLesson(lessonId);

      // Update local lesson data
      final lesson = await getLessonById(lessonId, forceRefresh: true);

      return lesson?.isCompleted ?? false;
    } catch (e) {
      debugPrint('❌ Error completing lesson: $e');
      return false;
    }
  }

  /// Submit a course review
  Future<ReviewModel?> submitCourseReview(
    String courseId,
    int rating,
    String review,
  ) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot submit review in offline mode
        return null;
      }

      // Submit the review
      final response = await _tutorLmsService.submitCourseReview(
        courseId,
        rating,
        review,
      );

      // Convert to ReviewModel
      final reviewModel = ReviewModel.fromJson({
        'id': response['id'].toString(),
        'course_id': courseId,
        'user_id': response['user_id'] ?? '0',
        'user_name': response['user_name'] ?? 'Anonymous',
        'user_avatar': response['user_avatar'],
        'rating': rating.toDouble(),
        'content': review,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_approved': true,
      });

      // Save review locally
      await _saveReviewLocally(reviewModel);

      // Clear cache for course reviews
      await _cacheService.clearCacheKey('course_${courseId}_reviews');

      // Update local course data
      await getCourseById(courseId, forceRefresh: true);

      return reviewModel;
    } catch (e) {
      debugPrint('❌ Error submitting course review: $e');
      return null;
    }
  }

  /// Get reviews for a specific course
  Future<List<ReviewModel>> getCourseReviews(
    String courseId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'course_${courseId}_reviews';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch reviews from Tutor LMS API
          final reviews = await _tutorLmsService.getCourseReviews(courseId);

          // Save reviews locally for offline use
          final reviewModels =
              reviews
                  .map(
                    (review) => ReviewModel.fromJson({
                      'id': review['id'].toString(),
                      'course_id': courseId,
                      'user_id': review['user_id'] ?? '0',
                      'user_name': review['user_name'] ?? 'Anonymous',
                      'user_avatar': review['user_avatar'],
                      'rating':
                          (review['rating'] is int)
                              ? (review['rating'] as int).toDouble()
                              : review['rating'] as double,
                      'content': review['content'] ?? '',
                      'created_at':
                          review['created_at'] ??
                          DateTime.now().toIso8601String(),
                      'updated_at':
                          review['updated_at'] ??
                          DateTime.now().toIso8601String(),
                      'is_approved': review['is_approved'] ?? true,
                    }),
                  )
                  .toList();

          await _saveReviewsLocally(reviewModels);

          return reviews;
        },
      );

      // Convert to ReviewModel list
      if (data is List) {
        return data
            .map(
              (review) => ReviewModel.fromJson({
                'id': review['id'].toString(),
                'course_id': courseId,
                'user_id': review['user_id'] ?? '0',
                'user_name': review['user_name'] ?? 'Anonymous',
                'user_avatar': review['user_avatar'],
                'rating':
                    (review['rating'] is int)
                        ? (review['rating'] as int).toDouble()
                        : review['rating'] as double,
                'content': review['content'] ?? '',
                'created_at':
                    review['created_at'] ?? DateTime.now().toIso8601String(),
                'updated_at':
                    review['updated_at'] ?? DateTime.now().toIso8601String(),
                'is_approved': review['is_approved'] ?? true,
              }),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error getting course reviews: $e');

      // Try to get reviews from local storage
      return await _getReviewsFromLocalStorage(courseId);
    }
  }

  /// Update a review
  Future<ReviewModel?> updateReview({
    required String reviewId,
    required int rating,
    required String content,
  }) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot update review in offline mode
        return null;
      }

      // Get the existing review to get the course ID
      final existingReview = await _getReviewFromLocalStorage(reviewId);
      if (existingReview == null) {
        return null;
      }

      // Update review in Tutor LMS API
      final response = await _tutorLmsService.updateReview(
        reviewId,
        rating,
        content,
      );

      // Convert to ReviewModel
      final reviewModel = existingReview.copyWith(
        rating: rating.toDouble(),
        content: content,
        updatedAt: DateTime.now(),
      );

      // Save review locally
      await _saveReviewLocally(reviewModel);

      // Clear cache for course reviews
      await _cacheService.clearCacheKey(
        'course_${reviewModel.courseId}_reviews',
      );

      return reviewModel;
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      return null;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot delete review in offline mode
        return false;
      }

      // Get the review first to know the course ID
      final review = await _getReviewFromLocalStorage(reviewId);

      // Delete review from Tutor LMS API
      await _tutorLmsService.deleteReview(reviewId);

      // Delete review locally
      await _deleteReviewLocally(reviewId);

      // Clear cache for course reviews if we have the course ID
      if (review != null) {
        await _cacheService.clearCacheKey('course_${review.courseId}_reviews');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      return false;
    }
  }

  /// Save reviews locally for offline use
  Future<void> _saveReviewsLocally(List<ReviewModel> reviews) async {
    try {
      final box = await Hive.openBox<Map>(_reviewsBoxName);

      for (final review in reviews) {
        await box.put(review.id, review.toJson());
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving reviews locally: $e');
    }
  }

  /// Save a single review locally
  Future<void> _saveReviewLocally(ReviewModel review) async {
    try {
      final box = await Hive.openBox<Map>(_reviewsBoxName);
      await box.put(review.id, review.toJson());
      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving review locally: $e');
    }
  }

  /// Get reviews for a course from local storage
  Future<List<ReviewModel>> _getReviewsFromLocalStorage(String courseId) async {
    try {
      final box = await Hive.openBox<Map>(_reviewsBoxName);

      final reviews =
          box.values
              .where((review) => review['course_id'] == courseId)
              .map(
                (review) =>
                    ReviewModel.fromJson(Map<String, dynamic>.from(review)),
              )
              .toList();

      await box.close();
      return reviews;
    } catch (e) {
      debugPrint('❌ Error getting reviews from local storage: $e');
      return [];
    }
  }

  /// Get a specific review from local storage
  Future<ReviewModel?> _getReviewFromLocalStorage(String reviewId) async {
    try {
      final box = await Hive.openBox<Map>(_reviewsBoxName);

      final reviewData = box.get(reviewId);
      await box.close();

      if (reviewData != null) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(reviewData));
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting review from local storage: $e');
      return null;
    }
  }

  /// Delete a review from local storage
  Future<void> _deleteReviewLocally(String reviewId) async {
    try {
      final box = await Hive.openBox<Map>(_reviewsBoxName);
      await box.delete(reviewId);
      await box.close();
    } catch (e) {
      debugPrint('❌ Error deleting review locally: $e');
    }
  }

  /// Get comments for a specific lesson
  Future<List<CommentModel>> getLessonComments(
    String lessonId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Create a cache key
      final cacheKey = 'lesson_${lessonId}_comments';

      // Use cache service to get or fetch data
      final data = await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch comments from Tutor LMS API
          final comments = await _tutorLmsService.getLessonComments(lessonId);

          // Convert to CommentModel list
          final commentModels = _parseCommentsFromApi(comments, lessonId);

          // Save comments locally for offline use
          await _saveCommentsLocally(commentModels);

          return comments;
        },
      );

      // Convert to CommentModel list
      if (data is List) {
        return _parseCommentsFromApi(data, lessonId);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error getting lesson comments: $e');

      // Try to get comments from local storage
      return await _getCommentsFromLocalStorage(lessonId);
    }
  }

  /// Parse comments from API response
  List<CommentModel> _parseCommentsFromApi(
    List<dynamic> data,
    String lessonId,
  ) {
    // First, create a map of all comments by ID
    final Map<String, CommentModel> commentsMap = {};

    // Create CommentModel objects for all comments
    for (final comment in data) {
      final commentModel = CommentModel(
        id: comment['id'].toString(),
        lessonId: lessonId,
        courseId: comment['course_id']?.toString() ?? '',
        userId: comment['user_id']?.toString() ?? '',
        userName: comment['user_name'] ?? 'Anonymous',
        userAvatar: comment['user_avatar'],
        content: comment['content'] ?? '',
        createdAt:
            comment['created_at'] != null
                ? DateTime.parse(comment['created_at'])
                : DateTime.now(),
        updatedAt:
            comment['updated_at'] != null
                ? DateTime.parse(comment['updated_at'])
                : DateTime.now(),
        isApproved: comment['is_approved'] ?? true,
        parentId: comment['parent_id']?.toString(),
        replies: [],
      );

      commentsMap[commentModel.id] = commentModel;
    }

    // Now, organize comments into a tree structure
    final List<CommentModel> rootComments = [];

    // Add replies to their parent comments
    commentsMap.forEach((id, comment) {
      if (comment.parentId == null || comment.parentId!.isEmpty) {
        // This is a root comment
        rootComments.add(comment);
      } else {
        // This is a reply
        final parentComment = commentsMap[comment.parentId];
        if (parentComment != null) {
          // Add this comment as a reply to its parent
          final updatedReplies = List<CommentModel>.from(parentComment.replies)
            ..add(comment);

          // Update the parent comment with the new replies list
          commentsMap[comment.parentId!] = parentComment.copyWith(
            replies: updatedReplies,
          );
        } else {
          // Parent comment not found, treat as root comment
          rootComments.add(comment);
        }
      }
    });

    return rootComments;
  }

  /// Add a comment to a lesson
  Future<CommentModel?> addLessonComment({
    required String lessonId,
    required String courseId,
    required String content,
    String? parentId,
  }) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot add comment in offline mode
        return null;
      }

      // Add the comment
      final response = await _tutorLmsService.addLessonComment(
        lessonId,
        courseId,
        content,
        parentId: parentId,
      );

      // Convert to CommentModel
      final commentModel = CommentModel(
        id: response['id'].toString(),
        lessonId: lessonId,
        courseId: courseId,
        userId: response['user_id']?.toString() ?? '',
        userName: response['user_name'] ?? 'Anonymous',
        userAvatar: response['user_avatar'],
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
        parentId: parentId,
        replies: [],
      );

      // Save comment locally
      await _saveCommentLocally(commentModel);

      // Clear cache for lesson comments
      await _cacheService.clearCacheKey('lesson_${lessonId}_comments');

      return commentModel;
    } catch (e) {
      debugPrint('❌ Error adding lesson comment: $e');
      return null;
    }
  }

  /// Update a comment
  Future<CommentModel?> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot update comment in offline mode
        return null;
      }

      // Get the existing comment to get the lesson ID
      final existingComment = await _getCommentFromLocalStorage(commentId);
      if (existingComment == null) {
        return null;
      }

      // Update comment in Tutor LMS API
      await _tutorLmsService.updateComment(commentId, content);

      // Convert to CommentModel
      final commentModel = existingComment.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );

      // Save comment locally
      await _saveCommentLocally(commentModel);

      // Clear cache for lesson comments
      await _cacheService.clearCacheKey(
        'lesson_${commentModel.lessonId}_comments',
      );

      return commentModel;
    } catch (e) {
      debugPrint('❌ Error updating comment: $e');
      return null;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Cannot delete comment in offline mode
        return false;
      }

      // Get the comment first to know the lesson ID
      final comment = await _getCommentFromLocalStorage(commentId);

      // Delete comment from Tutor LMS API
      await _tutorLmsService.deleteComment(commentId);

      // Delete comment locally
      await _deleteCommentLocally(commentId);

      // Clear cache for lesson comments if we have the lesson ID
      if (comment != null) {
        await _cacheService.clearCacheKey(
          'lesson_${comment.lessonId}_comments',
        );
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      return false;
    }
  }

  /// Save comments locally for offline use
  Future<void> _saveCommentsLocally(List<CommentModel> comments) async {
    try {
      final box = await Hive.openBox<Map>(_commentsBoxName);

      for (final comment in comments) {
        await box.put(comment.id, comment.toJson());

        // Also save replies
        for (final reply in comment.replies) {
          await box.put(reply.id, reply.toJson());
        }
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving comments locally: $e');
    }
  }

  /// Save a single comment locally
  Future<void> _saveCommentLocally(CommentModel comment) async {
    try {
      final box = await Hive.openBox<Map>(_commentsBoxName);
      await box.put(comment.id, comment.toJson());
      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving comment locally: $e');
    }
  }

  /// Get comments for a lesson from local storage
  Future<List<CommentModel>> _getCommentsFromLocalStorage(
    String lessonId,
  ) async {
    try {
      final box = await Hive.openBox<Map>(_commentsBoxName);

      // Get all comments for this lesson
      final allComments =
          box.values
              .where((comment) => comment['lesson_id'] == lessonId)
              .map(
                (comment) =>
                    CommentModel.fromJson(Map<String, dynamic>.from(comment)),
              )
              .toList();

      await box.close();

      // Organize comments into a tree structure
      final Map<String, CommentModel> commentsMap = {};
      for (final comment in allComments) {
        commentsMap[comment.id] = comment;
      }

      final List<CommentModel> rootComments = [];

      // Add replies to their parent comments
      commentsMap.forEach((id, comment) {
        if (comment.parentId == null || comment.parentId!.isEmpty) {
          // This is a root comment
          rootComments.add(comment);
        } else {
          // This is a reply
          final parentComment = commentsMap[comment.parentId];
          if (parentComment != null) {
            // Add this comment as a reply to its parent
            final updatedReplies = List<CommentModel>.from(
              parentComment.replies,
            )..add(comment);

            // Update the parent comment with the new replies list
            commentsMap[comment.parentId!] = parentComment.copyWith(
              replies: updatedReplies,
            );
          } else {
            // Parent comment not found, treat as root comment
            rootComments.add(comment);
          }
        }
      });

      return rootComments;
    } catch (e) {
      debugPrint('❌ Error getting comments from local storage: $e');
      return [];
    }
  }

  /// Get a specific comment from local storage
  Future<CommentModel?> _getCommentFromLocalStorage(String commentId) async {
    try {
      final box = await Hive.openBox<Map>(_commentsBoxName);

      final commentData = box.get(commentId);
      await box.close();

      if (commentData != null) {
        return CommentModel.fromJson(Map<String, dynamic>.from(commentData));
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting comment from local storage: $e');
      return null;
    }
  }

  /// Delete a comment from local storage
  Future<void> _deleteCommentLocally(String commentId) async {
    try {
      final box = await Hive.openBox<Map>(_commentsBoxName);
      await box.delete(commentId);
      await box.close();
    } catch (e) {
      debugPrint('❌ Error deleting comment locally: $e');
    }
  }
}
