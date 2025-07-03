import 'package:flutter/foundation.dart' show listEquals;

/// Model class for course reviews
class ReviewModel {
  /// Unique identifier for the review
  final String id;

  /// ID of the course this review belongs to
  final String courseId;

  /// ID of the user who wrote the review
  final String userId;

  /// Name of the user who wrote the review
  final String userName;

  /// Avatar URL of the user who wrote the review
  final String? userAvatar;

  /// Rating value (1-5)
  final double rating;

  /// Review content/comment
  final String content;

  /// Date when the review was created
  final DateTime createdAt;

  /// Date when the review was last updated
  final DateTime updatedAt;

  /// Whether the review is approved (visible to others)
  final bool isApproved;

  /// Constructor
  const ReviewModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isApproved = true,
  });

  /// Create a copy of this review with the given fields replaced with the new values
  ReviewModel copyWith({
    String? id,
    String? courseId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  /// Create a ReviewModel from a JSON map
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      rating:
          (json['rating'] is int)
              ? (json['rating'] as int).toDouble()
              : json['rating'] as double,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isApproved: json['is_approved'] as bool? ?? true,
    );
  }

  /// Convert this ReviewModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_approved': isApproved,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel &&
        other.id == id &&
        other.courseId == courseId &&
        other.userId == userId &&
        other.userName == userName &&
        other.userAvatar == userAvatar &&
        other.rating == rating &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isApproved == isApproved;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      courseId,
      userId,
      userName,
      userAvatar,
      rating,
      content,
      createdAt,
      updatedAt,
      isApproved,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, courseId: $courseId, userId: $userId, userName: $userName, rating: $rating, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, isApproved: $isApproved)';
  }
}
