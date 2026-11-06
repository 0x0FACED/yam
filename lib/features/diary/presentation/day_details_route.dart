import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';

/// Keeps the destination at its final layout size while its surface expands.
/// The summary Hero flies independently, so text is never scaled as a bitmap.
class DayDetailsRoute extends PageRouteBuilder<void> {
  DayDetailsRoute({
    required WidgetBuilder builder,
    required Rect Function() sourceRect,
    required bool reduceMotion,
  }) : super(
         settings: const RouteSettings(name: 'day-details'),
         transitionDuration: reduceMotion
             ? Duration.zero
             : AppMotion.dayDetailsExpansion,
         reverseTransitionDuration: reduceMotion
             ? Duration.zero
             : AppMotion.dayDetailsExpansion,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (MediaQuery.disableAnimationsOf(context)) return child;
           return LayoutBuilder(
             builder: (context, constraints) => AnimatedBuilder(
               animation: animation,
               child: child,
               builder: (context, child) {
                 final progress = AppMotion.emphasizedCurve.transform(
                   animation.value,
                 );
                 final rect = Rect.lerp(
                   sourceRect(),
                   Offset.zero & constraints.biggest,
                   progress,
                 )!;
                 return ClipPath(
                   clipper: _ExpandingSurfaceClipper(
                     rect,
                     AppRadius.card * (1 - progress),
                   ),
                   child: ColoredBox(
                     color: Theme.of(context).colorScheme.surface,
                     child: Opacity(
                       opacity: const Interval(
                         0.15,
                         1,
                         curve: AppMotion.standardCurve,
                       ).transform(animation.value),
                       child: child,
                     ),
                   ),
                 );
               },
             ),
           );
         },
       );
}

class _ExpandingSurfaceClipper extends CustomClipper<Path> {
  const _ExpandingSurfaceClipper(this.rect, this.radius);

  final Rect rect;
  final double radius;

  @override
  Path getClip(Size size) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  @override
  bool shouldReclip(_ExpandingSurfaceClipper oldClipper) =>
      rect != oldClipper.rect || radius != oldClipper.radius;
}
