import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../data/mock/home_dummy_data.dart';
import 'trailer_details_screen.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/trailer_section.dart';
import '../widgets/trending_now.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: HeroCarousel(trailers: HomeDummyData.featured, onDetails: openDetails),
              ),
              SliverToBoxAdapter(
                child: TrendingNow(
                  scrollController: _scrollController,
                  trailers: HomeDummyData.byCategory('Trending'),
                  onTap: openDetails,
                ),
              ),
              SliverToBoxAdapter(child: TrailerSection(scrollController: _scrollController, title: '🇮🇳 Telugu', trailers: HomeDummyData.byCategory('Telugu'), cardWidth: 260, onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(scrollController: _scrollController, title: '🎬 Hindi', trailers: HomeDummyData.byCategory('Hindi'), cardWidth: 260, onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(scrollController: _scrollController, title: '📺 Web Series', trailers: HomeDummyData.byCategory('Web Series'), cardWidth: 260, onTap: openDetails)),
              SliverToBoxAdapter(child: TrailerSection(scrollController: _scrollController, title: 'Upcoming Releases', trailers: HomeDummyData.upcoming, cardWidth: 260, onTap: openDetails)),
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
            ],
          ),
          const _HomeHeader(),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatefulWidget {
  const _HomeHeader();

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  static const _languages = ['English', 'हिन्दी', 'తెలుగు', 'தமிழ்', 'ଓଡ଼ିଆ', 'ಕನ್ನಡ', 'മലയാളം', 'मराठी'];
  String _selectedLanguage = 'English';

  void _openSearch() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _openLanguageMenu() async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF1A1A1A),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(overlay.size.width - 196, 82, 16, 0),
      items: _languages.map((language) {
        final active = language == _selectedLanguage;
        return PopupMenuItem<String>(
          value: language,
          child: Row(
            children: [
              Expanded(child: Text(language, style: const TextStyle(color: AppColors.textWhite))),
              if (active) const Icon(Icons.check_rounded, color: AppColors.amber, size: 18),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      setState(() => _selectedLanguage = selected);
    }
  }

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
                Image.asset(
                  'assets/images/trailerbaaz_logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search, color: AppColors.textWhite, size: 22),
                ),
                IconButton(
                  onPressed: _openLanguageMenu,
                  icon: const Icon(Icons.language, color: AppColors.textWhite, size: 22),
                ),
                _SpringPress(
                  onTap: _openLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
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
                  color: active ? AppColors.amber : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: active ? Colors.transparent : Colors.white.withValues(alpha: 0.12)),
                  boxShadow: active ? [BoxShadow(color: AppColors.amber.withValues(alpha: 0.18), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))] : null,
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
