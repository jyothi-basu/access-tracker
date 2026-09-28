import 'package:flutter/material.dart';
import '../models/application_model.dart';

/// Full-width, keyboard- and screen-reader-friendly application result tile.
class ApplicationTile extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onSelected;

  const ApplicationTile({
    super.key,
    required this.application,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(application.displayName),
        onTap: onSelected,
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
