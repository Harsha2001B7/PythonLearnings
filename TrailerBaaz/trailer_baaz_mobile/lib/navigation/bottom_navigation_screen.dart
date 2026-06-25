import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/config/youtube_api_config.dart';
import '../core/theme/app_colors.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/home/data/mock/home_dummy_data.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/reels/data/mock/reels_dummy_data.dart';
import '../features/reels/presentation/screens/reels_screen.dart';
import '../features/saved/presentation/screens/saved_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const ReelsScreen(),
    const SearchScreen(),
    const CalendarScreen(),
    const SavedScreen(),
    const SettingsScreen()
  ];

  static const _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.movie_outlined),
      activeIcon: Icon(Icons.movie_rounded),
      label: 'Reels',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      activeIcon: Icon(Icons.calendar_month_rounded),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border_rounded),
      activeIcon: Icon(Icons.bookmark_rounded),
      label: 'Saved',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),    
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_warmCache());
  }

  Future<void> _warmCache() async {
    await Future.wait([
      if (HomeDummyData.trailers.isEmpty)
        HomeDummyData.preload(apiKey: YoutubeApiConfig.apiKey),
      if (ReelsDummyData.reels.isEmpty)
        ReelsDummyData.preload(apiKey: YoutubeApiConfig.apiKey),
    ]);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (_currentIndex == index) return;
                    setState(() => _currentIndex = index);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconSize: 22,
                  selectedItemColor: AppColors.amber,
                  unselectedItemColor: AppColors.textGrey.withValues(
                    alpha: 0.82,
                  ),
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  enableFeedback: true,
                  items: _items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
