import 'package:flutter/material.dart';

import '../../../home/data/mock/home_dummy_data.dart';
import '../../../home/presentation/screens/trailer_details_screen.dart';
import '../../../home/presentation/screens/trailer_player_screen.dart';
import '../../data/mock/reels_dummy_data.dart';
import '../../domain/models/reel_model.dart';
import '../widgets/reel_overlay.dart';
import '../widgets/reel_player.dart';
import '../../../home/domain/models/trailer_model.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<ReelModel> get _reels => ReelsDummyData.reels;

  void _openDetails(ReelModel reel) {
    final trailer = _matchTrailer(reel);
    if (trailer == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }

  void _openPlayer(ReelModel reel) {
    final trailer = _matchTrailer(reel);
    if (trailer == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerPlayerScreen(trailer: trailer)),
    );
  }

  TrailerModel? _matchTrailer(ReelModel reel) {
    for (final trailer in HomeDummyData.trailers) {
      if (trailer.title == reel.title || trailer.youtubeUrl == reel.videoUrl) {
        return trailer;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (index) {
          if (_index == index) return;
          setState(() => _index = index);
        },
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final active = _index == index;
          return Stack(
            fit: StackFit.expand,
            children: [
              ReelPlayer(
                thumbnailUrl: reel.thumbnailUrl,
                active: active,
              ),
              ReelOverlay(
                reel: reel,
                active: active,
                onPlayTrailer: () => _openPlayer(reel),
                onDetails: () => _openDetails(reel),
              ),
            ],
          );
        },
      ),
    );
  }
}
