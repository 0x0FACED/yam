import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/buttons/yam_floating_actions.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/layout/yam_floating_layout.dart';

/// A bounded, scrollable sheet with optional viewport-overlay footer actions.
Future<T?> showYamActionSheet<T>({
  required BuildContext context,
  required String title,
  required String closeLabel,
  required List<Widget> Function(BuildContext, ValueChanged<T?>) content,
  Widget Function(BuildContext, ValueChanged<T?>)? actions,
}) {
  dismissYamSnackBar(context);
  ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  var closed = false;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (sheetContext) {
      void close(T? result) {
        if (closed || ModalRoute.of(sheetContext)?.isCurrent != true) return;
        closed = true;
        Navigator.of(sheetContext).pop(result);
      }

      Widget buildContent(double bottomClearance) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg + bottomClearance,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: AppTypography.sectionTitle),
                  ),
                ),
                YamIconButton(
                  icon: Icons.close_rounded,
                  tooltip: closeLabel,
                  surface: false,
                  onPressed: () => close(null),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...content(sheetContext, close),
          ],
        ),
      );

      return SafeArea(
        top: false,
        child: actions == null
            ? buildContent(0)
            : YamFloatingLayout(
                expand: false,
                contentBuilder: (context, bottomClearance) =>
                    buildContent(bottomClearance),
                floating: YamFloatingActions(
                  child: actions(sheetContext, close),
                ),
              ),
      );
    },
  );
}
