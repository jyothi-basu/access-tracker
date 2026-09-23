import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String error;

  const ErrorBanner({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
