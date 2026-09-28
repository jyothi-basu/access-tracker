import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/primary_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("AccessTracker", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Community-driven Accessibility Issue Tracker"),
            const SizedBox(height: 16),
            const Text("Discover accessibility issues before installing an app, report new issues, and help the community verify whether accessibility problems still exist."),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => context.push('/bugs'),
              text: "Browse Bug Reports",
              isFullWidth: true,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => context.push('/login'),
              text: "Login",
              isFullWidth: true,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => context.push('/register'),
              text: "Create Account",
              isFullWidth: true,
            ),
            const SizedBox(height: 48),
            // Add feature cards and recent reports section placeholder
          ],
        ),
      ),
    );
  }
}
