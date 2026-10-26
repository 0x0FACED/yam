import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/food/yam_quantity_control.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DiaryEntryChange {
  const DiaryEntryChange.delete()
    : delete = true,
      mealId = null,
      servingId = null,
      amount = null,
      canonicalQuantity = null;

  const DiaryEntryChange.save({
    required String this.mealId,
    required String this.servingId,
    required double this.amount,
    required double this.canonicalQuantity,
  }) : delete = false;

  final bool delete;
  final String? mealId;
  final String? servingId;
  final double? amount;
  final double? canonicalQuantity;
}

Future<DiaryEntryChange?> showEditDiaryEntrySheet({
  required BuildContext context,
  required DiaryEntry entry,
}) => showModalBottomSheet<DiaryEntryChange>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  constraints: const BoxConstraints(maxWidth: 480),
  builder: (context) => _EditDiaryEntrySheet(entry: entry),
);

class _EditDiaryEntrySheet extends StatefulWidget {
  const _EditDiaryEntrySheet({required this.entry});

  final DiaryEntry entry;

  @override
  State<_EditDiaryEntrySheet> createState() => _EditDiaryEntrySheetState();
}

class _EditDiaryEntrySheetState extends State<_EditDiaryEntrySheet> {
  late final TextEditingController _controller;
  late DiaryServingSnapshot _serving;
  late String _mealId;
  late double? _amount;
  late double? _canonicalQuantity;
  String _decimalSeparator = '.';
  bool _localizedInitialAmount = false;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _serving = widget.entry.food.serving(widget.entry.servingId);
    _mealId = widget.entry.mealId;
    _amount = widget.entry.amount;
    _canonicalQuantity = widget.entry.canonicalQuantity;
    _controller = TextEditingController(
      text: editableFoodSearchNumber(_amount!),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _decimalSeparator = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).symbols.DECIMAL_SEP;
    if (!_localizedInitialAmount) {
      _localizedInitialAmount = true;
      _controller.text = editableFoodSearchNumber(
        _amount!,
      ).replaceAll('.', _decimalSeparator);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setAmount(double value, {double? canonicalQuantity}) {
    setState(() {
      _amount = value;
      _canonicalQuantity = canonicalQuantity ?? value * _serving.baseAmount;
      final text = editableFoodSearchNumber(
        value,
      ).replaceAll('.', _decimalSeparator);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _selectServing(int index) {
    final next = widget.entry.food.servings[index];
    if (next.id == _serving.id) return;
    final exact = _canonicalQuantity;
    setState(() => _serving = next);
    _setAmount(
      exact == null ? 1 : exact / next.baseAmount,
      canonicalQuantity: exact,
    );
  }

  void _save() {
    setState(() => _attempted = true);
    final amount = _amount;
    final canonicalQuantity = _canonicalQuantity;
    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        canonicalQuantity == null ||
        !canonicalQuantity.isFinite ||
        canonicalQuantity <= 0 ||
        !widget.entry.food.nutritionFor(canonicalQuantity).isValid) {
      return;
    }
    Navigator.of(context).pop(
      DiaryEntryChange.save(
        mealId: _mealId,
        servingId: _serving.id,
        amount: amount,
        canonicalQuantity: canonicalQuantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final entry = widget.entry;
    final meals = buildFoodSearchPrototypeMeals(l10n);
    final selectedMeal = meals.firstWhere((meal) => meal.id == _mealId);
    final validQuantity =
        _amount != null &&
        _amount!.isFinite &&
        _amount! > 0 &&
        _canonicalQuantity != null &&
        _canonicalQuantity!.isFinite &&
        _canonicalQuantity! > 0;
    final candidateNutrition = entry.food.nutritionFor(
      validQuantity ? _canonicalQuantity! : 0,
    );
    final valid = validQuantity && candidateNutrition.isValid;
    final nutrition = valid ? candidateNutrition : entry.food.nutritionFor(0);
    final baseUnit = entry.food.baseUnit == DiaryBaseUnit.grams
        ? FoodSearchPrototypeUnit.grams
        : FoodSearchPrototypeUnit.milliliters;

    return SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.diaryEditEntry,
                      style: AppTypography.label.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  YamIconButton(
                    key: const ValueKey('diary-edit-delete'),
                    icon: Icons.delete_outline_rounded,
                    tooltip: l10n.diaryDeleteEntry,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const DiaryEntryChange.delete()),
                    destructive: true,
                    iconSize: 20,
                    visualSize: 32,
                    visualBorderRadius: AppRadius.small,
                  ),
                  YamIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.diaryEditClose,
                    onPressed: () => Navigator.of(context).pop(),
                    iconSize: 18,
                    visualSize: 32,
                    visualBorderRadius: AppRadius.small,
                  ),
                ],
              ),
              Text(
                entry.food.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.screenTitle.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                [
                  if (entry.food.brand != null) entry.food.brand!,
                  l10n.foodSearchCaloriesPerReference(
                    formatFoodSearchNumber(
                      context,
                      entry.food.nutritionPerBasis.kcal,
                    ),
                    formatFoodSearchQuantity(
                      context,
                      baseUnit,
                      entry.food.basisAmount,
                    ),
                  ),
                ].join(' · '),
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              YamQuantityControl(
                amountFieldKey: const ValueKey('diary-edit-quantity'),
                controller: _controller,
                unitLabels: [
                  for (final serving in entry.food.servings)
                    serving.label ??
                        foodSearchUnitLabel(
                          l10n,
                          FoodSearchPrototypeUnit.values.byName(serving.unit),
                        ),
                ],
                selectedUnitIndex: entry.food.servings.indexOf(_serving),
                amountSemanticLabel: l10n.quickAddQuantity,
                unitTooltip: l10n.quickAddUnit,
                decreaseTooltip: l10n.quickAddDecrease,
                increaseTooltip: l10n.quickAddIncrease,
                onAmountChanged: (text) => setState(() {
                  _amount = double.tryParse(text.trim().replaceAll(',', '.'));
                  _canonicalQuantity = _amount == null
                      ? null
                      : _amount! * _serving.baseAmount;
                }),
                onUnitSelected: _selectServing,
                onDecrease: () {
                  final next = (_amount ?? 1) - 1;
                  if (next > 0) _setAmount(next);
                },
                onIncrease: () => _setAmount((_amount ?? 0) + 1),
                errorText: _attempted && !valid
                    ? l10n.quickAddAmountInvalid
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              YamDropdown<String>(
                value: _mealId,
                options: [
                  for (final meal in meals)
                    YamDropdownOption(
                      value: meal.id,
                      label: meal.name,
                      icon: meal.icon,
                    ),
                ],
                onSelected: (id) => setState(() => _mealId = id),
                triggerBuilder: (context, toggle, focusNode, isOpen) =>
                    YamMealChip(
                      key: const ValueKey('diary-edit-meal'),
                      icon: selectedMeal.icon,
                      label: l10n.quickAddSelectedMeal(selectedMeal.name),
                      onPressed: toggle,
                      focusNode: focusNode,
                      focused: focusNode.hasFocus || isOpen,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              YamNutritionSummary(
                calorieValue: formatFoodSearchNumber(
                  context,
                  nutrition.kcal.round(),
                ),
                calorieUnit: l10n.unitKilocalories,
                proteinLabel: l10n.macroProteinShort,
                proteinValue:
                    '${formatFoodSearchNumber(context, nutrition.protein)} ${l10n.unitGrams}',
                fatLabel: l10n.macroFatShort,
                fatValue:
                    '${formatFoodSearchNumber(context, nutrition.fat)} ${l10n.unitGrams}',
                carbsLabel: l10n.macroCarbsShort,
                carbsValue:
                    '${formatFoodSearchNumber(context, nutrition.carbs)} ${l10n.unitGrams}',
              ),
              const SizedBox(height: AppSpacing.md),
              YamPrimaryButton(
                key: const ValueKey('diary-edit-save'),
                label: l10n.diaryEditSave,
                onPressed: _save,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
