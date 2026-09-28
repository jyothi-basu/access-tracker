import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/application_model.dart';
import '../providers/application_search_provider.dart';
import '../widgets/application_tile.dart';

/// Dedicated searchable screen for selecting an existing application.
class ApplicationPickerScreen extends ConsumerStatefulWidget {
  const ApplicationPickerScreen({super.key});

  @override
  ConsumerState<ApplicationPickerScreen> createState() => _ApplicationPickerScreenState();
}

class _ApplicationPickerScreenState extends ConsumerState<ApplicationPickerScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _select(ApplicationModel application) {
    Navigator.of(context).pop(application);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(applicationSearchProvider);
    final query = searchState.query.trim();
    final showTemporaryOption = query.length >= 3 &&
        !searchState.isLoading &&
        searchState.errorMessage == null &&
        searchState.results.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Application')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Search Application', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Application name',
              hintText: 'Type at least 3 characters',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: ref.read(applicationSearchProvider.notifier).setQuery,
          ),
          const SizedBox(height: 20),
          if (searchState.isLoading) const LoadingIndicator(),
          if (searchState.errorMessage != null)
            ErrorBanner(error: searchState.errorMessage!),
          if (!searchState.isLoading && searchState.errorMessage == null && query.length < 3)
            const Text('Enter at least 3 characters to search.'),
          if (showTemporaryOption) ...[
            const Text('No matching application found.'),
            const SizedBox(height: 12),
            ApplicationTile(
              application: ApplicationModel.temporary(displayName: query),
              onSelected: () => _select(ApplicationModel.temporary(displayName: query)),
            ),
          ],
          ...searchState.results.map(
            (application) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ApplicationTile(
                application: application,
                onSelected: () => _select(application),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
