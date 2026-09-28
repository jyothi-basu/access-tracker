import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_error_handler.dart';
import '../models/bug_models.dart';
import '../services/bug_service.dart';
import 'bug_provider.dart';

/// Submission state for the create bug form.
class CreateBugState {
  final bool isSubmitting;
  final String? errorMessage;

  const CreateBugState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  CreateBugState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateBugState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final createBugProvider =
    StateNotifierProvider.autoDispose<CreateBugNotifier, CreateBugState>((ref) {
  return CreateBugNotifier(ref.watch(bugServiceProvider));
});

/// Submits bug reports while keeping network concerns out of the form UI.
class CreateBugNotifier extends StateNotifier<CreateBugState> {
  final BugService _service;

  CreateBugNotifier(this._service) : super(const CreateBugState());

  /// Returns true only when the backend accepts the report.
  Future<bool> submit(CreateBugRequest request) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _service.createBug(request);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: ApiErrorHandler.handle(error),
      );
      return false;
    }
  }
}
