import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';

/// Widget to add or edit a review
class ReviewForm extends StatefulWidget {
  /// The course ID
  final String courseId;

  /// The review to edit (null for new review)
  final ReviewModel? review;

  /// Callback when the form is submitted
  final Function(int rating, String review) onSubmit;

  /// Constructor
  const ReviewForm({
    super.key,
    required this.courseId,
    this.review,
    required this.onSubmit,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  late int _rating;
  late TextEditingController _reviewController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating.toInt() ?? 5;
    _reviewController = TextEditingController(
      text: widget.review?.content ?? '',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            widget.review == null
                ? localizations.translate('add_review')
                : localizations.translate('edit_review'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Rating
          Text(
            localizations.translate('rating'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: index < _rating ? Colors.amber : Colors.grey,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),

          // Review text
          Text(
            localizations.translate('review'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Review text field
          TextFormField(
            controller: _reviewController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: localizations.translate('write_review_hint'),
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
                return localizations.translate('review_required');
              }
              if (value.length < 10) {
                return localizations.translate('review_too_short');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
              ),
              child: Text(
                widget.review == null
                    ? localizations.translate('submit_review')
                    : localizations.translate('update_review'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Submit the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_rating, _reviewController.text);
    }
  }
}
