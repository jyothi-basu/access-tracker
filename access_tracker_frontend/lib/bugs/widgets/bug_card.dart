import 'package:flutter/material.dart';
import '../models/bug_models.dart';
import 'bug_metadata.dart';

/// Presents a bug as a linear, screen-reader-friendly card.
class BugCard extends StatelessWidget {
  final BugModel bug;
  final VoidCallback onViewDetails;

  const BugCard({
    super.key,
    required this.bug,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bug.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Reporter: ${bug.reporterUsername}'),
            const SizedBox(height: 6),
            BugMetadata(bug: bug),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                child: const Text('View Bug Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
