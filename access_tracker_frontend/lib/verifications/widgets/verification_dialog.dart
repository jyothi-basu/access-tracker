import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/error_banner.dart';
import '../models/verification_models.dart';
import '../providers/verification_provider.dart';

/// Dialog used for both creating and editing a verification.
class VerificationDialog extends ConsumerStatefulWidget {
  final String bugId;
  final VerificationModel? initialVerification;

  const VerificationDialog({
    super.key,
    required this.bugId,
    this.initialVerification,
  });

  @override
  ConsumerState<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends ConsumerState<VerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late VerificationType? _verificationType =
      widget.initialVerification?.verificationType;
  late final TextEditingController _versionController = TextEditingController(
    text: widget.initialVerification?.appVersion ?? '',
  );
  late final TextEditingController _deviceController = TextEditingController(
    text: widget.initialVerification?.deviceModel ?? '',
  );

  @override
  void dispose() {
    _versionController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = VerificationRequest(
      verificationType: _verificationType!,
      appVersion: _versionController.text.trim(),
      deviceModel: _deviceController.text.trim().isEmpty
          ? null
          : _deviceController.text.trim(),
    );
    final notifier = ref.read(verificationActionProvider.notifier);
    final saved = widget.initialVerification == null
        ? await notifier.create(widget.bugId, request)
        : await notifier.update(widget.bugId, request);

    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(verificationActionProvider);
    final isEditing = widget.initialVerification != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Verification' : 'Add Verification'),
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
              DropdownButtonFormField<VerificationType>(
                value: _verificationType,
                decoration: const InputDecoration(labelText: 'Verification Type'),
                items: VerificationType.values
                    .map(
                      (type) => DropdownMenuItem<VerificationType>(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: actionState.isLoading
                    ? null
                    : (value) => setState(() => _verificationType = value),
                validator: (value) =>
                    value == null ? 'Verification Type is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: 'Application Version',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Application Version is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceController,
                decoration: const InputDecoration(labelText: 'Device (optional)'),
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
                      : Text(isEditing ? 'Save Changes' : 'Save Verification'),
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
