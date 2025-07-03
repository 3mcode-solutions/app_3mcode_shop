import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/models/lesson_model.dart';

class LessonItem extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onTap;
  final bool isLocked;

  const LessonItem({
    Key? key,
    required this.lesson,
    required this.onTap,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Lesson type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getLessonTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLessonTypeIcon(),
                  color: _getLessonTypeColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Lesson details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson title
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (lesson.summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // Lesson summary
                      Text(
                        lesson.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    // Lesson duration
                    if (lesson.duration > 0)
                      Text(
                        lesson.formattedDuration,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLocked ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Lesson status
              _buildLessonStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonStatus() {
    if (isLocked) {
      return const Icon(
        Icons.lock,
        color: Colors.grey,
        size: 20,
      );
    }

    if (lesson.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (lesson.isPreviewable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Preview',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const Icon(
      Icons.play_circle_outline,
      color: Colors.grey,
      size: 24,
    );
  }

  IconData _getLessonTypeIcon() {
    switch (lesson.type) {
      case LessonType.video:
        return Icons.videocam;
      case LessonType.document:
        return Icons.insert_drive_file;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.assignment:
        return Icons.assignment;
      case LessonType.text:
      default:
        return Icons.article;
    }
  }

  Color _getLessonTypeColor() {
    switch (lesson.type) {
      case LessonType.video:
        return Colors.red;
      case LessonType.document:
        return Colors.blue;
      case LessonType.quiz:
        return Colors.purple;
      case LessonType.assignment:
        return Colors.orange;
      case LessonType.text:
      default:
        return Colors.green;
    }
  }
}
