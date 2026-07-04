part of 'home_screen.dart';

@immutable
class _BrowseCategory {
  final String label;
  final IconData icon;
  final Color color;
  final String sectionKey;
  final String? flag;

  const _BrowseCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.sectionKey,
    this.flag,
  });
}

const _browseCategories = [
  _BrowseCategory(
    label: 'Trending Now',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF6B35),
    sectionKey: 'Trending Now',
  ),
  _BrowseCategory(
    label: 'Most Awaited',
    icon: Icons.star_rounded,
    color: Color(0xFFFFD700),
    sectionKey: 'Most Awaited',
  ),
  _BrowseCategory(
    label: 'Coming Soon',
    icon: Icons.schedule_rounded,
    color: Color(0xFF7C3AED),
    sectionKey: 'Coming Soon',
  ),
];

const _languageCategories = [
  _BrowseCategory(
    label: 'Hollywood',
    icon: Icons.movie_rounded,
    color: Color(0xFF3B82F6),
    sectionKey: 'Hollywood',
    flag: '🎬',
  ),
  _BrowseCategory(
    label: 'Bollywood',
    icon: Icons.music_note_rounded,
    color: Color(0xFFEC4899),
    sectionKey: 'Bollywood',
    flag: '🇮🇳',
  ),
  _BrowseCategory(
    label: 'Telugu',
    icon: Icons.videocam_rounded,
    color: Color(0xFF10B981),
    sectionKey: 'Telugu',
    flag: '🎭',
  ),
  _BrowseCategory(
    label: 'Tamil',
    icon: Icons.theater_comedy_rounded,
    color: Color(0xFFF59E0B),
    sectionKey: 'Tamil',
    flag: '🎥',
  ),
  _BrowseCategory(
    label: 'Korean',
    icon: Icons.subtitles_rounded,
    color: Color(0xFF06B6D4),
    sectionKey: 'Korean',
    flag: '🇰🇷',
  ),
  _BrowseCategory(
    label: 'OTT Originals',
    icon: Icons.play_circle_rounded,
    color: Color(0xFF8B5CF6),
    sectionKey: 'OTT Originals',
    flag: '🌐',
  ),
];

final _allCats = [..._browseCategories, ..._languageCategories];

class _QuickCategoryBar extends StatelessWidget {
  const _QuickCategoryBar({required this.onShowBrowse, required this.onSelect});

  final VoidCallback onShowBrowse;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Browse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShowBrowse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
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
                          'All Categories',
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _allCats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _allCats[i];
                return GestureDetector(
                  onTap: () => onSelect(cat.sectionKey),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cat.color.withValues(alpha: 0.25),
                          cat.color.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cat.color.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cat.flag != null) ...[
                          Text(cat.flag!, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                        ] else ...[
                          Icon(cat.icon, color: cat.color, size: 13),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          cat.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BrowseSheet extends StatelessWidget {
  const _BrowseSheet({
    required this.onSelect,
    required this.selectedSection,
    required this.loadedSections,
  });

  final ValueChanged<String> onSelect;
  final String? selectedSection;
  final Set<String> loadedSections;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.45, 0.72, 0.92],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xF50D1117),
                    Color(0xFA070A11),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: const Border(
                  top: BorderSide(
                    color: Color(0x4CE50914),
                    width: 1.2,
                  ),
                ),
              ),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 20,
                ),
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.accent,
                                Color(0x4CE50914),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Browse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _SheetSectionHeader(label: 'DISCOVER'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: _browseCategories.map((cat) {
                        final isSelected = selectedSection == cat.sectionKey;
                        final isLoaded = loadedSections.contains(
                          cat.sectionKey,
                        );
                        return _SheetCategoryTile(
                          category: cat,
                          isSelected: isSelected,
                          isLoaded: isLoaded,
                          onTap: () => onSelect(cat.sectionKey),
                        );
                      }).toList(),
                    ),
                  ),
                  const _SheetSectionHeader(label: 'POPULAR LANGUAGES'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      children: _languageCategories.map((cat) {
                        final isSelected = selectedSection == cat.sectionKey;
                        final isLoaded = loadedSections.contains(
                          cat.sectionKey,
                        );
                        return _SheetLanguageTile(
                          category: cat,
                          isSelected: isSelected,
                          isLoaded: isLoaded,
                          onTap: () => onSelect(cat.sectionKey),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetSectionHeader extends StatelessWidget {
  const _SheetSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0x80FFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SheetCategoryTile extends StatelessWidget {
  const _SheetCategoryTile({
    required this.category,
    required this.isSelected,
    required this.isLoaded,
    required this.onTap,
  });

  final _BrowseCategory category;
  final bool isSelected;
  final bool isLoaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    category.color.withValues(alpha: 0.35),
                    category.color.withValues(alpha: 0.18),
                  ]
                : const [
                    Color(0x0DFFFFFF),
                    Color(0x05FFFFFF),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.6)
                : const Color(0x14FFFFFF),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xD9FFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isLoaded)
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: isSelected
                    ? category.color
                    : const Color(0x4DFFFFFF),
                size: isSelected ? 20 : 14,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetLanguageTile extends StatelessWidget {
  const _SheetLanguageTile({
    required this.category,
    required this.isSelected,
    required this.isLoaded,
    required this.onTap,
  });

  final _BrowseCategory category;
  final bool isSelected;
  final bool isLoaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    category.color.withValues(alpha: 0.45),
                    category.color.withValues(alpha: 0.2),
                  ]
                : [
                    category.color.withValues(alpha: 0.15),
                    category.color.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.7)
                : category.color.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              bottom: -4,
              child: Text(
                category.flag ?? '',
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0x14FFFFFF),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(
                    category.flag ?? '',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xD9FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 10,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: category.color,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
