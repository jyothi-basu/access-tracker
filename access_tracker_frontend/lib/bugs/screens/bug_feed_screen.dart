import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../models/bug_models.dart';
import '../providers/bug_provider.dart';
import '../widgets/bug_card.dart';

/// Displays searchable and filterable accessibility bug reports.
class BugFeedScreen extends ConsumerStatefulWidget {
  final bool guestMode;
  final String? applicationName;

  const BugFeedScreen({
    super.key,
    this.guestMode = false,
    this.applicationName,
  });

  @override
  ConsumerState<BugFeedScreen> createState() => _BugFeedScreenState();
}

class _BugFeedScreenState extends ConsumerState<BugFeedScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.applicationName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(bugFeedProvider.notifier)
              .setApplicationName(widget.applicationName!);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilters(BugFeedState currentState) async {
    var platform = currentState.filters.platform;
    final applicationName = currentState.filters.applicationName;
    var screenReader = currentState.filters.screenReader;
    var severity = currentState.filters.severity;
    var sortOrder = currentState.filters.sortOrder;

    final selectedFilters = await showModalBottomSheet<BugFeedFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter Bug Reports', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: platform,
                      decoration: const InputDecoration(labelText: 'Platform'),
                      items: _options(_platforms),
                      onChanged: (value) => setSheetState(() => platform = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: screenReader,
                      decoration: const InputDecoration(labelText: 'Screen Reader'),
                      items: _options(_screenReaders),
                      onChanged: (value) => setSheetState(() => screenReader = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: severity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: _options(_severities),
                      onChanged: (value) => setSheetState(() => severity = value),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sort'),
                    RadioListTile<BugSortOrder>(
                      title: const Text('Newest'),
                      value: BugSortOrder.newest,
                      groupValue: sortOrder,
                      onChanged: (value) => setSheetState(() => sortOrder = value!),
                    ),
                    RadioListTile<BugSortOrder>(
                      title: const Text('Oldest'),
                      value: BugSortOrder.oldest,
                      groupValue: sortOrder,
                      onChanged: (value) => setSheetState(() => sortOrder = value!),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(
                          BugFeedFilters(
                            applicationName: applicationName,
                            platform: platform,
                            screenReader: screenReader,
                            severity: severity,
                            sortOrder: sortOrder,
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(
                        BugFeedFilters(applicationName: applicationName),
                      ),
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedFilters != null && mounted) {
      await ref.read(bugFeedProvider.notifier).setFilters(selectedFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(bugFeedProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.guestMode) ...[
          Text('Browse Bug Reports', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Explore accessibility issues reported by the community.'),
          const SizedBox(height: 20),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Search bug reports',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) => ref.read(bugFeedProvider.notifier).setSearch(value),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: 'Open bug report filters',
              button: true,
              child: IconButton(
                tooltip: 'Filter bug reports',
                onPressed: () => _showFilters(feedState),
                icon: const Icon(Icons.filter_list),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (feedState.isLoading) const LoadingIndicator(),
        if (feedState.errorMessage != null) ErrorBanner(error: feedState.errorMessage!),
        if (!feedState.isLoading && feedState.errorMessage == null && feedState.bugs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No bug reports found.')),
          ),
        ...feedState.bugs.map(
          (bug) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BugCard(
              bug: bug,
              onViewDetails: () => context.push('/bugs/${bug.id}'),
            ),
          ),
        ),
      ],
    );
  }

  static List<DropdownMenuItem<String>> _options(Map<String, String> values) {
    return values.entries
        .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
        .toList();
  }
}

const _platforms = {
  'android': 'Android',
  'ios': 'iOS',
  'windows': 'Windows',
  'macos': 'macOS',
  'linux': 'Linux',
  'web': 'Web',
};

const _screenReaders = {
  'nvda': 'NVDA',
  'talkback': 'TalkBack',
  'voiceover': 'VoiceOver',
  'jaws': 'JAWS',
  'narrator': 'Narrator',
  'orca': 'Orca',
  'other': 'Other',
};

const _severities = {
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
  'critical': 'Critical',
};
