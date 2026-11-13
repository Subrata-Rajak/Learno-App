import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/features/home/presentation/widgets/learno_bottom_nav.dart';

/// Application shell hosting the primary navigation destinations with
/// an [IndexedStack] and the persistent [LearnoBottomNav].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: LearnoBottomNav(
        currentIndex: navigationShell.currentIndex,
        onItemSelected: _onTabSelected,
      ),
    );
  }
}

