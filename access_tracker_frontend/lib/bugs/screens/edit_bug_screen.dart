import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bug_models.dart';
import '../providers/bug_provider.dart';
import '../widgets/bug_form.dart';

/// Edits an authenticated user's bug report using the shared bug form.
class EditBugScreen extends ConsumerWidget {
  final BugModel bug;

  const EditBugScreen({super.key, required this.bug});

  Future<bool> _save(
    BuildContext context,
    WidgetRef ref,
    CreateBugRequest request,
  ) async {
    final updated = await ref.read(bugMutationProvider.notifier).updateBug(
          bug.id,
          UpdateBugRequest(
            appVersion: request.appVersion,
            title: request.title,
            severity: request.severity,
            actualBehavior: request.actualBehavior,
            expectedBehavior: request.expectedBehavior,
            stepsToReproduce: request.stepsToReproduce,
          ),
        );
    if (!updated || !context.mounted) return false;

    ref.invalidate(myBugsProvider);
    ref.invalidate(bugFeedProvider);
    ref.invalidate(bugDetailsProvider(bug.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug report updated successfully.')),
    );
    if (context.mounted) Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bugMutationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bug')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: BugForm(
          initialBug: bug,
          onSubmit: (request) => _save(context, ref, request),
          isSubmitting: state.isLoading,
          errorMessage: state.errorMessage,
          submitLabel: 'Save Changes',
        ),
      ),
    );
  }
}
