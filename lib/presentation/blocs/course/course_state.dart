import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';

/// Base class for all course states
abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object> get props => [];
}

/// Initial state
class CourseInitial extends CourseState {
  const CourseInitial();
}

/// State when courses are being loaded
class CourseLoading extends CourseState {
  const CourseLoading();
}

/// State when courses have been loaded successfully
class CoursesLoaded extends CourseState {
  final List<CourseModel> courses;
  final int page;
  final int perPage;
  final bool hasReachedMax;
  final String? search;
  final String? category;
  final String? instructor;

  const CoursesLoaded({
    required this.courses,
    this.page = 1,
    this.perPage = 10,
    this.hasReachedMax = false,
    this.search,
    this.category,
    this.instructor,
  });

  @override
  List<Object> get props => [
    courses,
    page,
    perPage,
    hasReachedMax,
    if (search != null) search!,
    if (category != null) category!,
    if (instructor != null) instructor!,
  ];

  CoursesLoaded copyWith({
    List<CourseModel>? courses,
    int? page,
    int? perPage,
    bool? hasReachedMax,
    String? search,
    String? category,
    String? instructor,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
    );
  }
}

/// State when a specific course has been loaded successfully
class CourseLoaded extends CourseState {
  final CourseModel course;
  final List<LessonModel> lessons;

  const CourseLoaded({required this.course, this.lessons = const []});

  @override
  List<Object> get props => [course, lessons];

  CourseLoaded copyWith({CourseModel? course, List<LessonModel>? lessons}) {
    return CourseLoaded(
      course: course ?? this.course,
      lessons: lessons ?? this.lessons,
    );
  }
}

/// State when lessons for a course have been loaded successfully
class CourseLessonsLoaded extends CourseState {
  final String courseId;
  final List<LessonModel> lessons;

  const CourseLessonsLoaded({required this.courseId, required this.lessons});

  @override
  List<Object> get props => [courseId, lessons];
}

/// State when a specific lesson has been loaded successfully
class LessonLoaded extends CourseState {
  final LessonModel lesson;

  const LessonLoaded({required this.lesson});

  @override
  List<Object> get props => [lesson];
}

/// State when course categories have been loaded successfully
class CourseCategoriesLoaded extends CourseState {
  final List<Map<String, dynamic>> categories;

  const CourseCategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

/// State when a course enrollment has been completed
class CourseEnrollmentComplete extends CourseState {
  final String courseId;
  final bool success;

  const CourseEnrollmentComplete({
    required this.courseId,
    required this.success,
  });

  @override
  List<Object> get props => [courseId, success];
}

/// State when a lesson has been completed
class LessonCompleteSuccess extends CourseState {
  final String lessonId;

  const LessonCompleteSuccess({required this.lessonId});

  @override
  List<Object> get props => [lessonId];
}

/// State when a course review has been submitted
class CourseReviewSubmitted extends CourseState {
  final String courseId;
  final bool success;
  final ReviewModel? review;

  const CourseReviewSubmitted({
    required this.courseId,
    required this.success,
    this.review,
  });

  @override
  List<Object> get props => [courseId, success, if (review != null) review!];
}

/// State when course reviews have been loaded
class CourseReviewsLoaded extends CourseState {
  final String courseId;
  final List<ReviewModel> reviews;

  const CourseReviewsLoaded({required this.courseId, required this.reviews});

  @override
  List<Object> get props => [courseId, reviews];
}

/// State when a review has been updated
class ReviewUpdated extends CourseState {
  final ReviewModel review;
  final bool success;

  const ReviewUpdated({required this.review, required this.success});

  @override
  List<Object> get props => [review, success];
}

/// State when a review has been deleted
class ReviewDeleted extends CourseState {
  final String reviewId;
  final bool success;

  const ReviewDeleted({required this.reviewId, required this.success});

  @override
  List<Object> get props => [reviewId, success];
}

/// State when lesson comments have been loaded
class LessonCommentsLoaded extends CourseState {
  final String lessonId;
  final List<CommentModel> comments;

  const LessonCommentsLoaded({required this.lessonId, required this.comments});

  @override
  List<Object> get props => [lessonId, comments];
}

/// State when a comment has been added
class CommentAdded extends CourseState {
  final CommentModel comment;
  final bool success;

  const CommentAdded({required this.comment, required this.success});

  @override
  List<Object> get props => [comment, success];
}

/// State when a comment has been updated
class CommentUpdated extends CourseState {
  final CommentModel comment;
  final bool success;

  const CommentUpdated({required this.comment, required this.success});

  @override
  List<Object> get props => [comment, success];
}

/// State when a comment has been deleted
class CommentDeleted extends CourseState {
  final String commentId;
  final bool success;

  const CommentDeleted({required this.commentId, required this.success});

  @override
  List<Object> get props => [commentId, success];
}

/// State when an error occurs
class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object> get props => [message];
}
