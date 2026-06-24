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

  static const _industryOptions = ['HW', 'BW', 'KR', 'TE', 'TM', 'KN'];
  static const _genreOptions = ['Action', 'Drama', 'Comedy', 'Crime', 'Sci-Fi', 'Mass', 'Spy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 112),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.amber.withValues(alpha: 0.06), blurRadius: 40, spreadRadius: 8, offset: const Offset(0, 24))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tune TrailerBaaz for you', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('Pick the industries and genres you want surfaced first.', style: TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    _SpringPress(
                      onTap: () {},
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionLabel('INDUSTRIES'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _industryOptions.map((item) {
                    final selected = _industries.contains(item);
                    return _ChipButton(
                      label: item,
                      selected: selected,
                      onTap: () => setState(() => selected ? _industries.remove(item) : _industries.add(item)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),
                const _SectionLabel('HOME INDUSTRY'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _industries.map((item) {
                    final active = item == _homeIndustry;
                    return _HomeIndustryChip(
                      label: item,
                      active: active,
                      onTap: () => setState(() => _homeIndustry = item),
                      onRemove: () => setState(() {
                        _industries.remove(item);
                        if (_homeIndustry == item && _industries.isNotEmpty) _homeIndustry = _industries.first;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),
                const _SectionLabel('GENRES'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _genreOptions.map((item) {
                    final selected = _genres.contains(item);
                    return _ChipButton(
                      label: item,
                      selected: selected,
                      onTap: () => setState(() => selected ? _genres.remove(item) : _genres.add(item)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                _ActionPill(label: 'Yes, notify me', style: _ActionStyle.amber, onTap: () {}),
                const SizedBox(height: 10),
                _ActionPill(label: 'Just browsing', style: _ActionStyle.ghost, onTap: () {}),
                const SizedBox(height: 10),
                _ActionPill(label: 'Save preferences', style: _ActionStyle.white, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.amber, fontWeight: FontWeight.w600, letterSpacing: 1.6));
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.amber : AppColors.chip,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.10)),
          boxShadow: selected ? [BoxShadow(color: AppColors.amber.withValues(alpha: 0.30), blurRadius: 8)] : null,
        ),
        child: Text(label, style: TextStyle(color: selected ? AppColors.textWhite : const Color(0xFFCCCCCC), fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.amber : AppColors.chip,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.amber : Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            GestureDetector(onTap: onRemove, child: const Icon(Icons.close_rounded, size: 15, color: AppColors.textWhite)),
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
      _ActionStyle.ghost => Colors.white.withValues(alpha: 0.08),
      _ActionStyle.white => AppColors.textWhite,
    };
    final foreground = style == _ActionStyle.white ? AppColors.background : AppColors.textWhite;
    return _SpringPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: foreground, fontWeight: style == _ActionStyle.ghost ? FontWeight.w500 : FontWeight.w800)),
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
