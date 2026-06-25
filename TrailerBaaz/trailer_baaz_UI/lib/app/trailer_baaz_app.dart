import 'package:flutter/material.dart';

import '../features/shell/app_shell.dart';
import 'app_theme.dart';

class TrailerBaazApp extends StatelessWidget {
  const TrailerBaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailerBaaz',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
