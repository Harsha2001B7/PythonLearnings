part of 'home_screen.dart';

class _SectionDetailView extends StatelessWidget {
  const _SectionDetailView({
    required this.sectionKey,
    required this.trailers,
    required this.onBack,
    required this.onOpenDetails,
    required this.onPlay,
    required this.onShowBrowse,
  });

  final String sectionKey;
  final List<Trailer> trailers;
  final VoidCallback onBack;
  final ValueChanged<Trailer> onOpenDetails;
  final ValueChanged<Trailer> onPlay;
  final VoidCallback onShowBrowse;

  @override
  Widget build(BuildContext context) {
    final cat = _allCats.firstWhere(
      (c) => c.sectionKey == sectionKey,
      orElse: () => const _BrowseCategory(
        label: 'Trailers',
        icon: Icons.movie_rounded,
        color: AppTheme.accent,
        sectionKey: '',
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
             decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cat.color.withValues(alpha: 0.25),
                  const Color(0x00090909),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0x1FFFFFFF),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onShowBrowse,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0x26FFFFFF),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Browse',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: AppTheme.accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: cat.flag != null
                          ? Center(
                              child: Text(
                                cat.flag!,
                                style: const TextStyle(fontSize: 26),
                              ),
                            )
                          : Icon(cat.icon, color: cat.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '${trailers.length} trailers',
                          style: const TextStyle(
                            color: Color(0x80FFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (trailers.isEmpty)
          const SliverFillRemaining(
            child: NoResults(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList.separated(
              itemCount: trailers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                return TrailerCard.large(
                  trailer: trailer,
                  onTap: () => onOpenDetails(trailer),
                  onPlay: () => onPlay(trailer),
                  width: MediaQuery.sizeOf(context).width - 40,
                );
              },
            ),
          ),
      ],
    );
  }
}

