import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamTextField extends StatefulWidget {
  const YamTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.fieldKey,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    super.key,
  });

  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Key? fieldKey;
  final int? minLines;
  final int? maxLines;
  final bool obscureText;

  @override
  State<YamTextField> createState() => _YamTextFieldState();
}

class _YamTextFieldState extends State<YamTextField> {
  final _inputKey = GlobalKey();
  PointerDownEvent? _pointerDown;
  PointerDownEvent? _lastTap;
  Duration _lastTapUpTime = Duration.zero;
  Duration _pointerUpTime = Duration.zero;
  int _tapCount = 0;
  bool _normalizeSeries = false;
  bool _shiftTap = false;
  TextSelection? _selectionBeforeTap;
  TextSelection? _shiftSelection;
  _PreciseTapSelection? _selection;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    // Capture before a native multi-tap can replace the Shift-click anchor.
    _shiftSelection = HardwareKeyboard.instance.isShiftPressed
        ? widget.controller.selection
        : null;
    return false;
  }

  @override
  void didUpdateWidget(YamTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) _shiftSelection = null;
    if (oldWidget.fieldKey != widget.fieldKey) {
      _selection = null;
      _lastTap = null;
      _normalizeSeries = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = event;
    _pointerUpTime = event.timeStamp;
    _shiftTap = HardwareKeyboard.instance.isShiftPressed;
    _selectionBeforeTap = _shiftTap
        ? _shiftSelection ?? widget.controller.selection
        : widget.controller.selection;
    if (event.buttons != kPrimaryButton) {
      _lastTap = null;
      _normalizeSeries = false;
      return;
    }
    final previous = _lastTap;
    final elapsed = previous == null ? null : event.timeStamp - _lastTapUpTime;
    final inTime =
        elapsed != null &&
        elapsed >= Duration.zero &&
        elapsed <= kDoubleTapTimeout &&
        event.kind == previous!.kind &&
        event.buttons == previous.buttons;
    final slop = event.kind == PointerDeviceKind.mouse
        ? kDoubleTapTouchSlop
        : computeHitSlop(event.kind, MediaQuery.gestureSettingsOf(context));
    final nearby =
        previous != null &&
        (event.position - previous.position).distanceSquared <= slop * slop;
    _tapCount = !_shiftTap && inTime && nearby ? _tapCount + 1 : 1;
    // Flutter's 100px multi-tap radius also groups attempts to move the caret.
    // Keep normal gestures untouched until the two tap sequences diverge.
    _normalizeSeries = _shiftTap || inTime && (_normalizeSeries || !nearby);
    if (_normalizeSeries) {
      if (_selection == null || !_selection!.isMounted) {
        _selection = _findSelection(_inputKey.currentContext! as Element)!;
      }
      _selection!.tapDown(event, _tapCount);
    }
  }

  _PreciseTapSelection? _findSelection(Element element) {
    if (element is StatefulElement &&
        element.state is TextSelectionGestureDetectorBuilderDelegate) {
      return _PreciseTapSelection(
        delegate: element.state as TextSelectionGestureDetectorBuilderDelegate,
      );
    }
    _PreciseTapSelection? result;
    element.visitChildren((child) {
      result ??= _findSelection(child);
    });
    return result;
  }

  void _onTap() {
    final event = _pointerDown;
    if (event == null) return;
    if (_normalizeSeries) {
      if (_shiftTap) {
        widget.controller.selection = _selectionBeforeTap!;
        _selection!.restoreSelection(_selectionBeforeTap!);
      }
      _selection!.tapUp(event, _tapCount);
      if (_shiftTap) _shiftSelection = widget.controller.selection;
    }
    _lastTap = event;
    _lastTapUpTime = _pointerUpTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    final strokeWidth =
        (theme.inputDecorationTheme.focusedBorder ?? border).borderSide.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Listener(
          key: _inputKey,
          onPointerDown: _onPointerDown,
          onPointerUp: (event) => _pointerUpTime = event.timeStamp,
          onPointerCancel: (_) {
            _lastTap = null;
            _normalizeSeries = false;
          },
          child: ScrollConfiguration(
            behavior: widget.maxLines == 1
                ? _TextFieldScrollBehavior(
                    AppSpacing.md + border.gapPadding - strokeWidth,
                  )
                : ScrollConfiguration.of(context),
            child: TextField(
              key: widget.fieldKey,
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autocorrect: !widget.obscureText,
              enableSuggestions: !widget.obscureText,
              inputFormatters: widget.inputFormatters,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTapAlwaysCalled: true,
              onTap: _onTap,
              clipBehavior: widget.maxLines == 1 ? Clip.none : Clip.hardEdge,
              style: AppTypography.productTitle.copyWith(
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: widget.errorText,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: border,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Clip only the editable viewport, not the decoration. This lets text pass
// through the horizontal padding without painting over the outline or errors.
class _TextFieldScrollBehavior extends MaterialScrollBehavior {
  const _TextFieldScrollBehavior(this.horizontalOverflow);

  final double horizontalOverflow;

  @override
  ScrollBehavior copyWith({
    bool? scrollbars,
    bool? overscroll,
    Set<PointerDeviceKind>? dragDevices,
    MultitouchDragStrategy? multitouchDragStrategy,
    Set<LogicalKeyboardKey>? pointerAxisModifiers,
    ScrollPhysics? physics,
    TargetPlatform? platform,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
  }) => super.copyWith(
    scrollbars: scrollbars,
    // EditableText disables indicators; retain our clipping-only chrome.
    overscroll: true,
    dragDevices: dragDevices,
    multitouchDragStrategy: multitouchDragStrategy,
    pointerAxisModifiers: pointerAxisModifiers,
    physics: physics,
    platform: platform,
    keyboardDismissBehavior: keyboardDismissBehavior,
  );

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      ClipRect(clipper: _TextViewportClipper(horizontalOverflow), child: child);

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class _TextViewportClipper extends CustomClipper<Rect> {
  const _TextViewportClipper(this.horizontalOverflow);

  final double horizontalOverflow;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    -horizontalOverflow,
    0,
    size.width + horizontalOverflow,
    size.height,
  );

  @override
  bool shouldReclip(_TextViewportClipper oldClipper) =>
      oldClipper.horizontalOverflow != horizontalOverflow;
}

// Reuse Flutter's platform-specific word/line/paragraph selection rather than
// replacing TextField or disabling its long-press, drag and keyboard gestures.
class _PreciseTapSelection extends TextSelectionGestureDetectorBuilder {
  _PreciseTapSelection({required super.delegate});

  bool get isMounted => delegate.editableTextKey.currentState != null;

  void restoreSelection(TextSelection selection) {
    renderEditable.selection = selection;
  }

  int _effectiveCount(int count) => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.fuchsia ||
    TargetPlatform.linux => (count - 1) % 3 + 1,
    TargetPlatform.iOS || TargetPlatform.macOS => count.clamp(1, 3),
    TargetPlatform.windows => count < 2 ? count : 2 + count % 2,
  };

  void tapDown(PointerDownEvent event, int count) {
    onTapTrackStart();
    onTapDown(_details(event, count));
    switch (_effectiveCount(count)) {
      case 1:
        if (!HardwareKeyboard.instance.isShiftPressed) {
          editableText.hideToolbar();
          renderEditable.selectPositionAt(
            from: event.position,
            cause: SelectionChangedCause.tap,
          );
        }
      case 2:
        onDoubleTapDown(_details(event, count));
      case 3:
        onTripleTapDown(_details(event, count));
    }
  }

  void tapUp(PointerDownEvent event, int count) {
    // The built-in recognizer can dispatch a different tap count on pointer-up.
    // Reapply the corrected count after that callback, including after a rebase.
    tapDown(event, count);
    if (_effectiveCount(count) == 1) {
      onSingleTapUp(
        TapDragUpDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
          kind: event.kind,
          consecutiveTapCount: count,
        ),
      );
    }
    onTapTrackReset();
  }

  TapDragDownDetails _details(PointerDownEvent event, int count) =>
      TapDragDownDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
        consecutiveTapCount: count,
      );
}
