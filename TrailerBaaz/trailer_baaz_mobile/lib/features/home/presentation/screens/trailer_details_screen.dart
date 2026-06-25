import 'package:flutter/material.dart';

import '../../data/mock/home_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';
import '../widgets/action_buttons.dart';
import '../widgets/cast_section.dart';
import '../widgets/info_section.dart';
import '../widgets/related_trailers_section.dart';
import 'trailer_player_screen.dart';

class TrailerDetailsScreen extends StatelessWidget {
  final TrailerModel trailer;

  const TrailerDetailsScreen({super.key, required this.trailer});

  @override
  Widget build(BuildContext context) {
    final related = HomeDummyData.trailers
        .where(
          (item) =>
              item.title != trailer.title && item.category == trailer.category,
        )
        .take(6)
        .toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: _Hero(trailer: trailer),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                InfoSection(trailer: trailer),
                const SizedBox(height: 20),
                const ActionButtons(),
                const SizedBox(height: 28),
                CastSection(castMembers: trailer.castMembers),
                const SizedBox(height: 28),
                RelatedTrailersSection(
                  trailers: related,
                  onTap: (item) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrailerDetailsScreen(trailer: item),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final TrailerModel trailer;

  const _Hero({required this.trailer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _SafeImage(url: trailer.imageUrl),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.58, 1.0],
              colors: [Color(0x22000000), Color(0x12000000), Color(0xFF090909)],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GlassIconButton(
            size: 42,
            padding: const EdgeInsets.all(8),
            icon: const Text('🍿', style: TextStyle(fontSize: 18)),
            onTap: () => showReactionBottomSheet(context, trailer),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Row(
            children: [
              Expanded(
                child: _HeroButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Play',
                  filled: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrailerPlayerScreen(trailer: trailer),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafeImage extends StatefulWidget {
  final String url;
  const _SafeImage({required this.url});

  @override
  State<_SafeImage> createState() => _SafeImageState();
}

class _SafeImageState extends State<_SafeImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final valid = widget.url.startsWith('http') && widget.url.contains('/t/p/');
    if (_failed || !valid) {
      return const ColoredBox(
        color: AppColors.card,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            color: AppColors.textGrey,
            size: 42,
          ),
        ),
      );
    }
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (!_failed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
        }
        return const ColoredBox(
          color: AppColors.card,
          child: Center(
            child: Icon(
              Icons.movie_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _HeroButton({
    required this.icon,
    required this.label,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPillButton(
      label: label,
      icon: icon,
      filled: filled,
      onTap: onTap ?? () {},
    );
  }
}
