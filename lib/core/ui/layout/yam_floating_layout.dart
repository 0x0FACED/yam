import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_spacing.dart';

/// Keeps the scroll viewport behind its floating controls. The caller owns
/// safe-area/keyboard insets and adds the clearance to scroll end padding.
class YamFloatingLayout extends StatefulWidget {
  const YamFloatingLayout({
    required this.contentBuilder,
    required this.floating,
    this.expand = true,
    this.inset = AppSpacing.md,
    super.key,
  });

  final Widget Function(BuildContext context, double bottomClearance)
  contentBuilder;
  final Widget floating;

  /// False preserves a modal sheet's natural height until its viewport fills.
  final bool expand;

  /// Space around the overlay; child padding can reserve room for its shadow.
  final double inset;

  @override
  State<YamFloatingLayout> createState() => _YamFloatingLayoutState();
}

class _YamFloatingLayoutState extends State<YamFloatingLayout> {
  final _floatingKey = GlobalKey();
  double _floatingHeight = 0;
  bool _measurementPending = false;

  @override
  void initState() {
    super.initState();
    _measureAfterLayout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measureAfterLayout();
  }

  void _measureAfterLayout() {
    if (_measurementPending) return;
    _measurementPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementPending = false;
      if (!mounted) return;
      final box = _floatingKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final height = box.size.height;
      if ((height - _floatingHeight).abs() > 0.1) {
        setState(() => _floatingHeight = height);
      }
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      fit: widget.expand ? StackFit.expand : StackFit.loose,
      children: [
        widget.contentBuilder(
          context,
          _floatingHeight + widget.inset + AppSpacing.md,
        ),
        Positioned(
          left: widget.inset,
          right: widget.inset,
          bottom: widget.inset,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.max(0, constraints.maxHeight - widget.inset),
            ),
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (_) {
                _measureAfterLayout();
                return false;
              },
              child: SizeChangedLayoutNotifier(
                key: _floatingKey,
                child: SingleChildScrollView(
                  primary: false,
                  hitTestBehavior: HitTestBehavior.deferToChild,
                  child: widget.floating,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
