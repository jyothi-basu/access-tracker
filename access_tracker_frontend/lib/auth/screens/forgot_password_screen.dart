import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).requestPasswordResetOtp(_emailController.text.trim());
                if (context.mounted && ref.read(authProvider).errorMessage == null) {
                  context.push('/forgot-password/verify', extra: _emailController.text.trim());
                }
              },
              text: "Send OTP",
              isLoading: authState.isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
