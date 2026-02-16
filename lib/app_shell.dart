import 'package:flutter/material.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/features/list/list_screen.dart';
import 'package:to_do_flutter_app/features/pulse/pulse_screen.dart';

/// Two-pillar layout: List, Pulse.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    ListScreen(),
    PulseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_rounded),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Pulse',
          ),
        ],
      ),
    );
  }
}
