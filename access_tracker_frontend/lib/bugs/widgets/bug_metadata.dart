import 'package:flutter/material.dart';
import '../models/bug_models.dart';

/// Displays shared, non-interactive bug metadata in a vertical layout.
class BugMetadata extends StatelessWidget {
  final BugModel bug;

  const BugMetadata({super.key, required this.bug});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Application: ${bug.applicationName}'),
        Text('Platform: ${_label(bug.platform)}'),
        Text('Version: ${bug.appVersion}'),
        Text('Screen Reader: ${_label(bug.screenReader)}'),
        Text('Severity: ${_label(bug.severity)}'),
        Text('Reported: ${_relativeTime(bug.createdAt)}'),
      ],
    );
  }

  static String _label(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }

  static String _relativeTime(DateTime createdAt) {
    final difference = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (difference.isNegative || difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
  }
}
