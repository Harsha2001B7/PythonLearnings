import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/di/locator.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/navigation/routes.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with AutomaticKeepAliveClientMixin {
  final Set<String> _selectedIndustries = {
    'Hollywood',
    'Bollywood',
    'Tollywood (Telugu)',
  };
  final Set<String> _selectedGenres = {'Action', 'Sci-Fi', 'Thriller'};

  final Map<String, bool> _notifications = {
    'Upcoming Releases': true,
    'Favorite Actors': false,
    'Favorite Directors': false,
    'OTT Releases': true,
    'Trending Trailers': true,
    'Personalized Recommendations': true,
  };

  final List<String> _industries = [
    'Hollywood',
    'Bollywood',
    'Korean Cinema',
    'Tollywood (Telugu)',
    'Tamil Cinema',
    'Malayalam',
    'Kannada',
    'Marathi',
    'Odia',
    'Bengali',
    'Punjabi',
    'Spanish / Latin',
    'Arabic Cinema',
    'Gulf TV',
    'Japanese Cinema',
    'European Cinema',
  ];

  final List<String> _genres = [
    'Action',
    'Drama',
    'Horror',
    'Sci-Fi',
    'Romance',
    'Comedy',
    'Thriller',
    'Animation',
    'Documentary',
    'Fantasy',
    'Crime',
    'Musical',
    'Adventure',
    'Mystery',
  ];

  void _toggleIndustry(String industry) {
    setState(() {
      if (_selectedIndustries.contains(industry)) {
        _selectedIndustries.remove(industry);
      } else {
        _selectedIndustries.add(industry);
      }
    });
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _toggleNotification(String key, bool value) {
    setState(() {
      _notifications[key] = value;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tune TrailerBaaz for you',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pick industries, genres, and notifications — saved to your account when signed in.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => locator<NavigationService>().setShellTab(
                      context,
                      ShellTab.home,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.75, 0.88, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SectionHeader(title: 'INDUSTRIES'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _industries
                          .map(
                            (ind) => _SelectableChip(
                              label: ind,
                              isSelected: _selectedIndustries.contains(ind),
                              onTap: () => _toggleIndustry(ind),
                              showLiveIndicator: [
                                'Hollywood',
                                'Bollywood',
                                'Korean Cinema',
                                'Tollywood (Telugu)',
                                'Tamil Cinema',
                              ].contains(ind),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    if (_selectedIndustries.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'HOME INDUSTRY',
                        subtitle:
                            'Tap to set your default feed. Use × to remove.',
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _selectedIndustries
                            .map(
                              (ind) => _RemovableChip(
                                label: ind,
                                onRemove: () => _toggleIndustry(ind),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    _SectionHeader(title: 'GENRES'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _genres
                          .map(
                            (gen) => _SelectableChip(
                              label: gen,
                              isSelected: _selectedGenres.contains(gen),
                              onTap: () => _toggleGenre(gen),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    _SectionHeader(title: 'NOTIFICATIONS'),
                    ..._notifications.entries.map(
                      (entry) => _NotificationSwitch(
                        label: entry.key,
                        value: entry.value,
                        onChanged: (val) => _toggleNotification(entry.key, val),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 118,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Sticky Area
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .05),
                        Colors.black.withValues(alpha: .75),
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => locator<NavigationService>().setShellTab(
                      context,
                      ShellTab.home,
                    ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => locator<NavigationService>().setShellTab(
                      context,
                      ShellTab.home,
                    ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Continue Browsing',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLiveIndicator;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showLiveIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (showLiveIndicator) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· live',
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.accent.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.close, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.accent,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: const Color(0xFF1E1E1E),
          ),
        ],
      ),
    );
  }
}
