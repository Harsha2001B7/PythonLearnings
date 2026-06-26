import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../discover/discover_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../preferences/preferences_screen.dart';
import '../search/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  static void setIndex(BuildContext context, int index) {
    context.findAncestorStateOfType<_AppShellState>()?.setIndex(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    SearchScreen(),
    PreferencesScreen(),
    ProfileScreen(),
  ];

  void setIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: SizedBox(
        height: 100 + MediaQuery.paddingOf(context).bottom,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CurvePainter(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 12, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _NavIcon(
                    icon: _index == 0 ? Icons.auto_awesome : Icons.home_rounded,
                    label: 'Home',
                    selected: _index == 0,
                    onTap: () => setIndex(0),
                  ),
                  _NavIcon(
                    icon: Icons.explore_outlined,
                    label: 'Discover',
                    selected: _index == 1,
                    onTap: () => setIndex(1),
                  ),
                  _NavIcon(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    selected: _index == 2,
                    onTap: () => setIndex(2),
                  ),
                  _NavIcon(
                    icon: Icons.tune_rounded,
                    label: 'Preferences',
                    selected: _index == 3,
                    onTap: () => setIndex(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Arc starts lower on the edges and curves up in the middle
    final path = Path()
      ..moveTo(0, 35)
      ..quadraticBezierTo(size.width / 2, -10, size.width, 35);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Fill below the arc
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = const Color(0xFF070A11) // Deep dark bluish-black
        ..style = PaintingStyle.fill,
    );

    // Fade the glow towards the edges
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF00E5FF),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, 40);

    // Glowing blurred line
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Sharp inner core line
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (selected)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00E5FF).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.1, 0.8],
                        ),
                      ),
                    ),
                  Icon(
                    icon,
                    color: selected ? Colors.white : Colors.white38,
                    size: selected ? 28 : 24,
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
            // To keep the layout balanced when unselected, add invisible space
            if (!selected) const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
