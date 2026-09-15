import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({
    required this.semanticsLabel,
    required this.onFinished,
    this.artwork,
    super.key,
  });

  final String semanticsLabel;
  final VoidCallback onFinished;
  final StartupArtwork? artwork;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  bool _reduceMotion = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (!_started) {
      _started = true;
      _reduceMotion = reduceMotion;
      _controller.duration = reduceMotion
          ? AppMotion.reducedLogoIntro
          : AppMotion.logoIntro;
      _controller.forward();
      return;
    }

    if (reduceMotion && !_reduceMotion && !_finished) {
      _reduceMotion = true;
      _controller.animateTo(
        1,
        duration: AppMotion.reducedLogoIntro,
        curve: AppMotion.standardCurve,
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _finished) {
      return;
    }
    _finished = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      child: ColoredBox(
        color: AppColors.brandCream,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _reduceMotion
                  ? _ReducedMotionLogo(
                      progress: _controller,
                      artwork: widget.artwork,
                    )
                  : _IntroScene(progress: _controller, artwork: widget.artwork),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroScene extends StatelessWidget {
  const _IntroScene({required this.progress, required this.artwork});

  final Animation<double> progress;
  final StartupArtwork? artwork;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 300,
        height: 340,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, child) {
            final value = progress.value;
            final entrance = _curvedInterval(value, 0, 0.16);
            final exit = 1 - _curvedInterval(value, 0.94, 1);
            final chew = math.max(
              _pulse(value, 0.38, 0.035),
              math.max(_pulse(value, 0.58, 0.035), _pulse(value, 0.78, 0.035)),
            );
            final mascotScale = lerpDouble(0.88, 1, entrance)! + chew * 0.025;
            final mouthOpen = _mouthOpenAmount(value);

            return Opacity(
              opacity: entrance * exit,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 45,
                    top: 75,
                    width: 210,
                    height: 250,
                    child: Transform.scale(
                      scale: mascotScale,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ArtworkPicture(
                            asset: StartupArtwork.mascot,
                            picture: artwork?.pictureFor(StartupArtwork.mascot),
                            key: const ValueKey('startup-mascot'),
                          ),
                          Opacity(
                            opacity: 1 - mouthOpen,
                            child: _ArtworkPicture(
                              asset: StartupArtwork.mouthClosed,
                              picture: artwork?.pictureFor(
                                StartupArtwork.mouthClosed,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: mouthOpen,
                            child: _ArtworkPicture(
                              asset: StartupArtwork.mouthOpen,
                              picture: artwork?.pictureFor(
                                StartupArtwork.mouthOpen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _AnimatedLetter(
                    asset: StartupArtwork.letterY,
                    picture: artwork?.pictureFor(StartupArtwork.letterY),
                    width: 78,
                    start: const Offset(12, -4),
                    control: const Offset(48, 98),
                    target: const Offset(124, 176),
                    initialAngle: -0.10,
                    begin: 0.16,
                    end: 0.38,
                    progress: value,
                  ),
                  _AnimatedLetter(
                    asset: StartupArtwork.letterA,
                    picture: artwork?.pictureFor(StartupArtwork.letterA),
                    width: 79,
                    start: const Offset(108, -22),
                    control: const Offset(150, 76),
                    target: const Offset(124, 176),
                    initialAngle: 0.08,
                    begin: 0.36,
                    end: 0.58,
                    progress: value,
                  ),
                  _AnimatedLetter(
                    asset: StartupArtwork.letterM,
                    picture: artwork?.pictureFor(StartupArtwork.letterM),
                    width: 110,
                    start: const Offset(190, -2),
                    control: const Offset(218, 98),
                    target: const Offset(108, 176),
                    initialAngle: -0.07,
                    begin: 0.56,
                    end: 0.78,
                    progress: value,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.asset,
    required this.picture,
    required this.width,
    required this.start,
    required this.control,
    required this.target,
    required this.initialAngle,
    required this.begin,
    required this.end,
    required this.progress,
  });

  final String asset;
  final PictureInfo? picture;
  final double width;
  final Offset start;
  final Offset control;
  final Offset target;
  final double initialAngle;
  final double begin;
  final double end;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final travel = _curvedInterval(progress, begin, end);
    final position = _quadraticBezier(start, control, target, travel);
    final shrink = _curvedInterval(travel, 0.38, 1);
    final scale = lerpDouble(1, 0.08, shrink)!;
    final angle = lerpDouble(initialAngle, 0, travel)!;
    final opacity =
        _interval(travel, 0, 0.08) * (1 - _curvedInterval(travel, 0.78, 1));

    return Positioned(
      left: start.dx,
      top: start.dy,
      width: width,
      height: 112,
      child: Transform.translate(
        offset: position - start,
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: _ArtworkPicture(asset: asset, picture: picture),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReducedMotionLogo extends StatelessWidget {
  const _ReducedMotionLogo({required this.progress, required this.artwork});

  final Animation<double> progress;
  final StartupArtwork? artwork;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: progress,
        curve: AppMotion.standardCurve,
      ),
      child: SizedBox(
        width: 320,
        child: _ArtworkPicture(
          asset: StartupArtwork.fullLogo,
          picture: artwork?.pictureFor(StartupArtwork.fullLogo),
        ),
      ),
    );
  }
}

class _ArtworkPicture extends StatelessWidget {
  const _ArtworkPicture({
    required this.asset,
    required this.picture,
    super.key,
  });

  final String asset;
  final PictureInfo? picture;

  @override
  Widget build(BuildContext context) {
    final picture = this.picture;
    return RepaintBoundary(
      child: picture == null
          ? SvgPicture.asset(asset, excludeFromSemantics: true)
          : CustomPaint(painter: _PicturePainter(picture)),
    );
  }
}

class _PicturePainter extends CustomPainter {
  const _PicturePainter(this.pictureInfo);

  final PictureInfo pictureInfo;

  @override
  void paint(Canvas canvas, Size size) {
    final sourceSize = pictureInfo.size;
    final scale = math.min(
      size.width / sourceSize.width,
      size.height / sourceSize.height,
    );
    final offset = Offset(
      (size.width - sourceSize.width * scale) / 2,
      (size.height - sourceSize.height * scale) / 2,
    );

    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..drawPicture(pictureInfo.picture)
      ..restore();
  }

  @override
  bool shouldRepaint(_PicturePainter oldDelegate) {
    return oldDelegate.pictureInfo.picture != pictureInfo.picture;
  }
}

double _mouthOpenAmount(double progress) {
  if (progress < 0.12) {
    return 0;
  }
  if (progress < 0.18) {
    return _curvedInterval(progress, 0.12, 0.18);
  }
  if (progress < 0.80) {
    return 1;
  }
  return 1 - _curvedInterval(progress, 0.80, 0.86);
}

double _pulse(double value, double center, double halfWidth) {
  final distance = ((value - center) / halfWidth).abs();
  if (distance >= 1) {
    return 0;
  }
  return Curves.easeOut.transform(1 - distance);
}

Offset _quadraticBezier(
  Offset start,
  Offset control,
  Offset end,
  double progress,
) {
  final inverse = 1 - progress;
  return start * (inverse * inverse) +
      control * (2 * inverse * progress) +
      end * (progress * progress);
}

double _curvedInterval(double value, double begin, double end) {
  return AppMotion.emphasizedCurve.transform(_interval(value, begin, end));
}

double _interval(double value, double begin, double end) {
  return ((value - begin) / (end - begin)).clamp(0.0, 1.0);
}
