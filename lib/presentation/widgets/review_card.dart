import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/utils/date_formatter.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

/// Widget to display a review card
class ReviewCard extends StatelessWidget {
  /// The review to display
  final ReviewModel review;

  /// Callback when the edit button is pressed
  final VoidCallback? onEdit;

  /// Callback when the delete button is pressed
  final VoidCallback? onDelete;

  /// Whether the current user is the author of the review
  final bool isAuthor;

  /// Constructor
  const ReviewCard({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
    this.isAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      review.userAvatar != null && review.userAvatar!.isNotEmpty
                          ? NetworkImage(review.userAvatar!)
                          : null,
                  child:
                      review.userAvatar == null || review.userAvatar!.isEmpty
                          ? Text(
                            review.userName.isNotEmpty
                                ? review.userName[0]
                                : '?',
                          )
                          : null,
                ),
                const SizedBox(width: 12),

                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(review.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(review.rating),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Review content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(review.content, style: theme.textTheme.bodyMedium),
            ),

            // Actions if the user is the author
            if (isAuthor)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit button
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: Text(localizations.translate('edit')),
                    ),

                  // Delete button
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      label: Text(localizations.translate('delete')),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Get the color based on the rating
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.amber;
    if (rating >= 1.5) return Colors.orange;
    return Colors.red;
  }
}
