import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfx_fuhrpark/src/utils/extensions.dart';


class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar(this.navigationShell, {super.key});

  /// The navigation shell and container for the branch Navigators
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        indicatorColor: context.colorTheme.secondary,
        backgroundColor: Colors.white,
        elevation: 1.0,
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Karte',
            selectedIcon: Icon(Icons.map),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profil',
            selectedIcon: Icon(Icons.person),
          )
        ],
        onDestinationSelected: _onTap,
      ),
    );
  }

  void _onTap(index) {
    navigationShell.goBranch(
      index,
      // to support navigating to the initial location when tapping the item
      // that is already active
      initialLocation: true,
    );
  }
}