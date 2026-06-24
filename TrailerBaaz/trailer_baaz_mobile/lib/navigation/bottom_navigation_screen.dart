import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/reels/presentation/screens/reels_screen.dart';
import '../features/saved/presentation/screens/saved_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    ReelsScreen(),
    SearchScreen(),
    CalendarScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(Icons.movie_filter_outlined, Icons.movie_filter, 'Reels'),
    _NavItem(Icons.search_outlined, Icons.search, 'Search'),
    _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Calendar'),
    _NavItem(Icons.favorite_border, Icons.favorite, 'Saved'),
    _NavItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 88,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.background]),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                  child: Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final active = index == _currentIndex;
                      return Expanded(
                        child: _NavButton(
                          item: item,
                          active: active,
                          onTap: () => setState(() => _currentIndex = index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.active, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.active ? AppColors.primaryRed : AppColors.textMuted;
    final labelColor = widget.active ? AppColors.amber : AppColors.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.active ? 22 : 0,
              height: 4,
              decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(height: 7),
            Icon(widget.active ? widget.item.activeIcon : widget.item.icon, color: iconColor, size: 23),
            const SizedBox(height: 4),
            Text(widget.item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: labelColor, fontSize: 11, fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
