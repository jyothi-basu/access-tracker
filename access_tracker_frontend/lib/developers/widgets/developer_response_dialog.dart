import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/error_banner.dart';
import '../models/developer_models.dart';
import '../providers/developer_provider.dart';

/// Dialog used to create or edit a developer response.
class DeveloperResponseDialog extends ConsumerStatefulWidget {
  final String bugId;
  final DeveloperResponse? initialResponse;

  const DeveloperResponseDialog({
    super.key,
    required this.bugId,
    this.initialResponse,
  });

  @override
  ConsumerState<DeveloperResponseDialog> createState() =>
      _DeveloperResponseDialogState();
}

class _DeveloperResponseDialogState
    extends ConsumerState<DeveloperResponseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _responseController =
      TextEditingController(text: widget.initialResponse?.response ?? '');

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = DeveloperResponseRequest(
      response: _responseController.text.trim(),
    );
    final notifier = ref.read(developerResponseActionProvider.notifier);
    final saved = widget.initialResponse == null
        ? await notifier.create(widget.bugId, request)
        : await notifier.update(widget.initialResponse!.id, request);

    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(developerResponseActionProvider);
    final isEditing = widget.initialResponse != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Developer Response' : 'Respond to Bug'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (actionState.errorMessage != null) ...[
                ErrorBanner(error: actionState.errorMessage!),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _responseController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Response',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Response is required.'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actionState.isLoading ? null : _save,
                  child: actionState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Save Changes' : 'Submit Response'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: actionState.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
