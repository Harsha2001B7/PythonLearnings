import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/home_experience_provider.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/trailer_card.dart';
import '../../shared/widgets/trailer_player.dart';
import '../details/trailer_details_screen.dart';
import '../splash/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: YoutubeTrailersProvider.instance,
      builder: (context, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 18,
                20,
                110,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _ProfileHeader(),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      _ProfileStat(value: '142', label: 'Trailers Hyped'),
                      SizedBox(width: 10),
                      _ProfileStat(value: '38', label: 'Bookmarks'),
                      SizedBox(width: 10),
                      _ProfileStat(value: '219', label: 'Watch History'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _PreferencePanel(),
                  const SizedBox(height: 26),
                  const _SectionHeader('Watchlist'),
                  const SizedBox(height: 14),
                  _ProfileRail(start: 0),
                  const SizedBox(height: 26),
                  const _SectionHeader('Liked Trailers'),
                  const SizedBox(height: 14),
                  _ProfileRail(start: 2),
                  const SizedBox(height: 26),
                  const _SectionHeader('Recently Viewed'),
                  const SizedBox(height: 14),
                  _ProfileRail(start: 1),
                  const SizedBox(height: 26),
                  const _SettingsPanel(),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF201314), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: CinematicImage(
                    url:
                        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=300&q=80',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Renu Kumar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '@trailerhunter',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sci-fi loyalist, first-day trailer watcher, and professional hype curator.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge('Day One Fan'),
              _Badge('Top 1% Hype'),
              _Badge('OTT Scout'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  const _PreferencePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Favorites'),
          SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge('Sci-Fi'),
              _Badge('Thriller'),
              _Badge('Hindi'),
              _Badge('Telugu'),
              _Badge('Korean'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRail extends StatelessWidget {
  const _ProfileRail({required this.start});

  final int start;

  @override
  Widget build(BuildContext context) {
    final allTrailers = YoutubeTrailersProvider.instance.allTrailers;
    if (allTrailers.isEmpty) return const SizedBox();

    final items = List.generate(
      3,
      (index) => allTrailers[(start + index) % allTrailers.length],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = MediaQuery.sizeOf(context).width * 0.74;
        final imageH = cardWidth * (9 / 16);
        return SizedBox(
          height: imageH + kCardTextSectionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => TrailerCard(
              trailer: items[index],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrailerDetailsScreen(trailer: items[index]),
                ),
              ),
              onPlay: () => showTrailerPlayer(context, items[index]),
              width: cardWidth,
              height: imageH,
            ),
          ),
        );
      },
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.contrast_rounded, 'Appearance'),
      (Icons.notifications_none_rounded, 'Notifications'),
      (Icons.info_outline_rounded, 'About TrailerBaaz'),
      (Icons.logout_rounded, 'Logout'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              leading: Icon(
                item.$1,
                color: item.$2 == 'Logout' ? AppTheme.accent : Colors.white,
              ),
              title: Text(
                item.$2,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.muted,
              ),
              onTap: () {
                if (item.$2 == 'Appearance') {
                  _showAppearanceSheet(context);
                } else if (item.$2 == 'Logout') {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FadeTransition(
                            opacity: animation,
                            child: const SplashScreen(),
                          ),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showAppearanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _AppearanceSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.accent.withValues(alpha: .24)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ─── Appearance Sheet ────────────────────────────────────────────────────────

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HomeExperienceProvider.instance,
      builder: (context, _) {
        final current = HomeExperienceProvider.instance.experience;
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Home Experience',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how your Home screen looks',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              _ExperienceOption(
                title: 'Classic',
                subtitle: 'The familiar layout you know',
                icon: Icons.grid_view_rounded,
                isSelected: current == HomeExperience.classic,
                onTap: () {
                  HomeExperienceProvider.instance.setExperience(
                    HomeExperience.classic,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _ExperienceOption(
                title: 'Cinematic',
                subtitle: 'Immersive, premium cinema-inspired',
                icon: Icons.movie_filter_rounded,
                isSelected: current == HomeExperience.cinematic,
                onTap: () {
                  HomeExperienceProvider.instance.setExperience(
                    HomeExperience.cinematic,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExperienceOption extends StatelessWidget {
  const _ExperienceOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.12)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent.withValues(alpha: 0.5)
                : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.accent : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accent,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
