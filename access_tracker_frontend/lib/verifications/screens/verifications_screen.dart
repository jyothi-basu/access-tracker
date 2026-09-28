import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/provider/auth_provider.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/verification_models.dart';
import '../providers/verification_provider.dart';
import '../widgets/verification_dialog.dart';
import '../widgets/verification_tile.dart';
import '../widgets/delete_verification_dialog.dart';

/// Displays every community verification for a bug.
class VerificationsScreen extends ConsumerWidget {
  final String bugId;

  const VerificationsScreen({super.key, required this.bugId});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(verificationListProvider(bugId));
    ref.invalidate(verificationSummaryProvider(bugId));
    ref.invalidate(myVerificationsProvider);
  }

  Future<void> _showEditor(BuildContext context, WidgetRef ref, [
    VerificationModel? verification,
  ]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => VerificationDialog(
        bugId: bugId,
        initialVerification: verification,
      ),
    );
    if (changed != true || !context.mounted) return;
    await _refresh(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verification == null
              ? 'Verification added successfully.'
              : 'Verification updated successfully.',
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    VerificationModel verification,
  ) async {
    final confirmed = await showDeleteVerificationDialog(context);
    if (!confirmed || !context.mounted) return;

    final deleted = await ref
        .read(verificationActionProvider.notifier)
        .delete(bugId);
    if (!deleted || !context.mounted) return;
    await _refresh(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(verificationListProvider(bugId));
    final userId = ref.watch(authProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('All Verifications')),
      body: listState.when(
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorBanner(error: error.toString()),
        data: (verifications) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (userId != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showEditor(context, ref),
                  child: const Text('Add Verification'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (verifications.isEmpty)
              const Text('No verifications yet.')
            else
              ...verifications.map(
                (verification) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: VerificationTile(
                    verification: verification,
                    isOwner: userId != null && userId == verification.userId,
                    onEdit: () => _showEditor(context, ref, verification),
                    onDelete: () => _delete(context, ref, verification),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
