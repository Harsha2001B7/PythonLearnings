import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/config/youtube_api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/data/mock/home_dummy_data.dart';
import '../../../../features/reels/data/mock/reels_dummy_data.dart';
import '../../../../navigation/bottom_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      HomeDummyData.preload(apiKey: YoutubeApiConfig.apiKey),
      ReelsDummyData.preload(apiKey: YoutubeApiConfig.apiKey),
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryRed.withValues(alpha: 0.4),
                ),
              ),
              child: Image.asset(
                'assets/images/trailerbaaz_logo.png',
                width: 220,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TrailerBaaz',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your trailer universe starts here',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
