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
    super.key,
  });

  final int index;
  final Widget child;

  @override
  State<YamEntranceReveal> createState() => _YamEntranceRevealState();
}

class _YamEntranceRevealState extends State<YamEntranceReveal> {
  Timer? _timer;
  int? _epoch;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final epoch = YamEntranceScope.maybeEpochOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (epoch == null) {
      _timer?.cancel();
      _epoch = null;
      _visible = true;
      return;
    }
    if (_epoch == epoch && !(reduceMotion && !_visible)) return;
    _epoch = epoch;
    _timer?.cancel();
    _visible = reduceMotion;
    if (reduceMotion) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _epoch != epoch) return;
      _timer = Timer(AppMotion.entranceStagger * widget.index, () {
        if (mounted) setState(() => _visible = true);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.entranceFade,
      curve: AppMotion.standardCurve,
      child: widget.child,
    );
  }
}
