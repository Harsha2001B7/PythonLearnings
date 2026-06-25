import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/dummy_trailers.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/meta_widgets.dart';
import '../details/trailer_details_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: trailers.length * 20,
      itemBuilder: (context, index) {
        final trailer = trailers[index % trailers.length];
        return _DiscoverPage(trailer: trailer);
      },
    );
  }
}

class _DiscoverPage extends StatefulWidget {
  const _DiscoverPage({required this.trailer});

  final Trailer trailer;

  @override
  State<_DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<_DiscoverPage> {
  bool _hyped = false;
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    return Stack(
      fit: StackFit.expand,
      children: [
        CinematicImage(url: trailer.backdropUrl),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x55000000),
                Color(0x11000000),
                Color(0x99000000),
                Color(0xEE000000),
              ],
              stops: [0, .25, .66, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 18, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    GlassIconButton(
                      icon: Icons.volume_off_rounded,
                      tooltip: 'Muted preview',
                      size: 44,
                      onPressed: () {},
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: trailer.genres
                                .take(2)
                                .map(GenreChip.new)
                                .toList(),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            trailer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 34,
                              height: .96,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            trailer.tagline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 14,
                            runSpacing: 8,
                            children: [
                              HypeLabel(score: trailer.hypeScore),
                              Text(
                                '${trailer.views} views',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                trailer.releaseDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () => _openDetails(context, trailer),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Watch Trailer'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(190, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        _SideAction(
                          icon: _hyped
                              ? Icons.local_fire_department
                              : Icons.local_fire_department_outlined,
                          label: 'Hype',
                          active: _hyped,
                          onTap: () => setState(() => _hyped = !_hyped),
                        ),
                        _SideAction(
                          icon: _bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          label: 'Save',
                          active: _bookmarked,
                          onTap: () =>
                              setState(() => _bookmarked = !_bookmarked),
                        ),
                        _SideAction(
                          icon: Icons.mode_comment_outlined,
                          label: '12K',
                          onTap: () {},
                        ),
                        _SideAction(
                          icon: Icons.ios_share_rounded,
                          label: 'Share',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context, Trailer trailer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .36),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .12)),
              ),
              child: Icon(icon, color: active ? AppTheme.accent : Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
