import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.home_rounded,
        title: 'Home',
      ),
    );
  }
}
