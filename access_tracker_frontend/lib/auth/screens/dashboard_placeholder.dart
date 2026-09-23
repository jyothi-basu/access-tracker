import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';

class DashboardPlaceholder extends ConsumerWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Center(
        child: Column(
          children: [
            if (user != null) ...[
              Text("Welcome, ${user.name}"),
              Text("Email: ${user.email}"),
              Text("Role: ${user.role}"),
            ],
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
