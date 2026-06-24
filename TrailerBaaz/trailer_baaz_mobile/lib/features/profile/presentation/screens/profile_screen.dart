import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Set<String> _industries = {'TE', 'BW'};
  final Set<String> _genres = {'Action', 'Sci-Fi'};
  String _homeIndustry = 'TE';

  static const _industryOptions = [
    MapEntry('HW', 'Hollywood · live'),
    MapEntry('BW', 'Bollywood · live'),
    MapEntry('KR', 'Korean Cinema · live'),
    MapEntry('TE', 'Tollywood (Telugu) · live'),
    MapEntry('TM', 'Tamil Cinema · live'),
    MapEntry('ML', 'Malayalam'),
    MapEntry('KN', 'Kannada'),
    MapEntry('MR', 'Marathi'),
    MapEntry('OD', 'Odia'),
    MapEntry('BN', 'Bengali'),
    MapEntry('PJ', 'Punjabi'),
    MapEntry('SL', 'Spanish / Latin'),
    MapEntry('AR', 'Arabic Cinema'),
    MapEntry('GT', 'Gulf TV'),
    MapEntry('JP', 'Japanese Cinema'),
    MapEntry('EU', 'European Cinema'),
  ];
  static const _genreOptions = [
    'Action',
    'Drama',
    'Horror',
    'Sci-Fi',
    'Romance',
    'Comedy',
    'Thriller',
    'Animation',
    'Documentary',
    'Fantasy',
    'Crime',
    'Musical',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withOpacity(0.75)),
          ),
          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                constraints: const BoxConstraints(maxWidth: 560),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tune TrailerBaaz for you',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      height: 1.08,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Pick industries, genres, and notifications — saved to your account when signed in.',
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.10)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            _SpringPress(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: AppColors.textWhite, size: 22),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SectionLabel('INDUSTRIES'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _industryOptions.map((item) {
                            final selected = _industries.contains(item.key);
                            return _ChipButton(
                              label: item.value,
                              selected: selected,
                              onTap: () => setState(() => selected ? _industries.remove(item.key) : _industries.add(item.key)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 26),
                        const _SectionLabel('HOME INDUSTRY'),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to set your default feed. Use × to remove an industry from your list.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _industryOptions
                              .where((item) => _industries.contains(item.key))
                              .map((item) {
                                final active = item.key == _homeIndustry;
                                return _HomeIndustryChip(
                                  label: item.value.replaceFirst(' · live', ''),
                                  active: active,
                                  onTap: () => setState(() => _homeIndustry = item.key),
                                  onRemove: () => setState(() {
                                    _industries.remove(item.key);
                                    if (_homeIndustry == item.key && _industries.isNotEmpty) {
                                      _homeIndustry = _industries.contains('TE') ? 'TE' : _industries.first;
                                    }
                                  }),
                                );
                              })
                              .toList(),
                        ),
                        const SizedBox(height: 26),
                        const _SectionLabel('GENRES'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _genreOptions.map((item) {
                            final selected = _genres.contains(item);
                            return _ChipButton(
                              label: item,
                              selected: selected,
                              onTap: () => setState(() => selected ? _genres.remove(item) : _genres.add(item)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.10)),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ActionPill(label: 'Yes, notify me', style: _ActionStyle.amber, onTap: () {}),
                            _ActionPill(label: 'Just browsing', style: _ActionStyle.ghost, onTap: () {}),
                            _ActionPill(label: 'Save', style: _ActionStyle.white, onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.amber,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        fontSize: 13,
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _SpringPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.amber : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.12)),
          boxShadow: selected ? [BoxShadow(color: AppColors.amber.withValues(alpha: 0.30), blurRadius: 8)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HomeIndustryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HomeIndustryChip({required this.label, required this.active, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _SpringPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.amber : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.amber : Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            _RemoveButton(onTap: onRemove),
          ],
        ),
      ),
    );
  }
}

enum _ActionStyle { amber, ghost, white }

class _ActionPill extends StatelessWidget {
  final String label;
  final _ActionStyle style;
  final VoidCallback onTap;

  const _ActionPill({required this.label, required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final background = switch (style) {
      _ActionStyle.amber => AppColors.amber,
      _ActionStyle.ghost => const Color(0xFF2A2A2A),
      _ActionStyle.white => AppColors.textWhite,
    };
    final foreground = style == _ActionStyle.white ? AppColors.background : AppColors.textWhite;
    return _SpringPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 13,
            fontWeight: style == _ActionStyle.ghost ? FontWeight.w400 : FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _SpringPress(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textWhite),
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
      child: AnimatedScale(scale: _pressed ? 0.95 : 1, duration: const Duration(milliseconds: 420), curve: Curves.elasticOut, child: widget.child),
    );
  }
}
