import 'package:flutter/material.dart';

class TrailerPlayerRoute extends PageRouteBuilder<void> {
  TrailerPlayerRoute({
    required WidgetBuilder builder,
    required String trailerId,
  }) : super(
         settings: RouteSettings(name: 'trailer-player:$trailerId'),
         transitionDuration: const Duration(milliseconds: 260),
         reverseTransitionDuration: const Duration(milliseconds: 200),
         opaque: true,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: CurvedAnimation(
               parent: animation,
               curve: Curves.easeOutCubic,
               reverseCurve: Curves.easeInCubic,
             ),
             child: child,
           );
         },
       );
}
