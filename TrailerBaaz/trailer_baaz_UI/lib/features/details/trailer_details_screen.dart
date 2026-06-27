import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/meta_widgets.dart';
import '../../shared/widgets/trailer_card.dart';
import '../../shared/widgets/trailer_player.dart';

class TrailerDetailsScreen extends StatefulWidget {
  const TrailerDetailsScreen({super.key, required this.trailer});

  final Trailer trailer;

  @override
  State<TrailerDetailsScreen> createState() => _TrailerDetailsScreenState();
}

class _TrailerDetailsScreenState extends State<TrailerDetailsScreen> {
  bool _hyped = false;

  void _playTrailer() {
    showTrailerPlayer(context, widget.trailer);
  }

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height < 760
                  ? 350
                  : MediaQuery.sizeOf(context).height * .46,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'backdrop-${trailer.id}',
                    child: CinematicImage(
                      url: trailer.youtubeThumbnailUrl,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x22000000),
                          Color(0x33000000),
                          Color(0xDD000000),
                          AppTheme.background,
                        ],
                        stops: [0, .36, .76, 1],
                      ),
                    ),
                  ),
                  // Tappable play button
                  Center(
                    child: GestureDetector(
                      onTap: _playTrailer,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .54),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .55),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 38),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: MediaQuery.paddingOf(context).top + 8,
                    child: Row(
                      children: [
                        GlassIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          tooltip: 'Back',
                          size: 46,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        GlassIconButton(
                          icon: Icons.ios_share_rounded,
                          tooltip: 'Share',
                          size: 46,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trailer.genres.take(3).map(GenreChip.new).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  trailer.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    height: .94,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${trailer.director} • ${trailer.runtime} • ${trailer.language} • ${trailer.certificate}',
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    StatItem(
                      value: '${trailer.hypeScore}%',
                      label: 'Audience hype',
                      icon: Icons.local_fire_department,
                      valueColor: AppTheme.accent,
                    ),
                    StatItem(value: trailer.views, label: 'Trailer views'),
                    StatItem(value: trailer.releaseDate, label: 'Released'),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF242424), height: 1),
                const SizedBox(height: 22),
                _HypePanel(
                  score: trailer.hypeScore,
                  hyped: _hyped,
                  onChanged: () => setState(() => _hyped = !_hyped),
                ),
                const SizedBox(height: 18),
                const _TicketPanel(),
                const SizedBox(height: 28),
                const _SectionTitle('Synopsis'),
                const SizedBox(height: 10),
                Text(
                  trailer.synopsis,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.55,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Top Cast'),
                const SizedBox(height: 14),
                _CastList(cast: trailer.cast),
                const SizedBox(height: 30),
                const _SectionTitle('Related Trailers'),
                const SizedBox(height: 14),
                _RelatedRail(current: trailer),
                const SizedBox(height: 30),
                const _SectionTitle('Similar Movies'),
                const SizedBox(height: 14),
                _RelatedRail(current: trailer, reversed: true),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HypePanel extends StatelessWidget {
  const _HypePanel({
    required this.score,
    required this.hyped,
    required this.onChanged,
  });

  final int score;
  final bool hyped;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hyped
              ? [const Color(0xFF311015), const Color(0xFF181010)]
              : [const Color(0xFF171717), const Color(0xFF111111)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hyped
              ? AppTheme.accent.withValues(alpha: .45)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppTheme.accent,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$score% Audience Hype',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hyped
                      ? 'You hyped this trailer.'
                      : 'Make your hype count for TrailerBaaz.',
                  style:
                      const TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onChanged,
            style: FilledButton.styleFrom(
              backgroundColor: hyped ? Colors.white : AppTheme.accent,
              foregroundColor: hyped ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(hyped ? 'Remove' : 'Give Hype'),
          ),
        ],
      ),
    );
  }
}

class _TicketPanel extends StatelessWidget {
  const _TicketPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF241719), Color(0xFF171420)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tickets Available Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Book tickets from your preferred partner.',
            style: TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.confirmation_number_rounded,
                      size: 17),
                  label:
                      const FittedBox(child: Text('BookMyShow')),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF416D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_activity_rounded, size: 17),
                  label: const FittedBox(child: Text('District')),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF241F31),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
    );
  }
}

class _CastList extends StatelessWidget {
  const _CastList({required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CinematicImage(url: member.imageUrl),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  member.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 10, color: AppTheme.muted),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RelatedRail extends StatelessWidget {
  const _RelatedRail({required this.current, this.reversed = false});

  final Trailer current;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final provider = YoutubeTrailersProvider.instance;
    final allTrailers = provider.sections.values
        .expand((list) => list)
        .where((t) => t.id != current.id)
        .toList();
    if (reversed) allTrailers.sort((a, b) => b.title.compareTo(a.title));
    final items = allTrailers.take(8).toList();

    final cardWidth = 220.0;
    final imageHeight = cardWidth * 9 / 16;
    final totalHeight = imageHeight + 76.0;

    if (items.isEmpty) {
      return SizedBox(
        height: totalHeight,
        child: const Center(
          child: Text('No related trailers',
              style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return SizedBox(
      height: totalHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => TrailerCard(
          trailer: items[index],
          onTap: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, animation, _) => FadeTransition(
                  opacity: animation,
                  child: TrailerDetailsScreen(trailer: items[index]),
                ),
              ),
            );
          },
          onPlay: () => showTrailerPlayer(context, items[index]),
          width: cardWidth,
          height: imageHeight, // TrailerCard expects image height, not total height
        ),
      ),
    );
  }
}
