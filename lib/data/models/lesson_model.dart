import 'package:equatable/equatable.dart';

/// Enum representing the type of lesson content
enum LessonType {
  video,
  document,
  text,
  quiz,
  assignment,
  unknown,
}

/// A model class representing a lesson from Tutor LMS
class LessonModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String summary;
  final LessonType type;
  final String videoUrl;
  final String documentUrl;
  final String thumbnailUrl;
  final int duration; // Duration in seconds
  final bool isCompleted;
  final bool isPreviewable;
  final int order;
  final String courseId;
  final String parentId; // For topics/sections

  const LessonModel({
    required this.id,
    required this.title,
    this.content = '',
    this.summary = '',
    this.type = LessonType.text,
    this.videoUrl = '',
    this.documentUrl = '',
    this.thumbnailUrl = '',
    this.duration = 0,
    this.isCompleted = false,
    this.isPreviewable = false,
    this.order = 0,
    required this.courseId,
    this.parentId = '',
  });

  /// Create a LessonModel from a JSON object
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    // Determine lesson type
    LessonType lessonType = LessonType.text;
    if (json['video'] != null && json['video'].toString().isNotEmpty) {
      lessonType = LessonType.video;
    } else if (json['attachments'] != null && 
        (json['attachments'] as List).isNotEmpty) {
      lessonType = LessonType.document;
    } else if (json['quiz_id'] != null) {
      lessonType = LessonType.quiz;
    } else if (json['assignment_id'] != null) {
      lessonType = LessonType.assignment;
    }

    return LessonModel(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      summary: json['excerpt'] ?? '',
      type: lessonType,
      videoUrl: json['video'] ?? '',
      documentUrl: json['attachments'] != null && (json['attachments'] as List).isNotEmpty 
          ? json['attachments'][0]['url'] ?? '' 
          : '',
      thumbnailUrl: json['thumbnail'] ?? '',
      duration: json['video_duration_sec'] ?? 0,
      isCompleted: json['is_completed'] == true,
      isPreviewable: json['is_preview'] == true,
      order: json['order'] ?? 0,
      courseId: json['course_id']?.toString() ?? '0',
      parentId: json['topic_id']?.toString() ?? '',
    );
  }

  /// Create a copy of this LessonModel with the given fields replaced
  LessonModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    LessonType? type,
    String? videoUrl,
    String? documentUrl,
    String? thumbnailUrl,
    int? duration,
    bool? isCompleted,
    bool? isPreviewable,
    int? order,
    String? courseId,
    String? parentId,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      type: type ?? this.type,
      videoUrl: videoUrl ?? this.videoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      isPreviewable: isPreviewable ?? this.isPreviewable,
      order: order ?? this.order,
      courseId: courseId ?? this.courseId,
      parentId: parentId ?? this.parentId,
    );
  }

  /// Format the duration as a string (e.g., "1h 30m")
  String get formattedDuration {
    if (duration == 0) return '';
    
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  List<Object> get props => [
    id,
    title,
    content,
    summary,
    type,
    videoUrl,
    documentUrl,
    thumbnailUrl,
    duration,
    isCompleted,
    isPreviewable,
    order,
    courseId,
    parentId,
  ];
}
