import 'package:flutter/material.dart';

import '../animations/animations.dart';

class TrailerPlayerRoute extends PageRouteBuilder<void> {
  TrailerPlayerRoute({
    required WidgetBuilder builder,
    required String trailerId,
  }) : super(
         settings: RouteSettings(name: 'trailer-player:$trailerId'),
         transitionDuration: AppMotion.routePlayerForward,
         reverseTransitionDuration: AppMotion.routePlayerReverse,
         opaque: true,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return AppPageTransitions.curvedFade(
             animation: animation,
             child: child,
           );
         },
       );
}
