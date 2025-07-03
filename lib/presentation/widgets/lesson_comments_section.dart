import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/comment_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/widgets/comment_card.dart';
import 'package:app_3mcode_shop/presentation/widgets/comment_form.dart';

/// Widget to display lesson comments section
class LessonCommentsSection extends StatefulWidget {
  /// The lesson ID
  final String lessonId;

  /// The course ID
  final String courseId;

  /// Constructor
  const LessonCommentsSection({
    super.key,
    required this.lessonId,
    required this.courseId,
  });

  @override
  State<LessonCommentsSection> createState() => _LessonCommentsSectionState();
}

class _LessonCommentsSectionState extends State<LessonCommentsSection> {
  CommentModel? _commentToEdit;
  String? _replyToCommentId;

  @override
  void initState() {
    super.initState();
    // Load comments when the widget is initialized
    context.read<CourseBloc>().add(LoadLessonComments(widget.lessonId));
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
        return current is CommentAdded ||
            current is CommentUpdated ||
            current is CommentDeleted;
      },
      listener: (context, state) {
        if (state is CommentAdded && state.success) {
          setState(() {
            _commentToEdit = null;
            _replyToCommentId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('comment_added')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CommentUpdated && state.success) {
          setState(() {
            _commentToEdit = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('comment_updated')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CommentDeleted && state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('comment_deleted')),
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

        // Show comments
        if (state is LessonCommentsLoaded) {
          final comments = state.comments;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with comment count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Comment count
                    Text(
                      '${localizations.translate('comments')} (${comments.length})',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),

              // Add comment form (only for authenticated users)
              if (isAuthenticated &&
                  _commentToEdit == null &&
                  _replyToCommentId == null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CommentForm(
                    lessonId: widget.lessonId,
                    courseId: widget.courseId,
                    onSubmit: (content, {parentId}) {
                      context.read<CourseBloc>().add(
                        AddLessonComment(
                          lessonId: widget.lessonId,
                          courseId: widget.courseId,
                          content: content,
                          parentId: parentId,
                        ),
                      );
                    },
                  ),
                ),

              // Edit comment form
              if (_commentToEdit != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CommentForm(
                        lessonId: widget.lessonId,
                        courseId: widget.courseId,
                        comment: _commentToEdit,
                        onSubmit: (content, {parentId}) {
                          context.read<CourseBloc>().add(
                            UpdateComment(
                              commentId: _commentToEdit!.id,
                              content: content,
                            ),
                          );
                        },
                        onCancel: () {
                          setState(() {
                            _commentToEdit = null;
                          });
                        },
                      ),
                    ),
                  ),
                ),

              // Reply to comment form
              if (_replyToCommentId != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: 16.0,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CommentForm(
                        lessonId: widget.lessonId,
                        courseId: widget.courseId,
                        parentId: _replyToCommentId,
                        onSubmit: (content, {parentId}) {
                          context.read<CourseBloc>().add(
                            AddLessonComment(
                              lessonId: widget.lessonId,
                              courseId: widget.courseId,
                              content: content,
                              parentId: parentId,
                            ),
                          );
                        },
                        onCancel: () {
                          setState(() {
                            _replyToCommentId = null;
                          });
                        },
                      ),
                    ),
                  ),
                ),

              // Comments list
              if (comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      localizations.translate('no_comments'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isAuthor = comment.userId == userId;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Root comment
                        CommentCard(
                          comment: comment,
                          isAuthor: isAuthor,
                          onReply:
                              isAuthenticated
                                  ? () {
                                    setState(() {
                                      _commentToEdit = null;
                                      _replyToCommentId = comment.id;
                                    });
                                  }
                                  : null,
                          onEdit:
                              isAuthor
                                  ? () {
                                    setState(() {
                                      _commentToEdit = comment;
                                      _replyToCommentId = null;
                                    });
                                  }
                                  : null,
                          onDelete:
                              isAuthor
                                  ? () {
                                    _showDeleteConfirmationDialog(comment);
                                  }
                                  : null,
                        ),

                        // Replies
                        if (comment.replies.isNotEmpty)
                          ...comment.replies.map((reply) {
                            final isReplyAuthor = reply.userId == userId;

                            return CommentCard(
                              comment: reply,
                              isAuthor: isReplyAuthor,
                              showReplyButton: false,
                              onEdit:
                                  isReplyAuthor
                                      ? () {
                                        setState(() {
                                          _commentToEdit = reply;
                                          _replyToCommentId = null;
                                        });
                                      }
                                      : null,
                              onDelete:
                                  isReplyAuthor
                                      ? () {
                                        _showDeleteConfirmationDialog(reply);
                                      }
                                      : null,
                            );
                          }),
                      ],
                    );
                  },
                ),
            ],
          );
        }

        // Default empty state
        return Center(child: Text(localizations.translate('no_comments')));
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(CommentModel comment) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.translate('delete_comment')),
            content: Text(
              localizations.translate('delete_comment_confirmation'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CourseBloc>().add(DeleteComment(comment.id));
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
