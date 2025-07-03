import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';

/// Widget to add or edit a comment
class CommentForm extends StatefulWidget {
  /// The lesson ID
  final String lessonId;

  /// The course ID
  final String courseId;

  /// The comment to edit (null for new comment)
  final CommentModel? comment;

  /// The parent comment ID (for replies)
  final String? parentId;

  /// Callback when the form is submitted
  final Function(String content, {String? parentId}) onSubmit;

  /// Callback when the cancel button is pressed
  final VoidCallback? onCancel;

  /// Constructor
  const CommentForm({
    super.key,
    required this.lessonId,
    required this.courseId,
    this.comment,
    this.parentId,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  late TextEditingController _commentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(
      text: widget.comment?.content ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    final isEditing = widget.comment != null;
    final isReplying = widget.parentId != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (isEditing || isReplying)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                isEditing
                    ? localizations.translate('edit_comment')
                    : localizations.translate('reply_to_comment'),
                style: theme.textTheme.titleMedium,
              ),
            ),

          // Comment text field
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  isEditing
                      ? localizations.translate('edit_comment_hint')
                      : isReplying
                      ? localizations.translate('reply_hint')
                      : localizations.translate('add_comment_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('comment_required');
              }
              return null;
            },
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(localizations.translate('cancel')),
                  ),

                const SizedBox(width: 8),

                // Submit button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    isEditing
                        ? localizations.translate('update')
                        : isReplying
                        ? localizations.translate('reply')
                        : localizations.translate('comment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Submit the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _commentController.text,
        parentId: widget.parentId ?? widget.comment?.parentId,
      );

      // Clear the form if not editing
      if (widget.comment == null) {
        _commentController.clear();
      }
    }
  }
}
