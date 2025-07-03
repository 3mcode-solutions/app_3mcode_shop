import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';
import 'package:app_3mcode_shop/data/repositories/course_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course_state.dart';
import 'package:share_plus/share_plus.dart';

/// BLoC for managing course state
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc({required CourseRepository courseRepository})
    : _courseRepository = courseRepository,
      super(const CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCourseById>(_onLoadCourseById);
    on<LoadCourseLessons>(_onLoadCourseLessons);
    on<LoadLessonById>(_onLoadLessonById);
    on<LoadCourseCategories>(_onLoadCourseCategories);
    on<EnrollCourse>(_onEnrollCourse);
    on<CompleteLesson>(_onCompleteLesson);
    on<SubmitCourseReview>(_onSubmitCourseReview);
    on<LoadCourseReviews>(_onLoadCourseReviews);
    on<UpdateReview>(_onUpdateReview);
    on<DeleteReview>(_onDeleteReview);
    on<LoadLessonComments>(_onLoadLessonComments);
    on<AddLessonComment>(_onAddLessonComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<ShareCourse>(_onShareCourse);
  }

  /// Handle LoadCourses event
  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // If we're loading the first page or forcing a refresh, emit loading state
      if (event.page == 1 || event.forceRefresh) {
        emit(const CourseLoading());
      }

      // If we're loading more pages, get the current state
      final currentState = state;
      if (currentState is CoursesLoaded && event.page > 1) {
        // Load more courses
        final newCourses = await _courseRepository.getCourses(
          page: event.page,
          perPage: event.perPage,
          search: event.search,
          category: event.category,
          instructor: event.instructor,
          orderBy: event.orderBy,
          order: event.order,
          forceRefresh: event.forceRefresh,
        );

        // If no new courses, we've reached the max
        if (newCourses.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
          return;
        }

        // Combine existing and new courses
        final allCourses = [...currentState.courses, ...newCourses];

        emit(
          currentState.copyWith(
            courses: allCourses,
            page: event.page,
            hasReachedMax: newCourses.length < event.perPage,
          ),
        );
      } else {
        // Load first page of courses
        final courses = await _courseRepository.getCourses(
          page: event.page,
          perPage: event.perPage,
          search: event.search,
          category: event.category,
          instructor: event.instructor,
          orderBy: event.orderBy,
          order: event.order,
          forceRefresh: event.forceRefresh,
        );

        emit(
          CoursesLoaded(
            courses: courses,
            page: event.page,
            perPage: event.perPage,
            hasReachedMax: courses.length < event.perPage,
            search: event.search,
            category: event.category,
            instructor: event.instructor,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading courses: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadCourseById event
  Future<void> _onLoadCourseById(
    LoadCourseById event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // طباعة تصحيح لمعرفة معرف الكورس المطلوب
      debugPrint('🔍 CourseBloc: Loading course details for ID: ${event.id}');
      debugPrint('🔍 CourseBloc: Force refresh: ${event.forceRefresh}');

      // Load the course
      final course = await _courseRepository.getCourseById(
        event.id,
        forceRefresh: event.forceRefresh,
      );

      if (course == null) {
        debugPrint('⚠️ CourseBloc: Course not found for ID: ${event.id}');
        emit(const CourseError('Course not found'));
        return;
      }

      // طباعة تصحيح لمعرفة تفاصيل الكورس
      debugPrint('✅ CourseBloc: Course loaded successfully:');
      debugPrint('✅ CourseBloc: ID: ${course.id}');
      debugPrint('✅ CourseBloc: Title: ${course.title}');
      debugPrint('✅ CourseBloc: Is enrolled: ${course.isEnrolled}');

      // Load lessons for the course
      final lessons = await _courseRepository.getCourseLessons(
        event.id,
        forceRefresh: event.forceRefresh,
      );

      // طباعة تصحيح لمعرفة عدد الدروس
      debugPrint('✅ CourseBloc: Lessons loaded: ${lessons.length}');

      // طباعة تصحيح لمعرفة تفاصيل الدروس
      if (lessons.isNotEmpty) {
        debugPrint('✅ CourseBloc: First lesson: ${lessons[0].title}');
        debugPrint(
          '✅ CourseBloc: Last lesson: ${lessons[lessons.length - 1].title}',
        );
      }

      emit(CourseLoaded(course: course, lessons: lessons));
    } catch (e) {
      debugPrint('❌ Error loading course: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadCourseLessons event
  Future<void> _onLoadCourseLessons(
    LoadCourseLessons event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // Load lessons for the course
      final lessons = await _courseRepository.getCourseLessons(
        event.courseId,
        forceRefresh: event.forceRefresh,
      );

      emit(CourseLessonsLoaded(courseId: event.courseId, lessons: lessons));
    } catch (e) {
      debugPrint('❌ Error loading course lessons: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadLessonById event
  Future<void> _onLoadLessonById(
    LoadLessonById event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // Load the lesson
      final lesson = await _courseRepository.getLessonById(
        event.id,
        forceRefresh: event.forceRefresh,
      );

      if (lesson == null) {
        emit(const CourseError('Lesson not found'));
        return;
      }

      emit(LessonLoaded(lesson: lesson));
    } catch (e) {
      debugPrint('❌ Error loading lesson: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadCourseCategories event
  Future<void> _onLoadCourseCategories(
    LoadCourseCategories event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // Load course categories
      final categories = await _courseRepository.getCourseCategories(
        page: event.page,
        perPage: event.perPage,
        forceRefresh: event.forceRefresh,
      );

      emit(CourseCategoriesLoaded(categories: categories));
    } catch (e) {
      debugPrint('❌ Error loading course categories: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle EnrollCourse event
  Future<void> _onEnrollCourse(
    EnrollCourse event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Enroll in the course
      final success = await _courseRepository.enrollCourse(event.courseId);

      emit(
        CourseEnrollmentComplete(courseId: event.courseId, success: success),
      );

      // Reload the course to get updated enrollment status
      add(LoadCourseById(event.courseId, forceRefresh: true));
    } catch (e) {
      debugPrint('❌ Error enrolling in course: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle CompleteLesson event
  Future<void> _onCompleteLesson(
    CompleteLesson event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Complete the lesson
      final success = await _courseRepository.completeLesson(event.lessonId);

      if (success) {
        emit(LessonCompleteSuccess(lessonId: event.lessonId));
      } else {
        emit(const CourseError('Failed to complete lesson'));
      }

      // If we have a loaded course, reload it to update progress
      if (state is CourseLoaded) {
        final courseState = state as CourseLoaded;
        add(LoadCourseById(courseState.course.id, forceRefresh: true));
      }
    } catch (e) {
      debugPrint('❌ Error completing lesson: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle SubmitCourseReview event
  Future<void> _onSubmitCourseReview(
    SubmitCourseReview event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Submit the review
      final review = await _courseRepository.submitCourseReview(
        event.courseId,
        event.rating,
        event.review,
      );

      emit(
        CourseReviewSubmitted(
          courseId: event.courseId,
          success: review != null,
          review: review,
        ),
      );

      // Reload the course to get updated reviews
      add(LoadCourseById(event.courseId, forceRefresh: true));
    } catch (e) {
      debugPrint('❌ Error submitting course review: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadCourseReviews event
  Future<void> _onLoadCourseReviews(
    LoadCourseReviews event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // Load reviews for the course
      final reviews = await _courseRepository.getCourseReviews(
        event.courseId,
        forceRefresh: event.forceRefresh,
      );

      emit(CourseReviewsLoaded(courseId: event.courseId, reviews: reviews));
    } catch (e) {
      debugPrint('❌ Error loading course reviews: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle UpdateReview event
  Future<void> _onUpdateReview(
    UpdateReview event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Update the review
      final review = await _courseRepository.updateReview(
        reviewId: event.reviewId,
        rating: event.rating,
        content: event.content,
      );

      if (review != null) {
        emit(ReviewUpdated(review: review, success: true));

        // Reload reviews for the course
        add(LoadCourseReviews(review.courseId, forceRefresh: true));
      } else {
        emit(
          ReviewUpdated(
            review: ReviewModel(
              id: event.reviewId,
              courseId: '',
              userId: '',
              userName: '',
              rating: event.rating.toDouble(),
              content: event.content,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            success: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle DeleteReview event
  Future<void> _onDeleteReview(
    DeleteReview event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Delete the review
      final success = await _courseRepository.deleteReview(event.reviewId);

      emit(ReviewDeleted(reviewId: event.reviewId, success: success));

      // If we're in a course loaded state, reload reviews for the course
      if (state is CourseLoaded) {
        final courseState = state as CourseLoaded;
        add(LoadCourseReviews(courseState.course.id, forceRefresh: true));
      }
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle LoadLessonComments event
  Future<void> _onLoadLessonComments(
    LoadLessonComments event,
    Emitter<CourseState> emit,
  ) async {
    try {
      emit(const CourseLoading());

      // Load comments for the lesson
      final comments = await _courseRepository.getLessonComments(
        event.lessonId,
        forceRefresh: event.forceRefresh,
      );

      emit(LessonCommentsLoaded(lessonId: event.lessonId, comments: comments));
    } catch (e) {
      debugPrint('❌ Error loading lesson comments: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle AddLessonComment event
  Future<void> _onAddLessonComment(
    AddLessonComment event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Add the comment
      final comment = await _courseRepository.addLessonComment(
        lessonId: event.lessonId,
        courseId: event.courseId,
        content: event.content,
        parentId: event.parentId,
      );

      if (comment != null) {
        emit(CommentAdded(comment: comment, success: true));

        // Reload comments for the lesson
        add(LoadLessonComments(event.lessonId, forceRefresh: true));
      } else {
        emit(
          CommentAdded(
            comment: CommentModel(
              id: '0',
              lessonId: event.lessonId,
              courseId: event.courseId,
              userId: '',
              userName: '',
              content: event.content,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            success: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error adding lesson comment: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle UpdateComment event
  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Update the comment
      final comment = await _courseRepository.updateComment(
        commentId: event.commentId,
        content: event.content,
      );

      if (comment != null) {
        emit(CommentUpdated(comment: comment, success: true));

        // Reload comments for the lesson
        add(LoadLessonComments(comment.lessonId, forceRefresh: true));
      } else {
        emit(
          CommentUpdated(
            comment: CommentModel(
              id: event.commentId,
              lessonId: '',
              courseId: '',
              userId: '',
              userName: '',
              content: event.content,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            success: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating comment: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle DeleteComment event
  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Get the comment first to know the lesson ID
      // We'll try to get the comment from the current state
      CommentModel? comment;
      String? lessonId;

      // If we're in a LessonCommentsLoaded state, try to find the comment there
      if (state is LessonCommentsLoaded) {
        final commentsState = state as LessonCommentsLoaded;
        lessonId = commentsState.lessonId;

        // Search in root comments
        for (final rootComment in commentsState.comments) {
          if (rootComment.id == event.commentId) {
            comment = rootComment;
            break;
          }

          // Search in replies
          for (final reply in rootComment.replies) {
            if (reply.id == event.commentId) {
              comment = reply;
              break;
            }
          }

          if (comment != null) break;
        }
      }

      // Delete the comment
      final success = await _courseRepository.deleteComment(event.commentId);

      emit(CommentDeleted(commentId: event.commentId, success: success));

      // If we have the lesson ID, reload comments for the lesson
      if (lessonId != null) {
        add(LoadLessonComments(lessonId, forceRefresh: true));
      }
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      emit(CourseError(e.toString()));
    }
  }

  /// Handle ShareCourse event
  Future<void> _onShareCourse(
    ShareCourse event,
    Emitter<CourseState> emit,
  ) async {
    try {
      // Share the course using SharePlus
      final text =
          'Check out this course: ${event.courseTitle}\n${event.courseUrl}';
      await Share.share(text);

      debugPrint('✅ Course shared successfully: ${event.courseTitle}');
    } catch (e) {
      debugPrint('❌ Error sharing course: $e');
      emit(CourseError(e.toString()));
    }
  }
}
