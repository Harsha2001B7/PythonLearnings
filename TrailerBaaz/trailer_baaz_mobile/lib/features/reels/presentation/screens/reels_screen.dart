import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.movie_filter_rounded,
        title: 'Reels',
      ),
    );
  }
}
