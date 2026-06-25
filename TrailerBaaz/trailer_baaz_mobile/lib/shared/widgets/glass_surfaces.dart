import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/trailer_model.dart';
import '../../core/theme/app_colors.dart';

Future<void> showPreferencesModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.68),
    builder: (context) => const _PreferencesSheet(),
  );
}

Future<void> showReactionBottomSheet(
  BuildContext context,
  TrailerModel trailer,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.68),
    builder: (context) => _ReactionSheet(trailer: trailer),
  );
}

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double backgroundOpacity;
  final double borderOpacity;
  final List<BoxShadow> boxShadow;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 18,
    this.backgroundOpacity = 0.08,
    this.borderOpacity = 0.12,
    this.boxShadow = const [
      BoxShadow(color: Colors.black54, blurRadius: 28, offset: Offset(0, 14)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: backgroundOpacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
            ),
            boxShadow: boxShadow,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final double size;
  final EdgeInsetsGeometry padding;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: const [],
          child: SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: padding,
              child: FittedBox(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;
  final double height;

  const GlassPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(999),
          backgroundOpacity: filled ? 0.12 : 0.08,
          borderOpacity: filled ? 0.14 : 0.12,
          blurSigma: 18,
          boxShadow: const [],
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: AppColors.textWhite),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassSectionLabel extends StatelessWidget {
  final String label;
  final String? subtitle;

  const GlassSectionLabel({super.key, required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.amber,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  final Set<String> _industries = {'HW', 'BW', 'KR', 'TE', 'TM'};
  final Set<String> _genres = {'Action', 'Drama', 'Horror', 'Sci-Fi', 'Comedy'};
  String _homeIndustry = 'TE';
  bool _notifications = true;

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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                        children: const [
                          Text(
                            'Tune TrailerBaaz for you',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pick industries, genres, and notifications - saved to your account when signed in.',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassIconButton(
                      size: 38,
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                const SizedBox(height: 16),
                const GlassSectionLabel(label: 'INDUSTRIES'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _industryOptions.map((item) {
                    final selected = _industries.contains(item.key);
                    return _ChoiceChip(
                      label: item.value,
                      selected: selected,
                      onTap: () => setState(() {
                        if (selected) {
                          _industries.remove(item.key);
                          if (_homeIndustry == item.key &&
                              _industries.isNotEmpty) {
                            _homeIndustry = _industries.contains('TE')
                                ? 'TE'
                                : _industries.first;
                          }
                        } else {
                          _industries.add(item.key);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const GlassSectionLabel(label: 'HOME INDUSTRY'),
                const SizedBox(height: 10),
                const Text(
                  'Tap to set your default feed. Use x to remove an industry from your list.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
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
                            if (_homeIndustry == item.key &&
                                _industries.isNotEmpty) {
                              _homeIndustry = _industries.contains('TE')
                                  ? 'TE'
                                  : _industries.first;
                            }
                          }),
                        );
                      })
                      .toList(),
                ),
                const SizedBox(height: 24),
                const GlassSectionLabel(label: 'GENRES'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _genreOptions.map((item) {
                    final selected = _genres.contains(item);
                    return _ChoiceChip(
                      label: item,
                      selected: selected,
                      onTap: () => setState(() {
                        if (selected) {
                          _genres.remove(item);
                        } else {
                          _genres.add(item);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlassPillButton(
                        label: 'Yes, notify me',
                        icon: Icons.notifications_active_outlined,
                        filled: _notifications,
                        onTap: () => setState(() => _notifications = true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GlassPillButton(
                        label: 'Just browsing',
                        icon: Icons.visibility_outlined,
                        onTap: () => setState(() => _notifications = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GlassPillButton(
                      label: 'Save preferences',
                      filled: true,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionSheet extends StatelessWidget {
  final TrailerModel trailer;

  const _ReactionSheet({required this.trailer});

  @override
  Widget build(BuildContext context) {
    final seed = trailer.title.codeUnits.fold<int>(
      0,
      (sum, code) => sum + code,
    );
    final hype = 42 + (seed % 48);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(30),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('🍿', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'How hard will you pop?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    size: 36,
                    padding: const EdgeInsets.all(7),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textWhite,
                      size: 18,
                    ),
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Audience hype',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$hype/100',
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: hype / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _ReactionChip(label: 'Hard pass'),
                  _ReactionChip(label: 'One kerne?'),
                  _ReactionChip(label: 'Pop me'),
                  _ReactionChip(label: 'Gift popcorn'),
                  _ReactionChip(label: 'Feed the bucket'),
                ],
              ),
              const SizedBox(height: 18),
              GlassPillButton(
                label: 'Dismiss',
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String label;

  const _ReactionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 102,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        backgroundOpacity: 0.07,
        borderOpacity: 0.10,
        boxShadow: const [],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍿', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.amber
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.background : AppColors.textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
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

  const _HomeIndustryChip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.amber
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.background : AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: active ? AppColors.background : AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
