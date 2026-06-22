import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.favorite_rounded,
        title: 'Saved',
      ),
    );
  }
}
