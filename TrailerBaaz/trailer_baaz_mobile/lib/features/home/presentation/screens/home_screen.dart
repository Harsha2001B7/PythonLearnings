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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HomeHeader()),
            SliverToBoxAdapter(child: HeroCarousel(trailers: HomeDummyData.featured, onDetails: openDetails)),
            SliverToBoxAdapter(child: TrendingNow(trailers: HomeDummyData.byCategory('Trending'), onTap: openDetails)),
            SliverToBoxAdapter(child: TrailerSection(title: '🇮🇳 Telugu', trailers: HomeDummyData.byCategory('Telugu'), onTap: openDetails)),
            SliverToBoxAdapter(child: TrailerSection(title: '🎬 Hindi', trailers: HomeDummyData.byCategory('Hindi'), onTap: openDetails)),
            SliverToBoxAdapter(child: TrailerSection(title: '📺 Web Series', trailers: HomeDummyData.byCategory('Web Series'), onTap: openDetails)),
            SliverToBoxAdapter(child: TrailerSection(title: 'Upcoming Releases', trailers: HomeDummyData.upcoming, cardWidth: 158, onTap: openDetails)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Row(
        children: [
          Text('TrailerBaaz', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.card,
            child: const Icon(Icons.person_outline_rounded, color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}
