import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
            Text("We sent a 6-digit verification code to: ${widget.email}"),
            const SizedBox(height: 16),
            TextFormField(controller: _otpController, decoration: const InputDecoration(labelText: "OTP")),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                final verified = await ref.read(authProvider.notifier).verifyRegistrationOtp(
                  widget.email,
                  _otpController.text.trim(),
                );
                if (verified && context.mounted) {
                  context.go('/login');
                }
              },
              text: "Verify Email",
              isLoading: authState.isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
