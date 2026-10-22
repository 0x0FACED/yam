import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_goal_slider_field.dart';
import 'package:yam/core/ui/forms/yam_number_field.dart';
import 'package:yam/core/ui/navigation/yam_step_progress.dart';
import 'package:yam/core/ui/selection/yam_choice_card.dart';
import 'package:yam/features/backup/data/backup_file_service.dart';
import 'package:yam/features/backup/data/backup_repository.dart';
import 'package:yam/features/backup/presentation/backup_settings_section.dart';
import 'package:yam/features/onboarding/presentation/onboarding_input.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.initialProfile,
    this.initialWeightKg,
    this.requiredFirstRun = false,
    this.onClose,
    this.backupRepository,
    this.backupFiles,
    this.onBackupImported,
    required this.onCompleted,
    super.key,
  });

  final SessionProfile? initialProfile;
  final double? initialWeightKg;
  final bool requiredFirstRun;
  final VoidCallback? onClose;
  final BackupRepository? backupRepository;
  final BackupFileService? backupFiles;
  final VoidCallback? onBackupImported;
  final FutureOr<void> Function(SessionProfile) onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  late final TextEditingController _currentWeight;
  late final TextEditingController _targetWeight;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _fat;
  late final TextEditingController _carbs;
  WeightGoal? _goal;
  late OnboardingInput _input;
  int _step = 0;
  bool _weightErrors = false;
  bool _nutritionErrors = false;
  bool _transitioning = false;
  bool _localizedWeights = false;
  bool _goalError = false;
  bool _saving = false;
  bool _restoring = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _goal = profile?.goal;
    _currentWeight = TextEditingController(
      text: profile?.currentWeightKg != null || widget.initialWeightKg != null
          ? _weightText(profile?.currentWeightKg ?? widget.initialWeightKg!)
          : '',
    );
    _targetWeight = TextEditingController(
      text: profile == null ? '' : _weightText(profile.targetWeightKg),
    );
    _calories = TextEditingController(
      text: profile?.calorieTarget.toString() ?? '',
    );
    _protein = TextEditingController(
      text: profile?.proteinTarget.toString() ?? '',
    );
    _fat = TextEditingController(text: profile?.fatTarget.toString() ?? '');
    _carbs = TextEditingController(text: profile?.carbsTarget.toString() ?? '');
    _refreshInput();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizedWeights) return;
    _localizedWeights = true;
    final separator = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).symbols.DECIMAL_SEP;
    if (separator != '.') {
      _currentWeight.text = _currentWeight.text.replaceAll('.', separator);
      _targetWeight.text = _targetWeight.text.replaceAll('.', separator);
      _refreshInput();
    }
  }

  static String _weightText(double value) =>
      value.toString().replaceFirst(RegExp(r'\.0$'), '');

  void _refreshInput() {
    _input = OnboardingInput(
      goal: _goal,
      currentWeight: _currentWeight.text,
      targetWeight: _targetWeight.text,
      calories: _calories.text,
      protein: _protein.text,
      fat: _fat.text,
      carbs: _carbs.text,
    );
  }

  void _onInputChanged(String _) => setState(_refreshInput);

  void _setMacroAmount(TextEditingController controller, int amount) {
    if (controller.text == '$amount') return;
    controller.value = TextEditingValue(
      text: '$amount',
      selection: TextSelection.collapsed(offset: '$amount'.length),
    );
    setState(_refreshInput);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentWeight.dispose();
    _targetWeight.dispose();
    _calories.dispose();
    _protein.dispose();
    _fat.dispose();
    _carbs.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int step) async {
    if (_transitioning || _restoring) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _transitioning = true;
    setState(() => _step = step);
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(step);
    } else {
      await _pageController.animateToPage(
        step,
        duration: AppMotion.onboardingPage,
        curve: AppMotion.emphasizedCurve,
      );
    }
    _transitioning = false;
  }

  Future<void> _continue() async {
    if (_transitioning || _saving || _restoring) return;
    if (_step == 0) {
      if (_goal == null) {
        setState(() => _goalError = true);
        return;
      }
      _goToStep(1);
      return;
    }
    if (_step == 1) {
      if (!_input.validWeight) {
        setState(() => _weightErrors = true);
        return;
      }
      _goToStep(2);
      return;
    }
    if (!_input.validNutrition) {
      setState(() => _nutritionErrors = true);
      return;
    }
    final profile = _input.profile;
    if (profile != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _saving = true;
        _saveError = null;
      });
      try {
        await widget.onCompleted(profile);
      } on Object {
        if (mounted) {
          setState(
            () =>
                _saveError = AppLocalizations.of(context).onboardingSaveFailed,
          );
        }
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !widget.requiredFirstRun && _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _goToStep(_step - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: YamStepProgress(
                      step: _step + 1,
                      totalSteps: 3,
                      stepLabel: l10n.onboardingStepOf(_step + 1, 3),
                      leadingTooltip: _step == 0
                          ? l10n.onboardingClose
                          : l10n.onboardingBack,
                      leadingIcon: _step == 0
                          ? Icons.close_rounded
                          : Icons.arrow_back_rounded,
                      showLeading: _step > 0 || !widget.requiredFirstRun,
                      onLeadingPressed: _step == 0
                          ? (widget.onClose ??
                                () => Navigator.of(context).maybePop())
                          : () => _goToStep(_step - 1),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildPage(
                          index: 0,
                          title: l10n.onboardingGoalTitle,
                          description: l10n.onboardingGoalDescription,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildGoalChoices(l10n),
                              if (widget.requiredFirstRun &&
                                  widget.backupRepository != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                BackupImportButton(
                                  repository: widget.backupRepository!,
                                  files:
                                      widget.backupFiles ??
                                      const BackupFileService(),
                                  onImported: widget.onBackupImported,
                                  onBusyChanged: (busy) {
                                    if (mounted) {
                                      setState(() => _restoring = busy);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildPage(
                          index: 1,
                          title: l10n.onboardingWeightTitle,
                          description: l10n.onboardingWeightDescription,
                          content: _buildWeightFields(l10n),
                        ),
                        _buildPage(
                          index: 2,
                          title: l10n.onboardingNutritionTitle,
                          description: l10n.onboardingNutritionDescription,
                          content: _buildNutritionFields(l10n),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_saveError != null)
                          Text(
                            _saveError!,
                            style: AppTypography.caption.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        YamPrimaryButton(
                          key: const ValueKey('onboarding-continue'),
                          label: _step == 2
                              ? (_saving
                                    ? l10n.createProductSaving
                                    : l10n.onboardingStart)
                              : l10n.onboardingContinue,
                          trailingIcon: _step == 2
                              ? null
                              : Icons.arrow_forward_rounded,
                          expanded: true,
                          onPressed: _saving || _restoring ? null : _continue,
                          loading: _saving,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required int index,
    required String title,
    required String description,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: PageStorageKey('onboarding-page-$index'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.screenTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          content,
        ],
      ),
    );
  }

  Widget _buildGoalChoices(AppLocalizations l10n) {
    return Column(
      children: [
        if (_goalError) ...[
          Text(
            l10n.onboardingGoalRequired,
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        for (final goal in WeightGoal.values) ...[
          if (goal != WeightGoal.lose) const SizedBox(height: AppSpacing.md),
          YamChoiceCard(
            key: ValueKey('onboarding-goal-${goal.name}'),
            icon: switch (goal) {
              WeightGoal.lose => Icons.trending_down_rounded,
              WeightGoal.maintain => Icons.balance_rounded,
              WeightGoal.gain => Icons.trending_up_rounded,
            },
            title: switch (goal) {
              WeightGoal.lose => l10n.onboardingGoalLose,
              WeightGoal.maintain => l10n.onboardingGoalMaintain,
              WeightGoal.gain => l10n.onboardingGoalGain,
            },
            subtitle: switch (goal) {
              WeightGoal.lose => l10n.onboardingGoalLoseDescription,
              WeightGoal.maintain => l10n.onboardingGoalMaintainDescription,
              WeightGoal.gain => l10n.onboardingGoalGainDescription,
            },
            selected: _goal == goal,
            onPressed: () => setState(() {
              _goal = goal;
              _goalError = false;
              _refreshInput();
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildWeightFields(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final difference = _input.weightDifferenceKg;
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    )..maximumFractionDigits = 2;
    final differenceLabel = difference == null
        ? '—'
        : difference == 0
        ? l10n.onboardingWeightUnchanged
        : '${difference > 0 ? '+' : ''}${numbers.format(difference)} ${l10n.unitKilograms}';

    return Column(
      children: [
        YamNumberField(
          fieldKey: const ValueKey('onboarding-current-weight'),
          label: l10n.onboardingCurrentWeight,
          unit: l10n.unitKilograms,
          decimal: true,
          controller: _currentWeight,
          onChanged: _onInputChanged,
          errorText: _weightErrors && _input.currentWeightKg == null
              ? l10n.onboardingInvalidPositive
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        YamNumberField(
          fieldKey: const ValueKey('onboarding-target-weight'),
          label: l10n.onboardingTargetWeight,
          unit: l10n.unitKilograms,
          decimal: true,
          controller: _targetWeight,
          onChanged: _onInputChanged,
          textInputAction: TextInputAction.done,
          errorText: _weightErrors && _input.targetWeightKg == null
              ? l10n.onboardingInvalidPositive
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(
                l10n.onboardingWeightDifference,
                style: AppTypography.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                differenceLabel,
                style: AppTypography.body.copyWith(
                  color: difference == null || difference == 0
                      ? colors.onSurfaceVariant
                      : colors.primary,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionFields(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numbers = NumberFormat.decimalPattern(locale);
    final calculated = _input.caloriesFromMacros;
    final difference = _input.macroCalorieDifference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamNumberField(
          fieldKey: const ValueKey('onboarding-calories'),
          label: l10n.onboardingCalories,
          unit: l10n.unitKilocalories,
          controller: _calories,
          onChanged: _onInputChanged,
          style: YamNumberFieldStyle.prominent,
          errorText: _nutritionErrors && _input.calorieTarget == null
              ? l10n.onboardingInvalidPositive
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.onboardingMacros,
          style: AppTypography.label.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        YamGoalSliderField(
          fieldKey: const ValueKey('onboarding-protein'),
          sliderKey: const ValueKey('onboarding-protein-slider'),
          label: l10n.macroProtein,
          unit: l10n.unitGrams,
          controller: _protein,
          value: _input.proteinTarget,
          baseMax: 300,
          color: semantic.protein,
          onTextChanged: _onInputChanged,
          onSliderChanged: (amount) => _setMacroAmount(_protein, amount),
          errorText: _nutritionErrors && _input.proteinTarget == null
              ? l10n.onboardingInvalidNonNegative
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        YamGoalSliderField(
          fieldKey: const ValueKey('onboarding-fat'),
          sliderKey: const ValueKey('onboarding-fat-slider'),
          label: l10n.macroFat,
          unit: l10n.unitGrams,
          controller: _fat,
          value: _input.fatTarget,
          baseMax: 200,
          color: semantic.fat,
          onTextChanged: _onInputChanged,
          onSliderChanged: (amount) => _setMacroAmount(_fat, amount),
          errorText: _nutritionErrors && _input.fatTarget == null
              ? l10n.onboardingInvalidNonNegative
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        YamGoalSliderField(
          fieldKey: const ValueKey('onboarding-carbs'),
          sliderKey: const ValueKey('onboarding-carbs-slider'),
          label: l10n.macroCarbs,
          unit: l10n.unitGrams,
          controller: _carbs,
          value: _input.carbsTarget,
          baseMax: 500,
          color: semantic.carbs,
          onTextChanged: _onInputChanged,
          onSliderChanged: (amount) => _setMacroAmount(_carbs, amount),
          errorText: _nutritionErrors && _input.carbsTarget == null
              ? l10n.onboardingInvalidNonNegative
              : null,
        ),
        if (calculated != null && difference != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xxs,
              children: [
                Text(
                  l10n.onboardingEnergyFromMacros(numbers.format(calculated)),
                  style: AppTypography.productTitle.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
                Text(
                  difference == 0
                      ? l10n.onboardingEnergyMatches
                      : difference > 0
                      ? l10n.onboardingEnergyAbove(numbers.format(difference))
                      : l10n.onboardingEnergyBelow(numbers.format(-difference)),
                  style: AppTypography.body.copyWith(
                    color: colors.onSurfaceVariant,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.onboardingEnergyFormulaHint,
          style: AppTypography.caption.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: colors.outline),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                l10n.onboardingNutritionHint,
                style: AppTypography.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
