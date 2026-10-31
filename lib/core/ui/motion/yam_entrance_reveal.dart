import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_motion.dart';

class YamEntranceScope extends InheritedWidget {
  const YamEntranceScope({
    required this.epoch,
    required super.child,
    super.key,
  });

  final int epoch;

  static int? maybeEpochOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<YamEntranceScope>()?.epoch;

  @override
  bool updateShouldNotify(YamEntranceScope oldWidget) =>
      epoch != oldWidget.epoch;
}

class YamEntranceReveal extends StatefulWidget {
  const YamEntranceReveal({
    required this.index,
    required this.child,
    this.replayKey,
    this.ready = true,
    super.key,
  });

  final int index;
  final Widget child;
  final Object? replayKey;
  final bool ready;

  @override
  State<YamEntranceReveal> createState() => _YamEntranceRevealState();
}

class _YamEntranceRevealState extends State<YamEntranceReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _opacity;
  Timer? _timer;
  int? _epoch;
  int _generation = 0;
  bool _reduceMotion = false;
  bool _active = true;
  bool _hasDependencies = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.entranceFade,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final epoch = YamEntranceScope.maybeEpochOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final active = TickerMode.of(context);
    final changed =
        !_hasDependencies ||
        epoch != _epoch ||
        reduceMotion != _reduceMotion ||
        active != _active;
    _epoch = epoch;
    _reduceMotion = reduceMotion;
    _active = active;
    _hasDependencies = true;
    if (changed) _restart();
  }

  @override
  void didUpdateWidget(YamEntranceReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.replayKey != widget.replayKey ||
        oldWidget.ready != widget.ready) {
      _restart();
    }
  }

  void _restart() {
    final generation = ++_generation;
    _timer?.cancel();
    _timer = null;

    if (!widget.ready || !_active) {
      _controller.value = 0;
      return;
    }
    if (_reduceMotion || (_epoch == null && widget.replayKey == null)) {
      _controller.value = 1;
      return;
    }

    _controller.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_canReveal(generation)) return;
      final delay = AppMotion.entranceStagger * widget.index;
      if (delay == Duration.zero) {
        _controller.forward();
      } else {
        _timer = Timer(delay, () {
          if (_canReveal(generation)) _controller.forward();
        });
      }
    });
  }

  bool _canReveal(int generation) =>
      mounted &&
      generation == _generation &&
      widget.ready &&
      _active &&
      !_reduceMotion;

  @override
  void dispose() {
    _timer?.cancel();
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}
