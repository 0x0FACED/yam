import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/food/yam_quantity_control.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

Future<FoodAddPrototypeResult?> showFoodQuickAddSheet({
  required BuildContext context,
  required FoodSearchPrototypeFood food,
  required String? initialMealId,
}) {
  return showModalBottomSheet<FoodAddPrototypeResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (context) =>
        _FoodQuickAddSheet(food: food, initialMealId: initialMealId),
  );
}

class _FoodQuickAddSheet extends StatefulWidget {
  const _FoodQuickAddSheet({required this.food, required this.initialMealId});

  final FoodSearchPrototypeFood food;
  final String? initialMealId;

  @override
  State<_FoodQuickAddSheet> createState() => _FoodQuickAddSheetState();
}

class _FoodQuickAddSheetState extends State<_FoodQuickAddSheet> {
  late FoodSearchPrototypeServing _serving;
  late final TextEditingController _amountController;
  String? _mealId;
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _serving = widget.food.lastServing;
    _amountController = TextEditingController(
      text: _editableNumber(widget.food.lastAmount),
    );
    _mealId = widget.initialMealId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final meals = buildFoodSearchPrototypeMeals(l10n);
    final selectedMeal = _mealId == null
        ? null
        : meals.firstWhere((meal) => meal.id == _mealId);
    final amount = _amount;
    final validAmount = amount != null && amount > 0;
    final nutrition = widget.food.nutritionFor(
      _serving,
      validAmount ? amount : 0,
    );
    final calorieValue = formatFoodSearchNumber(
      context,
      nutrition.calories.round(),
    );
    final sourceLabel =
        widget.food.brand ??
        switch (widget.food.source) {
          FoodSearchPrototypeSource.localCatalog => l10n.foodSearchSourceLocal,
          FoodSearchPrototypeSource.userCreated => l10n.foodSearchSourceUser,
        };
    final referenceQuantity = formatFoodSearchQuantity(
      context,
      widget.food.referenceUnit,
      widget.food.referenceAmount,
    );
    final referenceCalories = l10n.foodSearchCaloriesPerReference(
      formatFoodSearchNumber(context, widget.food.nutrition.calories),
      referenceQuantity,
    );
    final selectedPresetIndex = _selectedPresetIndex(amount);

    return SafeArea(
      top: false,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MenuAnchor(
                          menuChildren: [
                            for (final meal in meals)
                              MenuItemButton(
                                key: ValueKey('quick-add-meal-${meal.id}'),
                                leadingIcon: Icon(meal.icon, size: 18),
                                onPressed: () {
                                  setState(() => _mealId = meal.id);
                                },
                                child: Text(meal.name),
                              ),
                          ],
                          builder: (context, controller, child) {
                            return YamMealChip(
                              key: const ValueKey('quick-add-meal'),
                              icon:
                                  selectedMeal?.icon ??
                                  Icons.restaurant_menu_rounded,
                              label: selectedMeal == null
                                  ? l10n.foodSearchChooseMeal
                                  : l10n.quickAddSelectedMeal(
                                      selectedMeal.name,
                                    ),
                              active: selectedMeal != null,
                              maxWidth: 280,
                              onPressed: controller.isOpen
                                  ? controller.close
                                  : controller.open,
                            );
                          },
                        ),
                        if (_attemptedSubmit && selectedMeal == null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l10n.foodSearchMealRequired,
                              style: AppTypography.caption.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.food.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.screenTitle.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (widget.food.verified) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Tooltip(
                                message: l10n.foodSearchVerified,
                                child: Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '$sourceLabel · $referenceCalories',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  YamIconButton(
                    key: const ValueKey('quick-add-close'),
                    icon: Icons.close_rounded,
                    tooltip: l10n.quickAddClose,
                    onPressed: () => Navigator.of(context).pop(),
                    iconSize: 17,
                    visualSize: 32,
                    visualBorderRadius: AppRadius.pill,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              YamQuantityControl(
                amountFieldKey: const ValueKey('quick-add-quantity'),
                unitKey: ValueKey('quick-add-unit-${_serving.id}'),
                controller: _amountController,
                unitLabels: [
                  for (final serving in widget.food.servings)
                    foodSearchUnitLabel(l10n, serving.unit),
                ],
                selectedUnitIndex: widget.food.servings.indexOf(_serving),
                amountSemanticLabel: l10n.quickAddQuantity,
                unitTooltip: l10n.quickAddUnit,
                decreaseTooltip: l10n.quickAddDecrease,
                increaseTooltip: l10n.quickAddIncrease,
                errorText: _attemptedSubmit && !validAmount
                    ? l10n.quickAddAmountInvalid
                    : null,
                onAmountChanged: (_) => setState(() {}),
                onUnitSelected: _selectServing,
                onDecrease: () => _changeAmount(-_serving.step),
                onIncrease: () => _changeAmount(_serving.step),
              ),
              const SizedBox(height: AppSpacing.sm),
              YamQuickAmountPresets(
                title: l10n.quickAddQuickSelect,
                usualAmountLabel: l10n.quickAddUsualAmount(
                  formatFoodSearchQuantity(
                    context,
                    widget.food.lastServing.unit,
                    widget.food.lastAmount,
                  ),
                ),
                labels: [
                  for (final preset in _serving.presets)
                    formatFoodSearchQuantity(context, _serving.unit, preset),
                ],
                selectedIndex: selectedPresetIndex,
                onSelected: (index) => _setAmount(_serving.presets[index]),
              ),
              const SizedBox(height: AppSpacing.md),
              YamNutritionSummary(
                calorieValue: calorieValue,
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
                key: const ValueKey('quick-add-submit'),
                label: selectedMeal == null
                    ? l10n.quickAddAddCalories(calorieValue)
                    : l10n.quickAddAddToMeal(selectedMeal.name, calorieValue),
                onPressed: _submit,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _selectedPresetIndex(double? amount) {
    if (amount == null) {
      return null;
    }
    final index = _serving.presets.indexOf(amount);
    return index < 0 ? null : index;
  }

  void _selectServing(int index) {
    final serving = widget.food.servings[index];
    setState(() {
      _serving = serving;
      _setControllerAmount(serving.defaultAmount);
    });
  }

  void _changeAmount(double delta) {
    final current = _amount ?? _serving.defaultAmount;
    final amount = (current + delta)
        .clamp(_serving.step, double.infinity)
        .toDouble();
    _setAmount(amount);
  }

  void _setAmount(double amount) {
    setState(() => _setControllerAmount(amount));
  }

  void _setControllerAmount(double amount) {
    final text = _editableNumber(amount);
    _amountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _submit() {
    final amount = _amount;
    setState(() => _attemptedSubmit = true);
    if (amount == null || amount <= 0 || _mealId == null) {
      return;
    }

    final nutrition = widget.food.nutritionFor(_serving, amount);
    Navigator.of(context).pop(
      FoodAddPrototypeResult(
        foodId: widget.food.id,
        name: widget.food.name,
        brand: widget.food.brand,
        quantityLabel: formatFoodSearchQuantity(context, _serving.unit, amount),
        mealId: _mealId!,
        calories: nutrition.calories.round(),
        protein: nutrition.protein,
        fat: nutrition.fat,
        carbs: nutrition.carbs,
      ),
    );
  }
}

String _editableNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
