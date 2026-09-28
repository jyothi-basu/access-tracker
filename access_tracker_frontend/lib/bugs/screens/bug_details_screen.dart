import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/bug_models.dart';
import '../providers/bug_provider.dart';
import '../widgets/bug_metadata.dart';
import '../../verifications/providers/verification_provider.dart';
import '../../verifications/models/verification_models.dart';
import '../../verifications/widgets/verification_dialog.dart';
import '../../verifications/widgets/delete_verification_dialog.dart';

/// Displays one bug report and its read-only verification summary.
class BugDetailsScreen extends ConsumerWidget {
  final String bugId;

  const BugDetailsScreen({super.key, required this.bugId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bugState = ref.watch(bugDetailsProvider(bugId));

    return Scaffold(
      appBar: AppBar(title: const Text('Bug Details')),
      body: bugState.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(error: error.toString()),
        data: (bug) => _BugDetailsBody(bug: bug, bugId: bugId),
      ),
    );
  }
}

class _BugDetailsBody extends ConsumerWidget {
  final BugModel bug;
  final String bugId;

  const _BugDetailsBody({required this.bug, required this.bugId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(verificationSummaryProvider(bugId));
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(bug.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Reporter: ${bug.reporterUsername}'),
        const SizedBox(height: 6),
        BugMetadata(bug: bug),
        _ContentSection(title: 'Actual Behavior', content: bug.actualBehavior),
        _ContentSection(title: 'Expected Behavior', content: bug.expectedBehavior),
        if (bug.stepsToReproduce != null && bug.stepsToReproduce!.isNotEmpty)
          _ContentSection(title: 'Steps to Reproduce', content: bug.stepsToReproduce!),
        if (bug.deviceModel != null && bug.deviceModel!.isNotEmpty)
          _ContentSection(title: 'Device', content: bug.deviceModel!),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Developer Response', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('No developer response yet.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Community Verification Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        summaryState.when(
          loading: () => const LoadingIndicator(),
          error: (error, stackTrace) => ErrorBanner(error: error.toString()),
          data: (summary) => _VerificationSummary(
            summary: summary,
            bugId: bugId,
            isAuthenticated: isAuthenticated,
          ),
        ),
        const SizedBox(height: 20),
        _BugOwnerActions(bug: bug),
      ],
    );
  }
}

class _BugOwnerActions extends ConsumerWidget {
  final BugModel bug;

  const _BugOwnerActions({required this.bug});

  Future<void> _deleteBug(BuildContext context, WidgetRef ref) async {
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
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).currentUser;
    final isOwner = currentUser?.id == bug.createdBy;
    final isAdmin = currentUser?.role.toLowerCase() == 'admin';
    if (!isOwner && !isAdmin) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bug Owner Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => context.push('/bugs/${bug.id}/edit', extra: bug),
          child: const Text('Edit Bug'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _deleteBug(context, ref),
          child: const Text('Delete Bug'),
        ),
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  final String title;
  final String content;

  const _ContentSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }
}

class _VerificationSummary extends ConsumerWidget {
  final VerificationSummary summary;
  final String bugId;
  final bool isAuthenticated;

  const _VerificationSummary({
    required this.summary,
    required this.bugId,
    required this.isAuthenticated,
  });

  Future<void> _showEditor(BuildContext context, WidgetRef ref) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => VerificationDialog(bugId: bugId),
    );
    if (changed != true || !context.mounted) return;
    ref.invalidate(verificationSummaryProvider(bugId));
    ref.invalidate(verificationListProvider(bugId));
    ref.invalidate(myVerificationsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification added successfully.')),
    );
  }

  Future<void> _editOwnVerification(
    BuildContext context,
    WidgetRef ref,
    VerificationModel verification,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => VerificationDialog(
        bugId: bugId,
        initialVerification: verification,
      ),
    );
    if (changed != true || !context.mounted) return;
    _refreshVerificationProviders(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification updated successfully.')),
    );
  }

  Future<void> _deleteOwnVerification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDeleteVerificationDialog(context);
    if (!confirmed || !context.mounted) return;

    final deleted = await ref
        .read(verificationActionProvider.notifier)
        .delete(bugId);
    if (!deleted || !context.mounted) return;
    _refreshVerificationProviders(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification deleted successfully.')),
    );
  }

  void _refreshVerificationProviders(WidgetRef ref) {
    ref.invalidate(verificationSummaryProvider(bugId));
    ref.invalidate(verificationListProvider(bugId));
    ref.invalidate(myVerificationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownVerificationState = isAuthenticated
        ? ref.watch(verificationListProvider(bugId))
        : null;
    VerificationModel? ownVerification;
    if (ownVerificationState?.hasValue == true) {
      final currentUserId = ref.read(authProvider).currentUser?.id;
      for (final verification in ownVerificationState!.value!) {
        if (verification.userId == currentUserId) {
          ownVerification = verification;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _count('Still present', summary.present),
        _count('Fixed for me', summary.fixed),
        _count('Not present', summary.notPresent),
        const SizedBox(height: 12),
        if (isAuthenticated) ...[
          if (ownVerificationState?.isLoading == true)
            const LoadingIndicator()
          else if (ownVerificationState?.hasError == true)
            ErrorBanner(error: ownVerificationState!.error.toString())
          else if (ownVerification == null)
            ElevatedButton(
              onPressed: () => _showEditor(context, ref),
              child: const Text('Add Verification'),
            )
          else ...[
            ElevatedButton(
              onPressed: () => _editOwnVerification(context, ref, ownVerification!),
              child: const Text('Edit Verification'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _deleteOwnVerification(context, ref),
              child: const Text('Delete Verification'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.push('/bugs/$bugId/verifications'),
            child: const Text('View All Verifications'),
          ),
        ] else
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login to Add Verification'),
          ),
      ],
    );
  }

  Widget _count(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $count'),
    );
  }
}
