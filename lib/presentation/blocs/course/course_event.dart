import 'package:equatable/equatable.dart';

/// Base class for all course events
abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all courses
class LoadCourses extends CourseEvent {
  final int page;
  final int perPage;
  final String? search;
  final String? category;
  final String? instructor;
  final String? orderBy;
  final String? order;
  final bool forceRefresh;

  const LoadCourses({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.category,
    this.instructor,
    this.orderBy,
    this.order,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [
    page,
    perPage,
    forceRefresh,
    if (search != null) search!,
    if (category != null) category!,
    if (instructor != null) instructor!,
    if (orderBy != null) orderBy!,
    if (order != null) order!,
  ];
}

/// Event to load a specific course by ID
class LoadCourseById extends CourseEvent {
  final String id;
  final bool forceRefresh;

  const LoadCourseById(this.id, {this.forceRefresh = false});

  @override
  List<Object> get props => [id, forceRefresh];
}

/// Event to load lessons for a specific course
class LoadCourseLessons extends CourseEvent {
  final String courseId;
  final bool forceRefresh;

  const LoadCourseLessons(this.courseId, {this.forceRefresh = false});

  @override
  List<Object> get props => [courseId, forceRefresh];
}

/// Event to load a specific lesson by ID
class LoadLessonById extends CourseEvent {
  final String id;
  final bool forceRefresh;

  const LoadLessonById(this.id, {this.forceRefresh = false});

  @override
  List<Object> get props => [id, forceRefresh];
}

/// Event to load course categories
class LoadCourseCategories extends CourseEvent {
  final int page;
  final int perPage;
  final bool forceRefresh;

  const LoadCourseCategories({
    this.page = 1,
    this.perPage = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [page, perPage, forceRefresh];
}

/// Event to enroll in a course
class EnrollCourse extends CourseEvent {
  final String courseId;

  const EnrollCourse(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// Event to complete a lesson
class CompleteLesson extends CourseEvent {
  final String lessonId;

  const CompleteLesson(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

/// Event to submit a course review
class SubmitCourseReview extends CourseEvent {
  final String courseId;
  final int rating;
  final String review;

  const SubmitCourseReview({
    required this.courseId,
    required this.rating,
    required this.review,
  });

  @override
  List<Object> get props => [courseId, rating, review];
}

/// Event to load reviews for a course
class LoadCourseReviews extends CourseEvent {
  final String courseId;
  final bool forceRefresh;

  const LoadCourseReviews(this.courseId, {this.forceRefresh = false});

  @override
  List<Object> get props => [courseId, forceRefresh];
}

/// Event to update a review
class UpdateReview extends CourseEvent {
  final String reviewId;
  final int rating;
  final String content;

  const UpdateReview({
    required this.reviewId,
    required this.rating,
    required this.content,
  });

  @override
  List<Object> get props => [reviewId, rating, content];
}

/// Event to delete a review
class DeleteReview extends CourseEvent {
  final String reviewId;

  const DeleteReview(this.reviewId);

  @override
  List<Object> get props => [reviewId];
}

/// Event to load comments for a lesson
class LoadLessonComments extends CourseEvent {
  final String lessonId;
  final bool forceRefresh;

  const LoadLessonComments(this.lessonId, {this.forceRefresh = false});

  @override
  List<Object> get props => [lessonId, forceRefresh];
}

/// Event to add a comment to a lesson
class AddLessonComment extends CourseEvent {
  final String lessonId;
  final String courseId;
  final String content;
  final String? parentId;

  const AddLessonComment({
    required this.lessonId,
    required this.courseId,
    required this.content,
    this.parentId,
  });

  @override
  List<Object> get props => [
    lessonId,
    courseId,
    content,
    if (parentId != null) parentId!,
  ];
}

/// Event to update a comment
class UpdateComment extends CourseEvent {
  final String commentId;
  final String content;

  const UpdateComment({required this.commentId, required this.content});

  @override
  List<Object> get props => [commentId, content];
}

/// Event to delete a comment
class DeleteComment extends CourseEvent {
  final String commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}

/// Event to add a course to favorites
class AddCourseToFavorites extends CourseEvent {
  final String courseId;

  const AddCourseToFavorites(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// Event to remove a course from favorites
class RemoveCourseFromFavorites extends CourseEvent {
  final String courseId;

  const RemoveCourseFromFavorites(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// Event to share a course
class ShareCourse extends CourseEvent {
  final String courseId;
  final String courseTitle;
  final String courseUrl;

  const ShareCourse({
    required this.courseId,
    required this.courseTitle,
    required this.courseUrl,
  });

  @override
  List<Object> get props => [courseId, courseTitle, courseUrl];
}
