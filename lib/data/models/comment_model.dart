import 'package:flutter/foundation.dart' show listEquals;

/// Model class for lesson comments
class CommentModel {
  /// Unique identifier for the comment
  final String id;

  /// ID of the lesson this comment belongs to
  final String lessonId;

  /// ID of the course this comment belongs to
  final String courseId;

  /// ID of the user who wrote the comment
  final String userId;

  /// Name of the user who wrote the comment
  final String userName;

  /// Avatar URL of the user who wrote the comment
  final String? userAvatar;

  /// Comment content
  final String content;

  /// Date when the comment was created
  final DateTime createdAt;

  /// Date when the comment was last updated
  final DateTime updatedAt;

  /// Whether the comment is approved (visible to others)
  final bool isApproved;

  /// Parent comment ID (for replies)
  final String? parentId;

  /// List of replies to this comment
  final List<CommentModel> replies;

  /// Constructor
  const CommentModel({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isApproved = true,
    this.parentId,
    this.replies = const [],
  });

  /// Create a copy of this comment with the given fields replaced with the new values
  CommentModel copyWith({
    String? id,
    String? lessonId,
    String? courseId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    String? parentId,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }

  /// Create a CommentModel from a JSON map
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      lessonId: json['lesson_id'].toString(),
      courseId: json['course_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isApproved: json['is_approved'] as bool? ?? true,
      parentId: json['parent_id'] as String?,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert this CommentModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'course_id': courseId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_approved': isApproved,
      'parent_id': parentId,
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel &&
        other.id == id &&
        other.lessonId == lessonId &&
        other.courseId == courseId &&
        other.userId == userId &&
        other.userName == userName &&
        other.userAvatar == userAvatar &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isApproved == isApproved &&
        other.parentId == parentId &&
        listEquals(other.replies, replies);
  }

  @override
  int get hashCode {
    final replyHashes = replies.map((reply) => reply.hashCode).toList();
    return Object.hash(
      id,
      lessonId,
      courseId,
      userId,
      userName,
      userAvatar,
      content,
      createdAt,
      updatedAt,
      isApproved,
      parentId,
      Object.hashAll(replyHashes),
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, lessonId: $lessonId, courseId: $courseId, userId: $userId, userName: $userName, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, isApproved: $isApproved, parentId: $parentId, replies: ${replies.length})';
  }
}
