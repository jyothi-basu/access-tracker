import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/bug_models.dart';
import '../providers/bug_provider.dart';
import '../widgets/bug_card.dart';

/// Lists bug reports created by the authenticated user.
class MyBugsScreen extends ConsumerWidget {
  const MyBugsScreen({super.key});

  Future<void> _deleteBug(
    BuildContext context,
    WidgetRef ref,
    BugModel bug,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Bug Report?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('This action cannot be undone.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete Bug'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final deleted = await ref.read(bugMutationProvider.notifier).deleteBug(bug.id);
    if (!deleted || !context.mounted) return;

    ref.invalidate(myBugsProvider);
    ref.invalidate(bugFeedProvider);
    ref.invalidate(bugDetailsProvider(bug.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug report deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bugsState = ref.watch(myBugsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bugs')),
      body: bugsState.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(error: error.toString()),
        data: (bugs) {
          if (bugs.isEmpty) {
            return const Center(child: Text('You have not reported any bugs yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: bugs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final bug = bugs[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BugCard(
                    bug: bug,
                    onViewDetails: () => context.push('/bugs/${bug.id}'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/bugs/${bug.id}/edit', extra: bug),
                    child: const Text('Edit Bug'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _deleteBug(context, ref, bug),
                    child: const Text('Delete Bug'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

