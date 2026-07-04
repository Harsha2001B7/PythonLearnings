import 'dart:async';
import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../shared/animations/animations.dart';
import '../../../shared/widgets/cinematic_image.dart';
import '../../../core/di/locator.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/navigation/routes.dart';
import '../../notifications/widgets/notification_badge.dart';

const double kHeaderLogoHeight = 52.0; // Enlarged from 42.0
const double kHeaderAvatarSize = 32.0; // Reduced from 40.0

const List<String> kSubtitlePlaceholders = [
  'Discover Today\'s Picks',
  '🔥 Trending Today',
  'Just Released',
  'Editor\'s Choice',
  'Weekend Picks',
  '18 New Trailers',
  'Oscar Season',
  'Comic-Con Special',
];

class AnimatedLogoGlow extends StatefulWidget {
  const AnimatedLogoGlow({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedLogoGlow> createState() => _AnimatedLogoGlowState();
}

class _AnimatedLogoGlowState extends State<AnimatedLogoGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.07, end: 0.14).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -20,
              right: -20,
              top: -8,
              bottom: -8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: _opacity.value),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/TrailerBaaz6.png',
      height: kHeaderLogoHeight,
      fit: BoxFit.contain,
    );
  }
}

class HeaderSubtitle extends StatelessWidget {
  const HeaderSubtitle({super.key, required this.subtitle});
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AnimatedFadeSwitcher(
      child: Text(
        subtitle,
        key: ValueKey(subtitle),
        style: const TextStyle(
          color: Color(0xB2FFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.2,
        ),
      ),
    );
  }
}

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    this.subtitle,
    this.topPadding = 0,
  });

  final String? subtitle;
  final double topPadding;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int _subtitleIndex = 0;
  Timer? _subtitleTimer;

  String get _currentSubtitle =>
      widget.subtitle ?? kSubtitlePlaceholders[_subtitleIndex];

  @override
  void initState() {
    super.initState();
    if (widget.subtitle == null) {
      _subtitleTimer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted) return;
        setState(() {
          _subtitleIndex =
              (_subtitleIndex + 1) % kSubtitlePlaceholders.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Unified top gradient, no curves at the bottom, just a smooth fade
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xE6000000),
            Color(0x99000000),
            Color(0x1A000000),
            Colors.transparent,
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: widget.topPadding + 0.5,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: Logo + Subtitle ───────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedLogoGlow(child: const HeaderLogo()),
              const SizedBox(height: 2),
              HeaderSubtitle(subtitle: _currentSubtitle),
            ],
          ),

          const Spacer(),
          
          // ── Right: Notification Bell ────────────────────────────────
          const NotificationBadge(),
          const SizedBox(width: 16),

          // ── Right: Profile Avatar ───────────────────────────────────
          const _HeaderAvatar(),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => locator<NavigationService>().setShellTab(
        context,
        ShellTab.profile,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(
              color: Color(0x38FFFFFF),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1FE50914),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: SizedBox(
            width: kHeaderAvatarSize,
            height: kHeaderAvatarSize,
            child: CinematicImage(
              url:
                  'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
            ),
          ),
        ),
      ),
    );
  }
}
