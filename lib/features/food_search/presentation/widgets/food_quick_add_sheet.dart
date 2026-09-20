import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
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
    constraints: const BoxConstraints(maxWidth: 600),
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
    final amount = _amount;
    final validAmount = amount != null && amount > 0;
    final nutrition = widget.food.nutritionFor(
      _serving,
      validAmount ? amount : 0,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quickAddTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.food.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (widget.food.brand case final brand?) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                brand,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final stackFields =
                    constraints.maxWidth < 440 ||
                    MediaQuery.textScalerOf(context).scale(16) > 20;
                final quantityField = TextField(
                  key: const ValueKey('quick-add-quantity'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.quickAddQuantity,
                    errorText: _attemptedSubmit && !validAmount
                        ? l10n.quickAddAmountInvalid
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                );
                final unitField = DropdownButtonFormField<String>(
                  key: ValueKey('quick-add-unit-${_serving.id}'),
                  initialValue: _serving.id,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.quickAddUnit),
                  items: [
                    for (final serving in widget.food.servings)
                      DropdownMenuItem(
                        value: serving.id,
                        child: Text(foodSearchUnitLabel(l10n, serving.unit)),
                      ),
                  ],
                  onChanged: (servingId) {
                    if (servingId == null) {
                      return;
                    }
                    final serving = widget.food.servings.firstWhere(
                      (candidate) => candidate.id == servingId,
                    );
                    setState(() {
                      _serving = serving;
                      _amountController.text = _editableNumber(
                        serving.defaultAmount,
                      );
                    });
                  },
                );

                if (stackFields) {
                  return Column(
                    children: [
                      quantityField,
                      const SizedBox(height: AppSpacing.sm),
                      unitField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: quantityField),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: unitField),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                OutlinedButton(
                  onPressed: () => _changeAmount(-_serving.step),
                  child: Text(
                    '-${formatFoodSearchNumber(context, _serving.step)}',
                    semanticsLabel: l10n.quickAddDecrease,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _changeAmount(_serving.step),
                  child: Text(
                    '+${formatFoodSearchNumber(context, _serving.step)}',
                    semanticsLabel: l10n.quickAddIncrease,
                  ),
                ),
                for (final preset in _serving.presets)
                  ChoiceChip(
                    label: Text(
                      formatFoodSearchQuantity(context, _serving.unit, preset),
                    ),
                    selected: amount == preset,
                    onSelected: (_) => _setAmount(preset),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              key: const ValueKey('quick-add-meal'),
              initialValue: _mealId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.quickAddMeal,
                errorText: _attemptedSubmit && _mealId == null
                    ? l10n.foodSearchMealRequired
                    : null,
              ),
              items: [
                for (final meal in meals)
                  DropdownMenuItem(value: meal.id, child: Text(meal.name)),
              ],
              onChanged: (mealId) => setState(() => _mealId = mealId),
            ),
            const SizedBox(height: AppSpacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quickAddNutrition,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _NutritionValue(
                          label: l10n.mealCalories(
                            formatFoodSearchNumber(context, nutrition.calories),
                          ),
                          emphasized: true,
                        ),
                        _NutritionValue(
                          label:
                              '${l10n.macroProtein} ${formatFoodSearchNumber(context, nutrition.protein)} ${l10n.unitGrams}',
                        ),
                        _NutritionValue(
                          label:
                              '${l10n.macroFat} ${formatFoodSearchNumber(context, nutrition.fat)} ${l10n.unitGrams}',
                        ),
                        _NutritionValue(
                          label:
                              '${l10n.macroCarbs} ${formatFoodSearchNumber(context, nutrition.carbs)} ${l10n.unitGrams}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              key: const ValueKey('quick-add-submit'),
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.quickAddAdd),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeAmount(double delta) {
    final current = _amount ?? _serving.defaultAmount;
    _setAmount((current + delta).clamp(_serving.step, double.infinity));
  }

  void _setAmount(double amount) {
    setState(() => _amountController.text = _editableNumber(amount));
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

class _NutritionValue extends StatelessWidget {
  const _NutritionValue({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: emphasized ? theme.colorScheme.primary : null,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

String _editableNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
