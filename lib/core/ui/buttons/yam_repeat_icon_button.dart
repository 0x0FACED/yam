import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

/// A one-step tap with accelerating one-step repetition while held.
class YamRepeatIconButton extends StatefulWidget {
  const YamRepeatIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<YamRepeatIconButton> createState() => _YamRepeatIconButtonState();
}

class _YamRepeatIconButtonState extends State<YamRepeatIconButton> {
  Timer? _timer;
  final _holdClock = Stopwatch();
  var _didRepeat = false;
  var _pressed = false;
  int? _activePointer;
  Offset? _downPosition;

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _start(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton || _activePointer != null) return;
    _stop();
    _activePointer = event.pointer;
    _downPosition = event.position;
    _pressed = true;
    _didRepeat = false;
    _holdClock
      ..reset()
      ..start();
    _timer = Timer(AppMotion.quantityHoldDelay, () {
      if (!_pressed || !mounted) return;
      _didRepeat = true;
      widget.onPressed();
      _repeat();
    });
  }

  void _repeat() {
    if (!_pressed || !mounted) return;
    final elapsed = _holdClock.elapsed;
    final interval = elapsed < const Duration(seconds: 1)
        ? AppMotion.quantityRepeatInitial
        : elapsed < const Duration(seconds: 2)
        ? AppMotion.quantityRepeatMedium
        : AppMotion.quantityRepeatFast;
    _timer = Timer(interval, () {
      if (!_pressed || !mounted) return;
      widget.onPressed();
      _repeat();
    });
  }

  void _stop() {
    _pressed = false;
    _activePointer = null;
    _downPosition = null;
    _timer?.cancel();
    _timer = null;
    _holdClock.stop();
  }

  void _release(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _stop();
    // IconButton dispatches its tap after pointer-up. Keep the repeat flag for
    // that dispatch so a long hold never produces one extra step on release.
    scheduleMicrotask(() => _didRepeat = false);
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;
    if ((event.position - _downPosition!).distance > kTouchSlop) {
      _stop();
      _didRepeat = false;
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _start,
    onPointerMove: _move,
    onPointerUp: _release,
    onPointerCancel: _release,
    child: YamIconButton(
      icon: widget.icon,
      tooltip: widget.tooltip,
      onPressed: () {
        if (!_didRepeat) widget.onPressed();
      },
      iconSize: 19,
      visualSize: 36,
      visualBorderRadius: AppRadius.small,
    ),
  );
}
