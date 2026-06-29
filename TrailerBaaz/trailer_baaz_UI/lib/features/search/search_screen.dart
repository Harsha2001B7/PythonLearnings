import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/trailer_card.dart';
import '../details/trailer_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  String _query = '';
  bool _showAllStudios = false;
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: YoutubeTrailersProvider.instance,
      builder: (context, _) {
        final allTrailers = YoutubeTrailersProvider.instance.allTrailers;
        final results = allTrailers
            .where(
              (item) => item.title.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
        final visibleResults = _query.isEmpty ? allTrailers : results;
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
                  const Text(
                    'Search',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  _SearchBar(
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 24),
                  _ChipBlock(
                    title: 'Recent Searches',
                    items: const [
                      'Neon Shadows',
                      'Cyberpunk',
                      'Tamil thrillers',
                    ],
                  ),
                  const SizedBox(height: 22),
                  _ChipBlock(
                    title: 'Trending Searches',
                    items: const [
                      'BookMyShow',
                      'Korean drama',
                      'OTT originals',
                      'Space',
                    ],
                    accent: true,
                  ),
                  const SizedBox(height: 22),
                  _ChipBlock(
                    title: 'Genres',
                    items: const [
                      'Action',
                      'Sci-Fi',
                      'Thriller',
                      'Drama',
                      'Adventure',
                    ],
                  ),
                  const SizedBox(height: 22),
                  _ChipBlock(
                    title: 'Languages',
                    items: const [
                      'English',
                      'Hindi',
                      'Telugu',
                      'Tamil',
                      'Korean',
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader('Trending Actors'),
                  const SizedBox(height: 14),
                  const _PeopleRail(),
                  const SizedBox(height: 28),
                  const _SectionHeader('Popular Studios'),
                  const SizedBox(height: 14),
                  _StudioGrid(
                    studios: allTrailers
                        .map((item) => item.studio)
                        .where((s) => s.isNotEmpty)
                        .toSet()
                        .toList(),
                    expanded: _showAllStudios,
                    onToggle: () {
                      setState(() {
                        _showAllStudios = !_showAllStudios;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    _query.isEmpty ? 'Search Results' : 'Results for "$_query"',
                  ),
                  const SizedBox(height: 14),
                  ...visibleResults.map(
                    (trailer) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ResultCard(
                        trailer: trailer,
                        onTap: () => _openDetails(trailer),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openDetails(Trailer trailer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .11)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: Icon(Icons.mic_none_rounded, color: Colors.white70),
          hintText: 'Search trailers, actors, studios',
          hintStyle: TextStyle(color: AppTheme.muted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 19),
        ),
      ),
    );
  }
}

class _ChipBlock extends StatelessWidget {
  const _ChipBlock({
    required this.title,
    required this.items,
    this.accent = false,
  });

  final String title;
  final List<String> items;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item),
                  avatar: accent
                      ? const Icon(
                          Icons.trending_up_rounded,
                          size: 17,
                          color: AppTheme.accent,
                        )
                      : null,
                  backgroundColor: accent
                      ? AppTheme.accent.withValues(alpha: .14)
                      : Colors.white.withValues(alpha: .07),
                ),
              )
              .toList(),
        ),
      ],
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

class _PeopleRail extends StatelessWidget {
  const _PeopleRail();

  @override
  Widget build(BuildContext context) {
    final allTrailers = YoutubeTrailersProvider.instance.allTrailers;
    final people = allTrailers.isNotEmpty ? allTrailers.first.cast : [];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: people.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final person = people[index];
          return SizedBox(
            width: 76,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: CinematicImage(url: person.imageUrl),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudioGrid extends StatelessWidget {
  const _StudioGrid({
    required this.studios,
    required this.expanded,
    required this.onToggle,
  });

  final List<String> studios;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final visible = expanded ? studios : studios.take(6).toList();

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: ShaderMask(
            shaderCallback: (bounds) {
              if (expanded) {
                return const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ).createShader(bounds);
              }

              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.75, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: visible
                  .map(
                    (studio) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        studio,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        if (studios.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton.icon(
              onPressed: onToggle,
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: expanded ? .5 : 0,
                child: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              label: Text(
                expanded ? "Show less" : "Show ${studios.length - 6} more",
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.trailer, required this.onTap});

  final Trailer trailer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40;
    final imageH = width * (9 / 16);
    return TrailerCard(
      trailer: trailer,
      onTap: onTap,
      width: width,
      height: imageH,
      showPlay: true,
    );
  }
}
