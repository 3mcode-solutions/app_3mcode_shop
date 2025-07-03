import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:app_3mcode_shop/data/models/instructor_model.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';

/// A model class representing a course from Tutor LMS
class CourseModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String image;
  final String price;
  final bool isFree;
  final String duration;
  final String level;
  final String category;
  final String categoryId;
  final InstructorModel instructor;
  final List<LessonModel> lessons;
  final int totalLessons;
  final int totalStudents;
  final double rating;
  final int ratingCount;
  final bool isEnrolled;
  final int progress; // Progress percentage (0-100)
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.isFree = false,
    required this.duration,
    required this.level,
    required this.category,
    required this.categoryId,
    required this.instructor,
    this.lessons = const [],
    this.totalLessons = 0,
    this.totalStudents = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isEnrolled = false,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a CourseModel from a JSON object
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // طباعة تصحيح لفهم بنية البيانات
    debugPrint(
      '🔍 Processing course JSON: ${json['id']} - ${json['title']?['rendered']}',
    );

    // التعامل مع العنوان بشكل صحيح
    String title = '';
    if (json['title'] is Map) {
      title = json['title']['rendered'] ?? '';
    } else if (json['title'] is String) {
      title = json['title'];
    }

    // التعامل مع الوصف بشكل صحيح
    String description = '';
    if (json['content'] is Map) {
      description = json['content']['rendered'] ?? '';
    } else if (json['content'] is String) {
      description = json['content'];
    } else if (json['description'] is String) {
      description = json['description'];
    }

    // التعامل مع الصورة
    String image =
        json['tutor_course_img'] ??
        (json['featured_image'] ?? (json['image'] ?? ''));

    // التعامل مع التصنيفات
    String category = '';
    String categoryId = '';

    if (json['categories_name'] is List &&
        (json['categories_name'] as List).isNotEmpty) {
      category = json['categories_name'][0] ?? '';
    } else if (json['category_name'] is String) {
      category = json['category_name'];
    }

    if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      categoryId = json['categories'][0].toString();
    } else if (json['category_id'] is String || json['category_id'] is int) {
      categoryId = json['category_id'].toString();
    }

    // التعامل مع المدرب
    InstructorModel instructorModel;
    if (json['instructor'] != null) {
      instructorModel = InstructorModel.fromJson(json['instructor']);
    } else {
      instructorModel = InstructorModel.empty();
    }

    // التعامل مع الدروس
    List<LessonModel> lessonsList = [];
    if (json['lessons'] != null && json['lessons'] is List) {
      lessonsList =
          (json['lessons'] as List)
              .map((lesson) => LessonModel.fromJson(lesson))
              .toList();
    }

    // التعامل مع التقييم
    double ratingValue = 0.0;
    if (json['average_rating'] != null) {
      ratingValue = double.tryParse(json['average_rating'].toString()) ?? 0.0;
    } else if (json['rating'] != null) {
      ratingValue = double.tryParse(json['rating'].toString()) ?? 0.0;
    }

    return CourseModel(
      id: json['id'].toString(),
      title: title,
      description: description,
      image: image,
      price: json['price']?.toString() ?? '0',
      isFree: json['price'] == null || json['price'].toString() == '0',
      duration: json['duration']?.toString() ?? '',
      level: json['level']?.toString() ?? 'Beginner',
      category: category,
      categoryId: categoryId,
      instructor: instructorModel,
      lessons: lessonsList,
      totalLessons: json['total_lessons'] is int ? json['total_lessons'] : 0,
      totalStudents: json['total_enrolled'] is int ? json['total_enrolled'] : 0,
      rating: ratingValue,
      ratingCount: json['rating_count'] is int ? json['rating_count'] : 0,
      isEnrolled: json['is_enrolled'] == true,
      progress: json['progress_percent'] is int ? json['progress_percent'] : 0,
      createdAt:
          json['date'] != null
              ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['modified'] != null
              ? DateTime.tryParse(json['modified'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  /// Create a copy of this CourseModel with the given fields replaced
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? price,
    bool? isFree,
    String? duration,
    String? level,
    String? category,
    String? categoryId,
    InstructorModel? instructor,
    List<LessonModel>? lessons,
    int? totalLessons,
    int? totalStudents,
    double? rating,
    int? ratingCount,
    bool? isEnrolled,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      instructor: instructor ?? this.instructor,
      lessons: lessons ?? this.lessons,
      totalLessons: totalLessons ?? this.totalLessons,
      totalStudents: totalStudents ?? this.totalStudents,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    image,
    price,
    isFree,
    duration,
    level,
    category,
    categoryId,
    instructor,
    lessons,
    totalLessons,
    totalStudents,
    rating,
    ratingCount,
    isEnrolled,
    progress,
    createdAt,
    updatedAt,
  ];
}
