import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';

/// Service class for interacting with the Tutor LMS API
class TutorLmsService {
  // Singleton pattern
  static final TutorLmsService _instance = TutorLmsService._internal();

  factory TutorLmsService() {
    return _instance;
  }

  TutorLmsService._internal();

  // Get API credentials from AppConfig
  String get _consumerKey => AppConfig.tutorLmsConsumerKey;
  String get _consumerSecret => AppConfig.tutorLmsConsumerSecret;

  // Base URL for the WordPress site
  String get _baseUrl => AppConstants.baseUrl;

  // WordPress REST API base path
  String get _wpApiPath => AppConfig.wpApiPath;

  // Tutor LMS API path
  String get _tutorApiPath => AppConfig.tutorApiPath;

  // WordPress API path
  String get _wpV2ApiPath => AppConfig.wpV2ApiPath;

  /// Make a GET request to the API
  Future<dynamic> get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    try {
      // Build the URL
      final uri = Uri.parse(
        '$_baseUrl$_wpApiPath$endpoint',
      ).replace(queryParameters: {...?queryParams});

      debugPrint('🔗 Making GET request to: $uri');

      // Make the request with Basic Authentication
      final response = await http.get(
        uri,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'))}',
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('📡 Response status: ${response.statusCode}');
        debugPrint('✅ Response data received successfully');

        // Parse the response body
        return json.decode(response.body);
      } else {
        debugPrint('❌ Request failed with status: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error making GET request: $e');
      rethrow;
    }
  }

  /// Make a POST request to the API
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      // Build the URL
      final uri = Uri.parse('$_baseUrl$_wpApiPath$endpoint');

      debugPrint('🔗 Making POST request to: $uri');

      // Make the request with Basic Authentication
      final response = await http.post(
        uri,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'))}',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      // Check if the request was successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('📡 Response status: ${response.statusCode}');
        debugPrint('✅ Response data received successfully');

        // Parse the response body
        return json.decode(response.body);
      } else {
        debugPrint('❌ Request failed with status: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
        throw Exception('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error making POST request: $e');
      rethrow;
    }
  }

  /// Get all courses
  Future<List<dynamic>> getCourses({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
    String? instructor,
    String? orderBy = 'date',
    String? order = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'orderby': orderBy ?? 'date',
      'order': order ?? 'desc',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    if (instructor != null && instructor.isNotEmpty) {
      queryParams['instructor'] = instructor;
    }

    final courses = await get('$_tutorApiPath/courses', queryParams);

    // طباعة تصحيح لفهم البيانات الواردة من API
    debugPrint('📚 Courses from API: ${courses.length}');
    if (courses.isNotEmpty) {
      debugPrint('📚 First course ID: ${courses[0]['id']}');
      debugPrint('📚 First course title: ${courses[0]['title']?['rendered']}');

      // طباعة معرفات جميع الكورسات للتحقق من التكرار
      final courseIds = courses.map((c) => c['id'].toString()).toList();
      debugPrint('📚 All course IDs: $courseIds');

      // التحقق من وجود تكرار في معرفات الكورسات
      final uniqueIds = courseIds.toSet().toList();
      if (uniqueIds.length != courseIds.length) {
        debugPrint('⚠️ WARNING: Duplicate course IDs detected!');
        debugPrint(
          '⚠️ Unique IDs count: ${uniqueIds.length}, Total IDs count: ${courseIds.length}',
        );
      }
    }

    return courses;
  }

  /// Get a specific course by ID
  Future<dynamic> getCourse(String id) async {
    return await get('$_tutorApiPath/courses/$id');
  }

  /// Get course categories
  Future<List<dynamic>> getCourseCategories({
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    return await get('$_wpV2ApiPath/course-categories', queryParams);
  }

  /// Get lessons for a specific course
  Future<List<dynamic>> getCourseLessons(String courseId) async {
    return await get('$_tutorApiPath/courses/$courseId/lessons');
  }

  /// Get a specific lesson by ID
  Future<dynamic> getLesson(String id) async {
    return await get('$_tutorApiPath/lessons/$id');
  }

  /// Get course instructors
  Future<List<dynamic>> getInstructors({int page = 1, int perPage = 20}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    return await get('$_tutorApiPath/instructors', queryParams);
  }

  /// Get a specific instructor by ID
  Future<dynamic> getInstructor(String id) async {
    return await get('$_tutorApiPath/instructors/$id');
  }

  /// Enroll in a course
  Future<dynamic> enrollCourse(String courseId) async {
    return await post('$_tutorApiPath/courses/$courseId/enroll', {});
  }

  /// Complete a lesson
  Future<dynamic> completeLesson(String lessonId) async {
    return await post('$_tutorApiPath/lessons/$lessonId/complete', {});
  }

  /// Submit a course review
  Future<dynamic> submitCourseReview(
    String courseId,
    int rating,
    String review,
  ) async {
    return await post('$_tutorApiPath/courses/$courseId/reviews', {
      'rating': rating,
      'review': review,
    });
  }

  /// Get reviews for a specific course
  Future<List<dynamic>> getCourseReviews(String courseId) async {
    return await get('$_tutorApiPath/courses/$courseId/reviews');
  }

  /// Get a specific review by ID
  Future<dynamic> getReview(String reviewId) async {
    return await get('$_tutorApiPath/reviews/$reviewId');
  }

  /// Update a review
  Future<dynamic> updateReview(
    String reviewId,
    int rating,
    String review,
  ) async {
    return await post('$_tutorApiPath/reviews/$reviewId', {
      'rating': rating,
      'review': review,
    });
  }

  /// Delete a review
  Future<dynamic> deleteReview(String reviewId) async {
    // Note: This would typically be a DELETE request, but we're using POST with a delete action
    return await post('$_tutorApiPath/reviews/$reviewId/delete', {});
  }

  /// Get comments for a specific lesson
  Future<List<dynamic>> getLessonComments(String lessonId) async {
    return await get('$_tutorApiPath/lessons/$lessonId/comments');
  }

  /// Add a comment to a lesson
  Future<dynamic> addLessonComment(
    String lessonId,
    String courseId,
    String content, {
    String? parentId,
  }) async {
    final data = {
      'lesson_id': lessonId,
      'course_id': courseId,
      'content': content,
    };

    if (parentId != null) {
      data['parent_id'] = parentId;
    }

    return await post('$_tutorApiPath/lessons/$lessonId/comments', data);
  }

  /// Update a comment
  Future<dynamic> updateComment(String commentId, String content) async {
    return await post('$_tutorApiPath/comments/$commentId', {
      'content': content,
    });
  }

  /// Delete a comment
  Future<dynamic> deleteComment(String commentId) async {
    // Note: This would typically be a DELETE request, but we're using POST with a delete action
    return await post('$_tutorApiPath/comments/$commentId/delete', {});
  }

  /// Verify API credentials by making a test request
  Future<bool> verifyApiCredentials() async {
    try {
      // Try to get a list of course categories to verify credentials
      // This endpoint is usually more accessible than the courses endpoint
      await get('$_wpV2ApiPath/course-categories', {'per_page': '1'});
      debugPrint('✅ API credentials verified successfully');
      return true;
    } catch (e) {
      debugPrint('❌ API credentials verification failed: $e');

      // Try another endpoint as a fallback
      try {
        await get('/wp/v2/users/me');
        debugPrint(
          '✅ API credentials verified successfully with users/me endpoint',
        );
        return true;
      } catch (e2) {
        debugPrint('❌ Secondary API credentials verification failed: $e2');
        return false;
      }
    }
  }
}
