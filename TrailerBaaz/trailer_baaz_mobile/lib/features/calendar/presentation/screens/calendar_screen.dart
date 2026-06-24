import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/mock/home_dummy_data.dart';
import '../widgets/release_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final releases = HomeDummyData.upcoming;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RELEASE RADAR', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.amber, fontWeight: FontWeight.w600, letterSpacing: 1.7)),
                    const SizedBox(height: 10),
                    Text('Calendar', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Upcoming trailers and releases worth keeping on your radar.', style: TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 30),
                    const Text('JUNE 2026', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500, letterSpacing: 1.6)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 108),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    if (index.isOdd) return const SizedBox(height: 12);
                    final releaseIndex = index ~/ 2;
                    return _StaggeredRelease(index: releaseIndex, child: ReleaseCard(trailer: releases[releaseIndex], index: releaseIndex));
                  },
                  childCount: releases.isEmpty ? 0 : releases.length * 2 - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredRelease extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredRelease({required this.index, required this.child});

  @override
  State<_StaggeredRelease> createState() => _StaggeredReleaseState();
}

class _StaggeredReleaseState extends State<_StaggeredRelease> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}
