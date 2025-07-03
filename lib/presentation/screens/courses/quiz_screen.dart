import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/quiz_model.dart';

/// Screen for taking a quiz
class QuizScreen extends StatefulWidget {
  /// The quiz to take
  final QuizModel quiz;

  /// Callback when the quiz is completed
  final Function(int score) onComplete;

  /// Constructor
  const QuizScreen({super.key, required this.quiz, required this.onComplete});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  List<bool> _isAnswerCorrect = [];
  bool _quizCompleted = false;
  int _score = 0;
  int _totalPoints = 0;

  // Timer variables
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Initialize selected answers and correctness arrays
    _selectedAnswers = List.filled(widget.quiz.questions.length, null);
    _isAnswerCorrect = List.filled(widget.quiz.questions.length, false);

    // Calculate total points
    _totalPoints = widget.quiz.totalPoints;

    // Start timer if there's a time limit
    if (widget.quiz.timeLimit > 0) {
      _remainingSeconds = widget.quiz.timeLimit * 60;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start the quiz timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _completeQuiz();
        }
      });
    });
  }

  /// Format the remaining time as MM:SS
  String _formatRemainingTime() {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Handle answer selection
  void _selectAnswer(int questionIndex, int answerIndex) {
    if (_quizCompleted) return;

    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;

      // Check if the answer is correct
      final question = widget.quiz.questions[questionIndex];
      _isAnswerCorrect[questionIndex] =
          answerIndex == question.correctAnswerIndex;
    });
  }

  /// Move to the next question
  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  /// Move to the previous question
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  /// Complete the quiz and calculate the score
  void _completeQuiz() {
    if (_quizCompleted) return;

    // Cancel the timer
    _timer?.cancel();

    // Calculate the score
    int earnedPoints = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_isAnswerCorrect[i]) {
        earnedPoints += widget.quiz.questions[i].points;
      }
    }

    // Calculate percentage score
    final percentageScore =
        (_totalPoints > 0) ? ((earnedPoints / _totalPoints) * 100).round() : 0;

    setState(() {
      _quizCompleted = true;
      _score = percentageScore;
    });

    // Call the completion callback
    widget.onComplete(_score);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Current question
    final question = widget.quiz.questions[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    final isAnswered = selectedAnswer != null;
    final isCorrect = _isAnswerCorrect[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          // Timer display
          if (widget.quiz.timeLimit > 0 && !_quizCompleted)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _formatRemainingTime(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        _remainingSeconds < 60
                            ? Colors.red
                            : theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body:
          _quizCompleted
              ? _buildResultsScreen(theme, localizations)
              : _buildQuizScreen(
                theme,
                localizations,
                question,
                selectedAnswer,
                isAnswered,
                isCorrect,
              ),
    );
  }

  /// Build the quiz screen
  Widget _buildQuizScreen(
    ThemeData theme,
    AppLocalizations localizations,
    QuizQuestionModel question,
    int? selectedAnswer,
    bool isAnswered,
    bool isCorrect,
  ) {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),

        // Question counter
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizations.translate('question')} ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${localizations.translate('points')}: ${question.points}',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),

        // Question text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(question.question, style: theme.textTheme.titleLarge),
        ),

        // Answer options
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedAnswer == index;

              // Determine the card color based on selection and correctness
              Color? cardColor;
              if (isSelected) {
                if (isAnswered) {
                  cardColor = isCorrect ? Colors.green[100] : Colors.red[100];
                } else {
                  cardColor = theme.colorScheme.primaryContainer;
                }
              }

              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _selectAnswer(_currentQuestionIndex, index),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Option letter (A, B, C, D, etc.)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.grey[300],
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(
                                65 + index,
                              ), // A, B, C, D, etc.
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimary
                                        : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Option text
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),

                        // Correct/incorrect icon
                        if (isAnswered && isSelected)
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Explanation (if answered)
        if (isAnswered && question.explanation != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: isCorrect ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect
                          ? localizations.translate('correct')
                          : localizations.translate('incorrect'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              TextButton.icon(
                onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                icon: const Icon(Icons.arrow_back),
                label: Text(localizations.translate('previous')),
              ),

              // Next/Finish button
              ElevatedButton(
                onPressed:
                    isAnswered
                        ? _currentQuestionIndex <
                                widget.quiz.questions.length - 1
                            ? _nextQuestion
                            : _completeQuiz
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? localizations.translate('next')
                      : localizations.translate('finish'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the results screen
  Widget _buildResultsScreen(ThemeData theme, AppLocalizations localizations) {
    final isPassed = _score >= widget.quiz.passingPercentage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pass/fail icon
            Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: isPassed ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),

            // Result text
            Text(
              isPassed
                  ? localizations.translate('quiz_passed')
                  : localizations.translate('quiz_failed'),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isPassed ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Score
            Text(
              '${localizations.translate('your_score')}: $_score%',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              '${localizations.translate('passing_score')}: ${widget.quiz.passingPercentage}%',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 32),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                localizations.translate('close'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
