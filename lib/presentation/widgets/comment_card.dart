import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/utils/date_formatter.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

/// Widget to display a comment card
class CommentCard extends StatelessWidget {
  /// The comment to display
  final CommentModel comment;

  /// Callback when the reply button is pressed
  final VoidCallback? onReply;

  /// Callback when the edit button is pressed
  final VoidCallback? onEdit;

  /// Callback when the delete button is pressed
  final VoidCallback? onDelete;

  /// Whether the current user is the author of the comment
  final bool isAuthor;

  /// Whether to show the reply button
  final bool showReplyButton;

  /// Constructor
  const CommentCard({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.isAuthor = false,
    this.showReplyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.only(
        left: comment.parentId != null ? 32.0 : 8.0,
        right: 8.0,
        top: 8.0,
        bottom: 8.0,
      ),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      comment.userAvatar != null &&
                              comment.userAvatar!.isNotEmpty
                          ? NetworkImage(comment.userAvatar!)
                          : null,
                  child:
                      comment.userAvatar == null || comment.userAvatar!.isEmpty
                          ? Text(
                            comment.userName.isNotEmpty
                                ? comment.userName[0]
                                : '?',
                          )
                          : null,
                ),
                const SizedBox(width: 8),

                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Comment content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(comment.content, style: theme.textTheme.bodyMedium),
            ),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reply button
                if (showReplyButton && onReply != null)
                  TextButton.icon(
                    onPressed: onReply,
                    icon: const Icon(Icons.reply, size: 16),
                    label: Text(localizations.translate('reply')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                // Edit button
                if (isAuthor && onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(localizations.translate('edit')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                // Delete button
                if (isAuthor && onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text(localizations.translate('delete')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}
