import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../data/mock/home_dummy_data.dart';
import 'trailer_details_screen.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/trailer_section.dart';
import '../widgets/trending_now.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void openDetails(TrailerModel trailer) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: HeroCarousel(trailers: HomeDummyData.featured, onDetails: openDetails)),
              SliverToBoxAdapter(child: TrendingNow(trailers: HomeDummyData.byCategory('Trending'), onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(title: '🇮🇳 Telugu', trailers: HomeDummyData.byCategory('Telugu'), onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(title: '🎬 Hindi', trailers: HomeDummyData.byCategory('Hindi'), onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(title: '📺 Web Series', trailers: HomeDummyData.byCategory('Web Series'), onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(title: 'Upcoming Releases', trailers: HomeDummyData.upcoming, cardWidth: 158, onTap: openDetails)),
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
            ],
          ),
          const _HomeHeader(),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('TrailerBaaz', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textWhite)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline_rounded, color: AppColors.textWhite)),
              ],
            ),
            const SizedBox(height: 12),
            const _IndustryFilter(),
          ],
        ),
      ),
    );
  }
}

class _IndustryFilter extends StatefulWidget {
  const _IndustryFilter();

  @override
  State<_IndustryFilter> createState() => _IndustryFilterState();
}

class _IndustryFilterState extends State<_IndustryFilter> {
  static const _items = ['HW', 'BW', 'KR', 'TE', 'TM', 'KN'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_items.length, (index) {
          final active = index == _selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _SpringPress(
              onTap: () => setState(() => _selected = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.amber : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.12)),
                  boxShadow: active ? [BoxShadow(color: AppColors.amber.withOpacity(0.18), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))] : null,
                ),
                child: Text(
                  _items[index],
                  style: TextStyle(color: active ? AppColors.textWhite : AppColors.textGrey, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SpringPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SpringPress({required this.child, required this.onTap});

  @override
  State<_SpringPress> createState() => _SpringPressState();
}

class _SpringPressState extends State<_SpringPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}
