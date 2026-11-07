import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_elevation.dart';
import 'package:yam/app/theme/app_spacing.dart';

/// Spacing and button shadows only; never a background panel or footer.
class YamFloatingActions extends StatelessWidget {
  const YamFloatingActions({
    required this.child,
    this.margin = const EdgeInsets.all(AppSpacing.sm),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = AppElevation.floatingShadow(theme.colorScheme);
    final elevation = ButtonStyle(
      elevation: const WidgetStatePropertyAll(AppElevation.floatingAction),
      shadowColor: WidgetStatePropertyAll(shadow),
    );
    return Padding(
      padding: margin,
      child: Theme(
        data: theme.copyWith(
          filledButtonTheme: FilledButtonThemeData(
            style: theme.filledButtonTheme.style?.merge(elevation) ?? elevation,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style:
                theme.outlinedButtonTheme.style?.merge(elevation) ?? elevation,
          ),
          textButtonTheme: TextButtonThemeData(
            style: (theme.textButtonTheme.style ?? const ButtonStyle()).merge(
              elevation.copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  theme.colorScheme.surface,
                ),
              ),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
