import 'package:flutter/foundation.dart' show listEquals;

/// Status of an assignment
enum AssignmentStatus {
  /// Not started
  notStarted,

  /// In progress
  inProgress,

  /// Submitted
  submitted,

  /// Graded
  graded,
}

/// Model class for assignments
class AssignmentModel {
  /// Unique identifier for the assignment
  final String id;

  /// ID of the lesson this assignment belongs to
  final String lessonId;

  /// Title of the assignment
  final String title;

  /// Description of the assignment
  final String description;

  /// Due date for the assignment
  final DateTime? dueDate;

  /// Maximum points possible
  final int maxPoints;

  /// Current status of the assignment
  final AssignmentStatus status;

  /// Points awarded (only available if status is graded)
  final int? points;

  /// Feedback from the instructor (only available if status is graded)
  final String? feedback;

  /// List of file URLs submitted by the student
  final List<String> submittedFiles;

  /// Text submitted by the student
  final String? submittedText;

  /// Date when the assignment was submitted
  final DateTime? submittedAt;

  /// Constructor
  const AssignmentModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    this.dueDate,
    this.maxPoints = 100,
    this.status = AssignmentStatus.notStarted,
    this.points,
    this.feedback,
    this.submittedFiles = const [],
    this.submittedText,
    this.submittedAt,
  });

  /// Create a copy of this assignment with the given fields replaced with the new values
  AssignmentModel copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    AssignmentStatus? status,
    int? points,
    String? feedback,
    List<String>? submittedFiles,
    String? submittedText,
    DateTime? submittedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      maxPoints: maxPoints ?? this.maxPoints,
      status: status ?? this.status,
      points: points ?? this.points,
      feedback: feedback ?? this.feedback,
      submittedFiles: submittedFiles ?? this.submittedFiles,
      submittedText: submittedText ?? this.submittedText,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  /// Create an AssignmentModel from a JSON map
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'].toString(),
      lessonId: json['lesson_id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate:
          json['due_date'] != null
              ? DateTime.parse(json['due_date'] as String)
              : null,
      maxPoints: json['max_points'] as int? ?? 100,
      status: AssignmentStatus.values.firstWhere(
        (e) => e.toString() == 'AssignmentStatus.${json['status']}',
        orElse: () => AssignmentStatus.notStarted,
      ),
      points: json['points'] as int?,
      feedback: json['feedback'] as String?,
      submittedFiles:
          (json['submitted_files'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      submittedText: json['submitted_text'] as String?,
      submittedAt:
          json['submitted_at'] != null
              ? DateTime.parse(json['submitted_at'] as String)
              : null,
    );
  }

  /// Convert this AssignmentModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'max_points': maxPoints,
      'status': status.toString().split('.').last,
      'points': points,
      'feedback': feedback,
      'submitted_files': submittedFiles,
      'submitted_text': submittedText,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }

  /// Check if the assignment is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == AssignmentStatus.submitted ||
        status == AssignmentStatus.graded) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  /// Get the percentage score (if graded)
  double? get percentageScore {
    if (points == null || maxPoints == 0) return null;
    return (points! / maxPoints) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssignmentModel &&
        other.id == id &&
        other.lessonId == lessonId &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.maxPoints == maxPoints &&
        other.status == status &&
        other.points == points &&
        other.feedback == feedback &&
        listEquals(other.submittedFiles, submittedFiles) &&
        other.submittedText == submittedText &&
        other.submittedAt == submittedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      lessonId,
      title,
      description,
      dueDate,
      maxPoints,
      status,
      points,
      feedback,
      Object.hashAll(submittedFiles),
      submittedText,
      submittedAt,
    );
  }
}
