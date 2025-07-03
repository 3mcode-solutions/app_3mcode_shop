import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/assignment_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path/path.dart' as path;

/// Screen for viewing and submitting an assignment
class AssignmentScreen extends StatefulWidget {
  /// The assignment to view/submit
  final AssignmentModel assignment;

  /// Callback when the assignment is submitted
  final Function(String text, List<File> files) onSubmit;

  /// Constructor
  const AssignmentScreen({
    super.key,
    required this.assignment,
    required this.onSubmit,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill the text if there's a submitted text
    if (widget.assignment.submittedText != null) {
      _textController.text = widget.assignment.submittedText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Pick files for submission
  Future<void> _pickFiles() async {
    try {
      // Show a message that file picking is not available in this version
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('feature_not_available'),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // For demonstration purposes, add a mock file
      if (mounted) {
        setState(() {
          _selectedFiles.add(File('mock_assignment.pdf'));
        });
      }
    } catch (e) {
      debugPrint('❌ Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Remove a selected file
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Submit the assignment
  void _submitAssignment() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Call the submission callback
    widget.onSubmit(_textController.text, _selectedFiles);

    setState(() {
      _isSubmitting = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('assignment_submitted'),
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final assignment = widget.assignment;

    return Scaffold(
      appBar: AppBar(title: Text(assignment.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      assignment.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),

                    // Due date
                    if (assignment.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color:
                                assignment.isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${localizations.translate('due_date')}: ${_formatDate(assignment.dueDate!)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  assignment.isOverdue
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Points
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          '${localizations.translate('points')}: ${assignment.maxPoints}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(assignment.status),
                          size: 16,
                          color: _getStatusColor(assignment.status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${localizations.translate('status')}: ${_getStatusText(assignment.status, localizations)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getStatusColor(assignment.status),
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    const Divider(height: 24),

                    // Description
                    Text(
                      localizations.translate('description'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Html(
                      data: assignment.description,
                      style: {
                        'body': Style(
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.5),
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submission form (if not graded)
            if (assignment.status != AssignmentStatus.graded)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('your_submission'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Text submission
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: localizations.translate('submission_text'),
                          border: const OutlineInputBorder(),
                          hintText: localizations.translate(
                            'submission_text_hint',
                          ),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),

                      // File submission
                      Text(
                        localizations.translate('submission_files'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Selected files list
                      if (_selectedFiles.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = _selectedFiles[index];
                            final fileName = path.basename(file.path);

                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(fileName),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeFile(index),
                              ),
                            );
                          },
                        ),

                      // Add file button
                      ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: Text(localizations.translate('add_files')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitAssignment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isSubmitting
                                  ? const CircularProgressIndicator()
                                  : Text(
                                    localizations.translate(
                                      'submit_assignment',
                                    ),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Graded feedback (if graded)
            if (assignment.status == AssignmentStatus.graded)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('feedback'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Score
                      Row(
                        children: [
                          const Icon(Icons.score, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '${localizations.translate('score')}: ${assignment.points}/${assignment.maxPoints} (${assignment.percentageScore?.round()}%)',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Feedback text
                      if (assignment.feedback != null)
                        Html(
                          data: assignment.feedback!,
                          style: {
                            'body': Style(
                              fontSize: FontSize(16),
                              lineHeight: LineHeight(1.5),
                            ),
                          },
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Format a date as a string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get the icon for an assignment status
  IconData _getStatusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.notStarted:
        return Icons.assignment;
      case AssignmentStatus.inProgress:
        return Icons.edit;
      case AssignmentStatus.submitted:
        return Icons.check_circle;
      case AssignmentStatus.graded:
        return Icons.grade;
    }
  }

  /// Get the color for an assignment status
  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.notStarted:
        return Colors.grey;
      case AssignmentStatus.inProgress:
        return Colors.blue;
      case AssignmentStatus.submitted:
        return Colors.green;
      case AssignmentStatus.graded:
        return Colors.purple;
    }
  }

  /// Get the text for an assignment status
  String _getStatusText(
    AssignmentStatus status,
    AppLocalizations localizations,
  ) {
    switch (status) {
      case AssignmentStatus.notStarted:
        return localizations.translate('not_started');
      case AssignmentStatus.inProgress:
        return localizations.translate('in_progress');
      case AssignmentStatus.submitted:
        return localizations.translate('submitted');
      case AssignmentStatus.graded:
        return localizations.translate('graded');
    }
  }
}
