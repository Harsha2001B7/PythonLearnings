import 'package:flutter/material.dart';

/// Shared hero tag for trailer backdrop shared-element transitions.
abstract final class TrailerHeroTags {
  static String backdrop(String trailerId) => 'backdrop-$trailerId';
}

/// Wraps [child] in a [Hero] for home → details backdrop continuity.
class TrailerBackdropHero extends StatelessWidget {
  const TrailerBackdropHero({
    super.key,
    required this.trailerId,
    required this.child,
  });

  final String trailerId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: TrailerHeroTags.backdrop(trailerId),
      child: child,
    );
  }
}
