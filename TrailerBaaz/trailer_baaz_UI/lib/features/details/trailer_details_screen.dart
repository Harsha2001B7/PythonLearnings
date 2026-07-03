import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/di/locator.dart';
import '../../core/models/trailer.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/meta_widgets.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/widgets/trailer_card.dart';
import '../../shared/widgets/trailer_player.dart';

class TrailerDetailsScreen extends StatefulWidget {
  const TrailerDetailsScreen({super.key, required this.trailer});

  final Trailer trailer;

  @override
  State<TrailerDetailsScreen> createState() => _TrailerDetailsScreenState();
}

class _TrailerDetailsScreenState extends State<TrailerDetailsScreen> {
  int? _popcornRating;

  void _openPopcornSheet() {
    showPopcornRating(
      context,
      hypeScore: widget.trailer.hypeScore,
      currentRating: _popcornRating,
      onRatingChanged: (r) => setState(() => _popcornRating = r),
    );
  }

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
                    fontSize: 24,
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
                    StatItem(value: trailer.views, label: 'Trailer views'),
                    StatItem(value: trailer.releaseDate, label: 'Released'),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF242424), height: 1),
                const SizedBox(height: 22),
                _PopcornPanel(
                  score: trailer.hypeScore,
                  rating: _popcornRating,
                  onOpen: _openPopcornSheet,
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

class _PopcornPanel extends StatelessWidget {
  const _PopcornPanel({
    required this.score,
    required this.rating,
    required this.onOpen,
  });

  final int score;
  final int? rating;
  final VoidCallback onOpen;

  String get _ratingLabel {
    if (rating == null) return 'Tap to rate this trailer';
    const labels = ['', 'Hard pass', 'One kernel?', 'Pop me', 'Gift popcorn', 'Feed the bucket'];
    return 'Your pop: ${labels[rating!]}';
  }

  @override
  Widget build(BuildContext context) {
    final rated = rating != null;
    return GestureDetector(
      onTap: onOpen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: rated
                ? [const Color(0xFF1E1A10), const Color(0xFF151208)]
                : [const Color(0xFF171717), const Color(0xFF111111)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: rated
                ? AppTheme.hype.withValues(alpha: .45)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.hype.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍿', style: TextStyle(fontSize: 28)),
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
                        fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ratingLabel,
                    style: TextStyle(
                      color: rated ? AppTheme.hype : AppTheme.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white38, size: 22),
          ],
        ),
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
    final provider = locator<YoutubeTrailersProvider>();
    final allTrailers = provider.sections.values
        .expand((list) => list)
        .where((t) => t.id != current.id)
        .toList();
    if (reversed) allTrailers.sort((a, b) => b.title.compareTo(a.title));
    final items = allTrailers.take(8).toList();

    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: NoResults(message: 'No related trailers'),
      );
    }

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
              height: imageH,
            ),
          ),
        );
      },
    );
  }
}
