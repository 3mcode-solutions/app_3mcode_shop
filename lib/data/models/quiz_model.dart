import 'package:flutter/foundation.dart' show listEquals;

/// Model class for quiz questions
class QuizQuestionModel {
  /// Unique identifier for the question
  final String id;

  /// The question text
  final String question;

  /// List of possible answers
  final List<String> options;

  /// Index of the correct answer in the options list
  final int correctAnswerIndex;

  /// Explanation for the answer (shown after answering)
  final String? explanation;

  /// Points awarded for correct answer
  final int points;

  /// Constructor
  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.points = 1,
  });

  /// Create a copy of this question with the given fields replaced with the new values
  QuizQuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    int? points,
  }) {
    return QuizQuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
    );
  }

  /// Create a QuizQuestionModel from a JSON map
  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'].toString(),
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndex: json['correct_answer_index'] as int,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
    );
  }

  /// Convert this QuizQuestionModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestionModel &&
        other.id == id &&
        other.question == question &&
        listEquals(other.options, options) &&
        other.correctAnswerIndex == correctAnswerIndex &&
        other.explanation == explanation &&
        other.points == points;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      question,
      Object.hashAll(options),
      correctAnswerIndex,
      explanation,
      points,
    );
  }
}

/// Model class for quizzes
class QuizModel {
  /// Unique identifier for the quiz
  final String id;

  /// ID of the lesson this quiz belongs to
  final String lessonId;

  /// Title of the quiz
  final String title;

  /// Description of the quiz
  final String description;

  /// Time limit in minutes (0 for no limit)
  final int timeLimit;

  /// Minimum percentage to pass the quiz
  final int passingPercentage;

  /// List of questions in the quiz
  final List<QuizQuestionModel> questions;

  /// Whether the quiz has been completed
  final bool isCompleted;

  /// The score achieved (percentage)
  final int? score;

  /// Constructor
  const QuizModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    this.timeLimit = 0,
    this.passingPercentage = 70,
    required this.questions,
    this.isCompleted = false,
    this.score,
  });

  /// Create a copy of this quiz with the given fields replaced with the new values
  QuizModel copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    int? timeLimit,
    int? passingPercentage,
    List<QuizQuestionModel>? questions,
    bool? isCompleted,
    int? score,
  }) {
    return QuizModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimit: timeLimit ?? this.timeLimit,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      questions: questions ?? this.questions,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
    );
  }

  /// Create a QuizModel from a JSON map
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'].toString(),
      lessonId: json['lesson_id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      timeLimit: json['time_limit'] as int? ?? 0,
      passingPercentage: json['passing_percentage'] as int? ?? 70,
      questions:
          (json['questions'] as List<dynamic>)
              .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      isCompleted: json['is_completed'] as bool? ?? false,
      score: json['score'] as int?,
    );
  }

  /// Convert this QuizModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'time_limit': timeLimit,
      'passing_percentage': passingPercentage,
      'questions': questions.map((e) => e.toJson()).toList(),
      'is_completed': isCompleted,
      'score': score,
    };
  }

  /// Get the total points possible for this quiz
  int get totalPoints {
    return questions.fold(0, (sum, question) => sum + question.points);
  }

  /// Check if the quiz has been passed
  bool get isPassed {
    if (!isCompleted || score == null) return false;
    return score! >= passingPercentage;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel &&
        other.id == id &&
        other.lessonId == lessonId &&
        other.title == title &&
        other.description == description &&
        other.timeLimit == timeLimit &&
        other.passingPercentage == passingPercentage &&
        listEquals(other.questions, questions) &&
        other.isCompleted == isCompleted &&
        other.score == score;
  }

  @override
  int get hashCode {
    final questionHashes = questions.map((q) => q.hashCode).toList();
    return Object.hash(
      id,
      lessonId,
      title,
      description,
      timeLimit,
      passingPercentage,
      Object.hashAll(questionHashes),
      isCompleted,
      score,
    );
  }
}
