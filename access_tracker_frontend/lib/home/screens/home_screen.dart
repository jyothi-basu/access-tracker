import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bugs/screens/bug_feed_screen.dart';
import '../../bugs/screens/create_bug_screen.dart';
import '../../developers/screens/developer_dashboard_screen.dart';
import '../../developers/providers/developer_provider.dart';
import 'profile_screen.dart';

/// Authenticated application shell with persistent top-level tabs.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Home', 'Report Bug', 'Developer', 'Profile'];

  void _selectTab(int index) {
    if (index == 2) {
      ref.invalidate(developerApplicationsProvider);
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const BugFeedScreen(),
          CreateBugScreen(
            onBugCreated: () => setState(() => _selectedIndex = 0),
          ),
          DeveloperDashboardScreen(isActive: _selectedIndex == 2),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Report Bug',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            label: 'Developer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
