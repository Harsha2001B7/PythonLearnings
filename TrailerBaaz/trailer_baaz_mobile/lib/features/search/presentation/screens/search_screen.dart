import 'package:flutter/material.dart';

import '../../../../shared/widgets/coming_soon_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComingSoonWidget(
        icon: Icons.search_rounded,
        title: 'Search',
      ),
    );
  }
}
