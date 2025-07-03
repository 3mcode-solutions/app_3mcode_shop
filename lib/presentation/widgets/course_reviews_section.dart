import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/review_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/widgets/review_card.dart';
import 'package:app_3mcode_shop/presentation/widgets/review_form.dart';

/// Widget to display course reviews section
class CourseReviewsSection extends StatefulWidget {
  /// The course ID
  final String courseId;

  /// Constructor
  const CourseReviewsSection({super.key, required this.courseId});

  @override
  State<CourseReviewsSection> createState() => _CourseReviewsSectionState();
}

class _CourseReviewsSectionState extends State<CourseReviewsSection> {
  bool _showAddReviewForm = false;
  ReviewModel? _reviewToEdit;

  @override
  void initState() {
    super.initState();
    // Load reviews when the widget is initialized
    context.read<CourseBloc>().add(LoadCourseReviews(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is Authenticated;
    final userId = isAuthenticated ? authState.user.id : '';

    return BlocConsumer<CourseBloc, CourseState>(
      listenWhen: (previous, current) {
        return current is CourseReviewSubmitted ||
            current is ReviewUpdated ||
            current is ReviewDeleted;
      },
      listener: (context, state) {
        if (state is CourseReviewSubmitted && state.success) {
          setState(() {
            _showAddReviewForm = false;
            _reviewToEdit = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('review_submitted')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewUpdated && state.success) {
          setState(() {
            _showAddReviewForm = false;
            _reviewToEdit = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('review_updated')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewDeleted && state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('review_deleted')),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading indicator
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (state is CourseError) {
          return Center(
            child: Text(
              '${localizations.translate('error')}: ${state.message}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        // Show reviews
        if (state is CourseReviewsLoaded) {
          final reviews = state.reviews;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with review count and add review button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Review count
                    Text(
                      '${localizations.translate('reviews')} (${reviews.length})',
                      style: theme.textTheme.titleLarge,
                    ),

                    // Add review button (only for authenticated users)
                    if (isAuthenticated && !_showAddReviewForm)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAddReviewForm = true;
                            _reviewToEdit = null;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: Text(localizations.translate('add_review')),
                      ),
                  ],
                ),
              ),

              // Add/Edit review form
              if (_showAddReviewForm || _reviewToEdit != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ReviewForm(
                        courseId: widget.courseId,
                        review: _reviewToEdit,
                        onSubmit: (rating, review) {
                          if (_reviewToEdit == null) {
                            // Submit new review
                            context.read<CourseBloc>().add(
                              SubmitCourseReview(
                                courseId: widget.courseId,
                                rating: rating,
                                review: review,
                              ),
                            );
                          } else {
                            // Update existing review
                            context.read<CourseBloc>().add(
                              UpdateReview(
                                reviewId: _reviewToEdit!.id,
                                rating: rating,
                                content: review,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

              // Reviews list
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      localizations.translate('no_reviews'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final isAuthor = review.userId == userId;

                    return ReviewCard(
                      review: review,
                      isAuthor: isAuthor,
                      onEdit:
                          isAuthor
                              ? () {
                                setState(() {
                                  _showAddReviewForm = true;
                                  _reviewToEdit = review;
                                });
                              }
                              : null,
                      onDelete:
                          isAuthor
                              ? () {
                                _showDeleteConfirmationDialog(review);
                              }
                              : null,
                    );
                  },
                ),
            ],
          );
        }

        // Default empty state
        return Center(child: Text(localizations.translate('no_reviews')));
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(ReviewModel review) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.translate('delete_review')),
            content: Text(
              localizations.translate('delete_review_confirmation'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CourseBloc>().add(DeleteReview(review.id));
                },
                child: Text(
                  localizations.translate('delete'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}
