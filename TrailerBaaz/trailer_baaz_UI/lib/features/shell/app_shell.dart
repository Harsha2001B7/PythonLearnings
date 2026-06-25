import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../discover/discover_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../preferences/preferences_screen.dart';
import '../search/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  static void setIndex(BuildContext context, int index) {
    context.findAncestorStateOfType<_AppShellState>()?.setIndex(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    SearchScreen(),
    PreferencesScreen(),
    ProfileScreen(),
  ];
  void setIndex(int index) {
    setState(() {
      _index = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 0, 28, 16),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: const Color(0xDD121212),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .45),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavIcon(
                icon: Icons.explore_outlined,
                label: 'Discover',
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavIcon(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavIcon(
                icon: Icons.tune_rounded,
                label: 'Preferences',
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: selected ? 54 : 46,
          height: 46,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: selected ? AppTheme.background : AppTheme.muted,
            size: 25,
          ),
        ),
      ),
    );
  }
}
