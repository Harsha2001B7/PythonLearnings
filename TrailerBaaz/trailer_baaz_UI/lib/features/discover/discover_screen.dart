import 'package:flutter/material.dart';

import '../../core/data/youtube_trailers_provider.dart';
import '../../core/di/locator.dart';
import '../../shared/ui/ui.dart';
import 'widgets/reel_page.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  PageController? _pageController;
  int _currentPage = 0;
  final _provider = locator<YoutubeTrailersProvider>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _provider.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onDataChanged);
    try {
      _pageController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = locator<YoutubeTrailersProvider>();
    // Combine all available trailers or fallback to heroTrailers
    final allTrailers = provider.heroTrailers;

    if (allTrailers.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: allTrailers.length * 20,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        final trailer = allTrailers[index % allTrailers.length];
        final isActive = index == _currentPage;
        return ReelPage(trailer: trailer, isActive: isActive);
      },
    );
  }
}


