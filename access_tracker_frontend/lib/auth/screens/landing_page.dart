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
            PrimaryButton(onPressed: () {}, text: "Browse Applications", isFullWidth: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: PrimaryButton(onPressed: () => context.push('/login'), text: "Login")),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton(onPressed: () => context.push('/register'), child: const Text("Create Account"))),
              ],
            ),
            const SizedBox(height: 48),
            // Add feature cards and recent reports section placeholder
          ],
        ),
      ),
    );
  }
}
