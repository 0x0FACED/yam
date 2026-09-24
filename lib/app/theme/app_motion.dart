import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const logoIntro = Duration(milliseconds: 1400);
  static const reducedLogoIntro = Duration(milliseconds: 150);
  static const smallChange = Duration(milliseconds: 180);
  static const onboardingPage = Duration(milliseconds: 260);
  static const entranceFade = Duration(milliseconds: 220);
  static const entranceStagger = Duration(milliseconds: 45);
  static const snackBarEnter = Duration(milliseconds: 220);
  static const snackBarExit = Duration(milliseconds: 180);
  static const diaryEntryHighlight = Duration(milliseconds: 1600);
  static const quantityHoldDelay = Duration(milliseconds: 400);
  static const quantityRepeatInitial = Duration(milliseconds: 140);
  static const quantityRepeatMedium = Duration(milliseconds: 85);
  static const quantityRepeatFast = Duration(milliseconds: 50);

  static const standardCurve = Curves.easeOutCubic;
  static const emphasizedCurve = Curves.easeInOutCubic;
  static const exitCurve = Curves.easeInCubic;
}
