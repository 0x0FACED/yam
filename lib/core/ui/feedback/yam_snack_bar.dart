import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

class YamSnackBar extends StatefulWidget {
  const YamSnackBar({
    required this.message,
    this.actionLabel,
    this.onAction,
    this.visible = true,
    this.onHidden,
    this.onDisposed,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool visible;
  final VoidCallback? onHidden;
  final VoidCallback? onDisposed;

  @override
  State<YamSnackBar> createState() => _YamSnackBarState();
}

class _YamSnackBarState extends State<YamSnackBar> {
  bool _ready = false;
  bool _started = false;
  bool _hiddenNotified = false;

  @override
  void dispose() {
    widget.onDisposed?.call();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ready = true;
      if (!widget.visible) _notifyHidden();
    } else if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.visible) setState(() => _ready = true);
      });
    }
  }

  @override
  void didUpdateWidget(YamSnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.visible &&
        (!_ready || MediaQuery.disableAnimationsOf(context))) {
      _notifyHidden();
    }
  }

  void _notifyHidden() {
    if (_hiddenNotified || widget.visible) return;
    _hiddenNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.visible) widget.onHidden?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);
    final stack = MediaQuery.textScalerOf(context).scale(12) > 17;
    final messageWidget = Row(
      children: [
        Container(
          key: const ValueKey('yam-snack-bar-success-indicator'),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: semanticColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            widget.message,
            style: AppTypography.label.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
    final action = widget.actionLabel == null
        ? null
        : YamTextButton(
            label: widget.actionLabel!,
            onPressed: widget.onAction,
            tone: YamTextButtonTone.accent,
          );
    final message = action == null
        ? messageWidget
        : IgnorePointer(child: messageWidget);

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedOpacity(
        opacity: _ready && widget.visible ? 1 : 0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : widget.visible
            ? AppMotion.snackBarEnter
            : AppMotion.snackBarExit,
        curve: widget.visible ? AppMotion.standardCurve : AppMotion.exitCurve,
        onEnd: _notifyHidden,
        child: Semantics(
          liveRegion: true,
          container: true,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.42
                            : 0.16,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xxs,
                    AppSpacing.xxs,
                    AppSpacing.xxs,
                  ),
                  child: action == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxs,
                            vertical: AppSpacing.xs,
                          ),
                          child: message,
                        )
                      : stack
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xxs,
                                AppSpacing.xs,
                                AppSpacing.sm,
                                0,
                              ),
                              child: message,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: action,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: message),
                            const SizedBox(width: AppSpacing.xs),
                            action,
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final Map<OverlayState, _YamSnackBarHandle> _visibleSnackBars = {};

class _YamSnackBarHandle {
  _YamSnackBarHandle(this.overlay, this.reduceMotion);

  final OverlayState overlay;
  final bool reduceMotion;
  late final OverlayEntry entry;
  Timer? timer;
  bool visible = true;
  bool removed = false;

  void show(Duration duration) {
    overlay.insert(entry);
    timer = Timer(duration, dismiss);
  }

  void dismiss({bool immediately = false}) {
    if (removed) return;
    timer?.cancel();
    if (immediately || reduceMotion) {
      remove();
    } else if (visible) {
      visible = false;
      if (WidgetsBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!removed) entry.markNeedsBuild();
        });
        WidgetsBinding.instance.scheduleFrame();
      } else {
        entry.markNeedsBuild();
      }
    }
  }

  void onWidgetDisposed() {
    timer?.cancel();
    removed = true;
    if (identical(_visibleSnackBars[overlay], this)) {
      _visibleSnackBars.remove(overlay);
    }
  }

  void remove() {
    if (removed) return;
    removed = true;
    timer?.cancel();
    entry
      ..remove()
      ..dispose();
    if (identical(_visibleSnackBars[overlay], this)) {
      _visibleSnackBars.remove(overlay);
    }
  }
}

_YamSnackBarHandle _presentYamSnackBar({
  required BuildContext context,
  required String message,
  required Duration duration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _visibleSnackBars[overlay]?.dismiss(immediately: true);
  final handle = _YamSnackBarHandle(
    overlay,
    MediaQuery.disableAnimationsOf(context),
  );
  handle.entry = OverlayEntry(
    builder: (context) => Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom:
          MediaQuery.viewInsetsOf(context).bottom +
          MediaQuery.paddingOf(context).bottom +
          AppSpacing.md,
      child: IgnorePointer(
        ignoring: actionLabel == null,
        child: Material(
          color: Colors.transparent,
          child: YamSnackBar(
            message: message,
            visible: handle.visible,
            onHidden: handle.remove,
            onDisposed: handle.onWidgetDisposed,
            actionLabel: actionLabel,
            onAction: onAction == null
                ? null
                : () {
                    handle.dismiss();
                    onAction();
                  },
          ),
        ),
      ),
    ),
  );
  _visibleSnackBars[overlay] = handle;
  handle.show(duration);
  return handle;
}

/// Lets a new modal use the bottom of the screen without obscuring its CTA.
void dismissYamSnackBar(BuildContext context) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _visibleSnackBars[overlay]?.dismiss();
}

/// Success feedback stays above sheets and fades out when dismissed.
VoidCallback showYamSuccessSnackBar({
  required BuildContext context,
  required String message,
}) {
  final handle = _presentYamSnackBar(
    context: context,
    message: message,
    duration: const Duration(seconds: 2),
  );
  return handle.dismiss;
}

void showYamUndoSnackBar({
  required BuildContext context,
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  _presentYamSnackBar(
    context: context,
    message: message,
    duration: const Duration(seconds: 4),
    actionLabel: undoLabel,
    onAction: onUndo,
  );
}
