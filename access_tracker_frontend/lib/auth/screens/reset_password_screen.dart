import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class ResetPasswordScreen extends ConsumerWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
            TextFormField(controller: passwordController, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            const SizedBox(height: 16),
            TextFormField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }
                await ref.read(authProvider.notifier).resetPassword(resetToken, passwordController.text);
                if (context.mounted && ref.read(authProvider).errorMessage == null) {
                  context.go('/login');
                }
              },
              text: "Reset Password",
              isLoading: authState.isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
