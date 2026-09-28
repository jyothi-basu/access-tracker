import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../applications/models/application_model.dart';
import '../models/bug_models.dart';

/// Reusable vertical form for creating and, later, editing bug reports.
class BugForm extends StatefulWidget {
  final ApplicationModel? initialApplication;
  final BugModel? initialBug;
  final Future<bool> Function(CreateBugRequest request) onSubmit;
  final bool isSubmitting;
  final String? errorMessage;
  final String submitLabel;

  const BugForm({
    super.key,
    this.initialApplication,
    this.initialBug,
    required this.onSubmit,
    this.isSubmitting = false,
    this.errorMessage,
    this.submitLabel = 'Submit Bug',
  });

  @override
  State<BugForm> createState() => _BugFormState();
}

class _BugFormState extends State<BugForm> {
  final _formKey = GlobalKey<FormState>();
  ApplicationModel? _application;

  final _versionController = TextEditingController();
  final _titleController = TextEditingController();
  final _actualBehaviorController = TextEditingController();
  final _expectedBehaviorController = TextEditingController();
  final _stepsController = TextEditingController();
  final _deviceController = TextEditingController();

  String? _platform;
  String? _severity;
  String? _screenReader;

  static const _platforms = <String, String>{
    'android': 'Android',
    'ios': 'iOS',
    'windows': 'Windows',
    'macos': 'macOS',
    'linux': 'Linux',
    'web': 'Web',
  };

  static const _severities = <String, String>{
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'critical': 'Critical',
  };

  static const _screenReaders = <String, String>{
    'nvda': 'NVDA',
    'talkback': 'TalkBack',
    'voiceover': 'VoiceOver',
    'jaws': 'JAWS',
    'narrator': 'Narrator',
    'orca': 'Orca',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    final bug = widget.initialBug;
    _application = widget.initialApplication ??
        (bug == null
            ? null
            : ApplicationModel.temporary(displayName: bug.applicationName));
    _versionController.text = bug?.appVersion ?? '';
    _titleController.text = bug?.title ?? '';
    _actualBehaviorController.text = bug?.actualBehavior ?? '';
    _expectedBehaviorController.text = bug?.expectedBehavior ?? '';
    _stepsController.text = bug?.stepsToReproduce ?? '';
    _deviceController.text = bug?.deviceModel ?? '';
    _platform = bug?.platform;
    _severity = bug?.severity;
    _screenReader = bug?.screenReader;
  }

  @override
  void dispose() {
    _versionController.dispose();
    _titleController.dispose();
    _actualBehaviorController.dispose();
    _expectedBehaviorController.dispose();
    _stepsController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _chooseApplication(FormFieldState<ApplicationModel> field) async {
    final selected = await context.push<ApplicationModel>('/application-picker');
    if (!mounted || selected == null) return;
    field.didChange(selected);
    setState(() => _application = selected);
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final submitted = await widget.onSubmit(
      CreateBugRequest(
        applicationName: _application!.displayName.trim(),
        platform: _platform!,
        appVersion: _versionController.text.trim(),
        title: _titleController.text.trim(),
        severity: _severity!,
        screenReader: _screenReader!,
        actualBehavior: _actualBehaviorController.text.trim(),
        expectedBehavior: _expectedBehaviorController.text.trim(),
        stepsToReproduce: _stepsController.text.trim().isEmpty
            ? null
            : _stepsController.text.trim(),
        deviceModel: _deviceController.text.trim().isEmpty
            ? null
            : _deviceController.text.trim(),
      ),
    );

    if (submitted && mounted) _clearForm();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _application = null;
      _platform = null;
      _severity = null;
      _screenReader = null;
      _versionController.clear();
      _titleController.clear();
      _actualBehaviorController.clear();
      _expectedBehaviorController.clear();
      _stepsController.clear();
      _deviceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialBug != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.errorMessage != null) ...[
            _ErrorMessage(message: widget.errorMessage!),
            const SizedBox(height: 16),
          ],
          FormField<ApplicationModel>(
            initialValue: _application,
            validator: (_) => _application == null ? 'Application is required.' : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Application'),
                const SizedBox(height: 8),
                if (isEditing)
                  InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_application?.displayName ?? ''),
                  )
                else
                  OutlinedButton(
                    onPressed: widget.isSubmitting
                        ? null
                        : () => _chooseApplication(field),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_application?.displayName ?? 'Select application'),
                    ),
                  ),
                if (field.hasError)
                  Text(
                    field.errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Platform',
            value: _platform,
            values: _platforms,
            validator: (value) => value == null ? 'Platform is required.' : null,
            onChanged: (value) => setState(() => _platform = value),
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _versionController,
            label: 'Application Version',
            validator: (value) => _requiredText(value, 'Application Version'),
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _titleController,
            label: 'Bug Title',
            validator: (value) => _requiredText(value, 'Bug Title'),
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Severity',
            value: _severity,
            values: _severities,
            validator: (value) => value == null ? 'Severity is required.' : null,
            onChanged: (value) => setState(() => _severity = value),
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: 'Screen Reader',
            value: _screenReader,
            values: _screenReaders,
            validator: (value) => value == null ? 'Screen Reader is required.' : null,
            onChanged: (value) => setState(() => _screenReader = value),
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _actualBehaviorController,
            label: 'Actual Behavior',
            maxLines: 4,
            validator: (value) => _requiredText(value, 'Actual Behavior'),
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _expectedBehaviorController,
            label: 'Expected Behavior',
            maxLines: 4,
            validator: (value) => _requiredText(value, 'Expected Behavior'),
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _stepsController,
            label: 'Steps to Reproduce (optional)',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          _textField(
            controller: _deviceController,
            label: 'Device (optional)',
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isSubmitting ? null : _submit,
              child: widget.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: maxLines > 1),
      validator: validator,
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required Map<String, String> values,
    required String? Function(String?) validator,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: values.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
      onChanged: widget.isSubmitting || widget.initialBug != null
          ? null
          : onChanged,
      validator: validator,
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}
