import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const logoIntro = Duration(milliseconds: 2000);
  static const reducedLogoIntro = Duration(milliseconds: 150);
  static const smallChange = Duration(milliseconds: 180);

  static const standardCurve = Curves.easeOutCubic;
  static const emphasizedCurve = Curves.easeInOutCubic;
}
