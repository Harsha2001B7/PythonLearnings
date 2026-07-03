import 'package:flutter/material.dart';

import 'empty_state.dart';

/// A pre-configured empty state for trailer lists.
///
/// Shows a [Icons.movie_filter_rounded] icon with a "No trailers available"
/// heading. Pass a custom [message] to override the copy (e.g.
/// "No related trailers").
class NoResults extends StatelessWidget {
  const NoResults({
    super.key,
    this.message = 'No trailers available',
  });

  /// Heading text. Defaults to "No trailers available".
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.movie_filter_rounded,
      title: message,
    );
  }
}
