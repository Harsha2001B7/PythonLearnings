import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/di/locator.dart';
import '../../core/models/trailer.dart';
import '../../core/navigation/navigation_service.dart';
import '../../shared/animations/animations.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/meta_widgets.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/trailer_player/trailer_player.dart';
import 'widgets/popcorn_panel.dart';
import 'widgets/ticket_panel.dart';
import 'widgets/cast_list.dart';
import 'widgets/related_rail.dart';

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
                  TrailerBackdropHero(
                    trailerId: trailer.id,
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
                          onPressed: () =>
                              locator<NavigationService>().pop(context),
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
                PopcornPanel(
                  score: trailer.hypeScore,
                  rating: _popcornRating,
                  onOpen: _openPopcornSheet,
                ),
                const SizedBox(height: 18),
                const TicketPanel(),
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
                CastList(cast: trailer.cast),
                const SizedBox(height: 30),
                const _SectionTitle('Related Trailers'),
                const SizedBox(height: 14),
                RelatedRail(current: trailer),
                const SizedBox(height: 30),
                const _SectionTitle('Similar Movies'),
                const SizedBox(height: 14),
                RelatedRail(current: trailer, reversed: true),
              ]),
            ),
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
