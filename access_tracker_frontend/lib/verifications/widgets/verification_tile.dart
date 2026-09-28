import 'package:flutter/material.dart';
import '../models/verification_models.dart';

/// Read-only vertical presentation of one community verification.
class VerificationTile extends StatelessWidget {
  final VerificationModel verification;
  final String? applicationName;
  final String? bugTitle;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VerificationTile({
    super.key,
    required this.verification,
    this.applicationName,
    this.bugTitle,
    this.isOwner = false,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (applicationName != null && applicationName!.isNotEmpty)
              Text('Application: $applicationName'),
            if (bugTitle != null && bugTitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Bug: $bugTitle'),
            ],
            if ((applicationName != null && applicationName!.isNotEmpty) ||
                (bugTitle != null && bugTitle!.isNotEmpty))
              const SizedBox(height: 6),
            Text('Username: ${verification.username}'),
            const SizedBox(height: 6),
            Text('Verification: ${verification.verificationType.label}'),
            const SizedBox(height: 6),
            Text('Version: ${verification.appVersion}'),
            if (verification.deviceModel != null &&
                verification.deviceModel!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Device: ${verification.deviceModel}'),
            ],
            const SizedBox(height: 6),
            Text('Verified On: ${_dateLabel(verification.createdAt)}'),
            if (isOwner) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onEdit,
                child: const Text('Edit Verification'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDelete,
                child: const Text('Delete Verification'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
