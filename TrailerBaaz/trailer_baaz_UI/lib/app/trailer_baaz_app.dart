import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import 'app_theme.dart';
import '../main.dart';

class TrailerBaazApp extends StatelessWidget {
  const TrailerBaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailerBaaz',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}
