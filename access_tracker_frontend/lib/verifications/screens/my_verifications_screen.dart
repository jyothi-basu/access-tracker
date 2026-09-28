import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/verification_models.dart';
import '../providers/verification_provider.dart';
import '../widgets/delete_verification_dialog.dart';
import '../widgets/verification_dialog.dart';
import '../widgets/verification_tile.dart';

/// Lists verifications created by the authenticated user.
class MyVerificationsScreen extends ConsumerWidget {
  const MyVerificationsScreen({super.key});

  Future<void> _refresh(WidgetRef ref, String bugId) async {
    ref.invalidate(myVerificationsProvider);
    ref.invalidate(verificationSummaryProvider(bugId));
    ref.invalidate(verificationListProvider(bugId));
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String bugId,
    MyVerificationItem item,
  ) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => VerificationDialog(
        bugId: bugId,
        initialVerification: item.verification,
      ),
    );
    if (changed != true || !context.mounted) return;
    await _refresh(ref, bugId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification updated successfully.')),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String bugId) async {
    final confirmed = await showDeleteVerificationDialog(context);
    if (!confirmed || !context.mounted) return;

    final deleted = await ref
        .read(verificationActionProvider.notifier)
        .delete(bugId);
    if (!deleted || !context.mounted) return;
    await _refresh(ref, bugId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myVerificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Verifications')),
      body: state.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(error: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('You have not submitted any verifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final item = items[index];
              final verification = item.verification;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VerificationTile(
                    verification: verification,
                    applicationName: item.applicationName,
                    bugTitle: item.bugTitle,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/bugs/${verification.bugId}'),
                    child: const Text('Open Bug'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _edit(
                      context,
                      ref,
                      verification.bugId,
                      item,
                    ),
                    child: const Text('Edit Verification'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _delete(context, ref, verification.bugId),
                    child: const Text('Delete Verification'),
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
