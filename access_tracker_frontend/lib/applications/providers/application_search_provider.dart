import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

final applicationServiceProvider = Provider<ApplicationService>((ref) {
  return ApplicationService(ref.watch(apiClientProvider));
});

/// Provides the applications available in the bug-feed filter.
final applicationListProvider = FutureProvider.autoDispose<List<ApplicationModel>>((ref) {
  return ref.watch(applicationServiceProvider).fetchAllApplications();
});

class ApplicationSearchState {
  final String query;
  final List<ApplicationModel> results;
  final bool isLoading;
  final String? errorMessage;

  const ApplicationSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ApplicationSearchState copyWith({
    String? query,
    List<ApplicationModel>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApplicationSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final applicationSearchProvider = StateNotifierProvider.autoDispose<
    ApplicationSearchNotifier, ApplicationSearchState>((ref) {
  return ApplicationSearchNotifier(ref.watch(applicationServiceProvider));
});

class ApplicationSearchNotifier extends StateNotifier<ApplicationSearchState> {
  static const _minimumSearchLength = 3;
  static const _debounceDuration = Duration(milliseconds: 300);

  final ApplicationService _service;
  Timer? _debounceTimer;
  int _requestSequence = 0;

  ApplicationSearchNotifier(this._service) : super(const ApplicationSearchState());

  /// Updates the query and schedules a debounced backend search when eligible.
  void setQuery(String value) {
    final query = value.trim();
    _debounceTimer?.cancel();
    _requestSequence++;

    state = state.copyWith(
      query: value,
      results: const [],
      isLoading: false,
      clearError: true,
    );

    if (query.length < _minimumSearchLength) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final requestSequence = _requestSequence;
    _debounceTimer = Timer(_debounceDuration, () {
      _search(query, requestSequence);
    });
  }

  Future<void> _search(String query, int requestSequence) async {
    try {
      final results = await _service.searchApplications(query);
      if (requestSequence != _requestSequence || !mounted) return;

      state = state.copyWith(results: results, isLoading: false);
    } on ApplicationServiceException catch (error) {
      if (requestSequence != _requestSequence || !mounted) return;

      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
