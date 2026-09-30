import 'package:flutter/material.dart';
import '../models/developer_models.dart';

/// Presents one developer response as a read-only vertical card with actions.
class DeveloperResponseTile extends StatelessWidget {
  final DeveloperResponse response;
  final bool isOwner;
  final bool showOpenBug;
  final VoidCallback? onOpenBug;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeveloperResponseTile({
    super.key,
    required this.response,
    required this.isOwner,
    this.showOpenBug = false,
    this.onOpenBug,
    this.onEdit,
    this.onDelete,
  });

  String _dateLabel(DateTime date) {
    return date.toLocal().toString().split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Developer: ${response.developerUsername}'),
            const SizedBox(height: 8),
            const Text(
              'Response:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(response.response),
            const SizedBox(height: 8),
            Text('Created: ${_dateLabel(response.createdAt)}'),
            const SizedBox(height: 4),
            Text('Updated: ${_dateLabel(response.updatedAt)}'),
            if (showOpenBug) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onOpenBug,
                child: const Text('Open Bug'),
              ),
            ],
            if (isOwner) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onEdit,
                child: const Text('Edit Response'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDelete,
                child: const Text('Delete Response'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
