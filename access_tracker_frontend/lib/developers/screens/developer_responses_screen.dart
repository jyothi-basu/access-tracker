import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';
import '../../core/network/api_error_handler.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/developer_models.dart';
import '../providers/developer_provider.dart';
import '../widgets/delete_developer_response_dialog.dart';
import '../widgets/developer_response_dialog.dart';
import '../widgets/developer_response_tile.dart';

/// Displays every response created by the authenticated developer.
class MyDeveloperResponsesScreen extends ConsumerWidget {
  const MyDeveloperResponsesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsesState = ref.watch(developerMyResponsesProvider);
    final currentUserId = ref.watch(authProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('My Developer Responses')),
      body: responsesState.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(
          error: ApiErrorHandler.handle(error),
        ),
        data: (responses) {
          if (responses.isEmpty) {
            return const Center(
              child: Text('You have not submitted any developer responses yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: responses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final response = responses[index];
              return DeveloperResponseTile(
                response: response,
                isOwner: response.developerId == currentUserId,
                showOpenBug: true,
                onOpenBug: () => context.push('/bugs/${response.bugId}'),
                onEdit: () => _editResponse(context, ref, response),
                onDelete: () => _deleteResponse(context, ref, response),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editResponse(
    BuildContext context,
    WidgetRef ref,
    DeveloperResponse response,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => DeveloperResponseDialog(
        bugId: response.bugId,
        initialResponse: response,
      ),
    );
    if (changed != true || !context.mounted) return;
    ref.invalidate(developerMyResponsesProvider);
    ref.invalidate(developerResponsesForBugProvider(response.bugId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Developer response updated successfully.')),
    );
  }

  Future<void> _deleteResponse(
    BuildContext context,
    WidgetRef ref,
    DeveloperResponse response,
  ) async {
    final confirmed = await showDeleteDeveloperResponseDialog(context);
    if (!confirmed || !context.mounted) return;

    final deleted = await ref
        .read(developerResponseActionProvider.notifier)
        .delete(response.id);
    if (!deleted || !context.mounted) return;

    ref.invalidate(developerMyResponsesProvider);
    ref.invalidate(developerResponsesForBugProvider(response.bugId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Developer response deleted successfully.')),
    );
  }
}

/// Displays all developer responses associated with one bug.
class DeveloperResponsesForBugScreen extends ConsumerWidget {
  final String bugId;

  const DeveloperResponsesForBugScreen({
    super.key,
    required this.bugId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsesState = ref.watch(developerResponsesForBugProvider(bugId));
    final currentUserId = ref.watch(authProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Developer Responses')),
      body: responsesState.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(
          error: ApiErrorHandler.handle(error),
        ),
        data: (responses) {
          if (responses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No developer responses yet.\n\nDevelopers representing this application haven\'t responded to this bug yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: responses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final response = responses[index];
              return DeveloperResponseTile(
                response: response,
                isOwner: response.developerId == currentUserId,
                onEdit: () => _editResponse(context, ref, response),
                onDelete: () => _deleteResponse(context, ref, response),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editResponse(
    BuildContext context,
    WidgetRef ref,
    DeveloperResponse response,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => DeveloperResponseDialog(
        bugId: bugId,
        initialResponse: response,
      ),
    );
    if (changed != true || !context.mounted) return;
    _refresh(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Developer response updated successfully.')),
    );
  }

  Future<void> _deleteResponse(
    BuildContext context,
    WidgetRef ref,
    DeveloperResponse response,
  ) async {
    final confirmed = await showDeleteDeveloperResponseDialog(context);
    if (!confirmed || !context.mounted) return;

    final deleted = await ref
        .read(developerResponseActionProvider.notifier)
        .delete(response.id);
    if (!deleted || !context.mounted) return;
    _refresh(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Developer response deleted successfully.')),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(developerResponsesForBugProvider(bugId));
    ref.invalidate(developerMyResponsesProvider);
  }
}
