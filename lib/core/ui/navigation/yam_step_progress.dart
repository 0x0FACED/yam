import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

class YamStepProgress extends StatelessWidget {
  const YamStepProgress({
    required this.step,
    required this.totalSteps,
    required this.stepLabel,
    required this.leadingTooltip,
    required this.leadingIcon,
    required this.onLeadingPressed,
    this.showLeading = true,
    super.key,
  });

  final int step;
  final int totalSteps;
  final String stepLabel;
  final String leadingTooltip;
  final IconData leadingIcon;
  final VoidCallback onLeadingPressed;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.onboardingPage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (showLeading)
              YamIconButton(
                icon: leadingIcon,
                tooltip: leadingTooltip,
                onPressed: onLeadingPressed,
                surface: false,
                iconSize: 20,
              )
            else
              const SizedBox.square(dimension: 44),
            Expanded(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      stepLabel,
                      style: AppTypography.label.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xxl),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: stepLabel,
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var index = 0; index < totalSteps; index++) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: index < step ? 1 : 0),
                      duration: duration,
                      curve: AppMotion.standardCurve,
                      builder: (context, fill, child) => ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: SizedBox(
                          height: AppSpacing.xxs,
                          child: LayoutBuilder(
                            builder: (context, constraints) => Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: colors.surfaceContainer,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: constraints.maxWidth * fill,
                                  child: ColoredBox(color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
