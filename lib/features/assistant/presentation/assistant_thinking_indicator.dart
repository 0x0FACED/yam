import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

/// Mounted only while a request is active; no ticker survives its completion.
class AssistantThinkingIndicator extends StatefulWidget {
  const AssistantThinkingIndicator({super.key});

  @override
  State<AssistantThinkingIndicator> createState() =>
      _AssistantThinkingIndicatorState();
}

class _AssistantThinkingIndicatorState extends State<AssistantThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: AppMotion.assistantThinking,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion
        ..stop()
        ..value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).assistantThinking;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AnimatedBuilder(
            animation: _motion,
            child: SizedBox(
              width: AppSpacing.xl,
              height: AppSpacing.xxl,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset('assets/inapp/intro_batat_base.svg'),
                  SvgPicture.asset('assets/inapp/intro_mouth_closed.svg'),
                ],
              ),
            ),
            builder: (context, mascot) {
              final wave = math.sin(_motion.value * math.pi * 2);
              final pulse = (1 - math.cos(_motion.value * math.pi * 2)) / 2;
              return Row(
                children: [
                  Transform.translate(
                    offset: Offset(0, -AppSpacing.xxs * pulse),
                    child: Transform.rotate(angle: wave * 0.06, child: mascot),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Opacity(
                      opacity: 1 - pulse * 0.25,
                      child: Text(
                        label,
                        style: AppTypography.label.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
