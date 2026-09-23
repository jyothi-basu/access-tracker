import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/error_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (authState.errorMessage != null) ErrorBanner(error: authState.errorMessage!),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final loginSucceeded = await ref.read(authProvider.notifier).login(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (loginSucceeded && context.mounted) {
                      context.go('/dashboard');
                    }
                  }
                },
                text: "Login",
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
