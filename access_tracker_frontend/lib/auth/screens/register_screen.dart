import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 16),
              TextFormField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final registered = await ref.read(authProvider.notifier).register(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (registered && context.mounted) {
                      context.push('/verify-email', extra: _emailController.text.trim());
                    }
                  }
                },
                text: "Send Verification Code",
                isLoading: authState.isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
