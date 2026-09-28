import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';

/// Displays the authenticated user's profile and account actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;

    if (user == null) {
      return const Center(child: Text('Profile is unavailable.'));
    }

    final role = user.role.isEmpty
        ? 'User'
        : '${user.role[0].toUpperCase()}${user.role.substring(1)}';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text('Email: ${user.email}'),
        const SizedBox(height: 8),
        Text('Role: $role'),
        const SizedBox(height: 28),
        PrimaryButton(
          onPressed: () => context.push('/my-bugs'),
          text: 'My Bugs',
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: () => context.push('/my-verifications'),
          text: 'My Verifications',
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go('/');
            }
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
