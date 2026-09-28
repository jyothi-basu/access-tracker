import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bug_models.dart';
import '../providers/bug_provider.dart';
import '../providers/create_bug_provider.dart';
import '../widgets/bug_form.dart';

/// Creates a bug report from the authenticated user's Report Bug tab.
class CreateBugScreen extends ConsumerWidget {
  final VoidCallback onBugCreated;

  const CreateBugScreen({
    super.key,
    required this.onBugCreated,
  });

  Future<bool> _submit(
    BuildContext context,
    WidgetRef ref,
    CreateBugRequest request,
  ) async {
    final success = await ref.read(createBugProvider.notifier).submit(request);
    if (!success || !context.mounted) return false;

    await ref.read(bugFeedProvider.notifier).fetchBugs();
    if (!context.mounted) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug report submitted successfully.')),
    );
    onBugCreated();
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState = ref.watch(createBugProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: BugForm(
        onSubmit: (request) => _submit(context, ref, request),
        isSubmitting: submissionState.isSubmitting,
        errorMessage: submissionState.errorMessage,
      ),
    );
  }
}
