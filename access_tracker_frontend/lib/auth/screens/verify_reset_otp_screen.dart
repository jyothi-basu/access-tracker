import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class VerifyResetOtpScreen extends ConsumerWidget {
  final String email;

  const VerifyResetOtpScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = TextEditingController();
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
            Text("Verification code sent to: $email"),
            TextFormField(controller: otpController, decoration: const InputDecoration(labelText: "OTP")),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                final resetToken = await ref.read(authProvider.notifier).verifyPasswordResetOtp(
                  email,
                  otpController.text.trim(),
                );
                if (resetToken != null && context.mounted) {
                  context.push('/forgot-password/reset', extra: resetToken);
                }
              },
              text: "Verify OTP",
              isLoading: authState.isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
