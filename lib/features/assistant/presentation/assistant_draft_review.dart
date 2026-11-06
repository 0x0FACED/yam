import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_number_field.dart';
import 'package:yam/core/ui/forms/yam_select_field.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/features/assistant/application/assistant_tools.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantDraftReview extends StatefulWidget {
  const AssistantDraftReview({
    required this.draft,
    required this.tools,
    required this.onChanged,
    required this.onConfirm,
    required this.onDiscard,
    required this.disabled,
    required this.saving,
    super.key,
  });
  final AssistantDraft draft;
  final AssistantTools tools;
  final ValueChanged<AssistantDraft> onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;
  final bool disabled;
  final bool saving;

  @override
  State<AssistantDraftReview> createState() => _AssistantDraftReviewState();
}

class _AssistantDraftReviewState extends State<AssistantDraftReview> {
  final Set<String> _invalidAmounts = {};

  void _replace(AssistantDraftItem replacement) => widget.onChanged(
    widget.draft.copyWith(
      items: [
        for (final item in widget.draft.items)
          item.id == replacement.id ? replacement : item,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = widget.draft;
    final colors = Theme.of(context).colorScheme;
    final valid =
        draft.items.isNotEmpty &&
        !_invalidAmounts.any(
          (id) => draft.items.any((item) => item.id == id),
        ) &&
        draft.items.every(
          (item) =>
              item.addToDiary || item.newFood != null && item.saveToCatalog,
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.assistantDraftTitle, style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.assistantDraftNote,
              style: AppTypography.label.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            YamSecondaryButton(
              label:
                  '${l10n.assistantDate}: ${MaterialLocalizations.of(context).formatMediumDate(draft.day)}',
              icon: Icons.calendar_today_outlined,
              onPressed: widget.disabled
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: draft.day,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100, 12, 31),
                      );
                      if (date != null && mounted) {
                        widget.onChanged(widget.draft.copyWith(day: date));
                      }
                    },
            ),
            const SizedBox(height: AppSpacing.sm),
            IgnorePointer(
              ignoring: widget.disabled,
              child: YamSelectField<String>(
                label: l10n.assistantMeal,
                value: draft.mealId,
                items: [
                  for (final meal in buildFoodSearchPrototypeMeals(l10n))
                    YamDropdownOption(value: meal.id, label: meal.name),
                ],
                onChanged: (meal) =>
                    widget.onChanged(draft.copyWith(mealId: meal)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in draft.items) ...[
              _DraftItemEditor(
                key: ValueKey(item.id),
                item: item,
                disabled: widget.disabled,
                onChanged: _replace,
                onValidity: (valid) => setState(() {
                  if (valid) {
                    _invalidAmounts.remove(item.id);
                  } else {
                    _invalidAmounts.add(item.id);
                  }
                }),
                onRemove: () {
                  _invalidAmounts.remove(item.id);
                  widget.onChanged(
                    draft.copyWith(
                      items: draft.items
                          .where((candidate) => candidate.id != item.id)
                          .toList(),
                    ),
                  );
                },
                onEdit: item.newFood == null
                    ? null
                    : () async {
                        final edited = await showDialog<CustomFoodDraft>(
                          context: context,
                          builder: (context) =>
                              _NewFoodEditor(food: item.newFood!),
                        );
                        if (edited == null || !mounted) return;
                        final food = widget.tools.snapshotForNewFood(
                          edited,
                          foodId: item.food.foodId,
                        );
                        final servingId =
                            food.servings.any(
                              (serving) => serving.id == item.servingId,
                            )
                            ? item.servingId
                            : food.servings.first.id;
                        _replace(
                          item.copyWith(
                            food: food,
                            newFood: edited,
                            servingId: servingId,
                          ),
                        );
                      },
              ),
              const Divider(height: AppSpacing.lg),
            ],
            if (draft.items.any((item) => item.isEstimated)) ...[
              Text(
                l10n.assistantEstimateNote,
                style: AppTypography.label.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (draft.hasDiaryItems) ...[
              _NutritionLine(nutrition: draft.nutrition),
              const SizedBox(height: AppSpacing.md),
            ],
            if (!valid)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.assistantInvalidDraft,
                  style: AppTypography.label.copyWith(color: colors.error),
                ),
              ),
            YamPrimaryButton(
              key: const ValueKey('assistant-confirm-draft'),
              label: draft.hasDiaryItems
                  ? l10n.assistantAddToDiary
                  : l10n.assistantSaveProducts,
              expanded: true,
              loading: widget.saving,
              onPressed: widget.disabled || !valid ? null : widget.onConfirm,
            ),
            YamTextButton(
              label: l10n.assistantDiscard,
              onPressed: widget.disabled ? null : widget.onDiscard,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftItemEditor extends StatefulWidget {
  const _DraftItemEditor({
    required this.item,
    required this.disabled,
    required this.onChanged,
    required this.onValidity,
    required this.onRemove,
    this.onEdit,
    super.key,
  });
  final AssistantDraftItem item;
  final bool disabled;
  final ValueChanged<AssistantDraftItem> onChanged;
  final ValueChanged<bool> onValidity;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;
  @override
  State<_DraftItemEditor> createState() => _DraftItemEditorState();
}

class _DraftItemEditorState extends State<_DraftItemEditor> {
  late final TextEditingController _amount;
  bool _valid = true;
  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: _editNumber(widget.item.amount));
  }

  @override
  void didUpdateWidget(_DraftItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (oldWidget.item.amount != widget.item.amount &&
        current != widget.item.amount) {
      _amount.text = _editNumber(widget.item.amount);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.food.name, style: AppTypography.productTitle),
                  if (item.food.brand case final brand?)
                    Text(
                      brand,
                      style: AppTypography.caption.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  if (item.isEstimated)
                    Text(
                      l10n.assistantEstimatedLabel,
                      style: AppTypography.label.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            YamIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.assistantRemoveItem,
              onPressed: widget.disabled ? null : widget.onRemove,
              surface: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        IgnorePointer(
          ignoring: widget.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YamNumberField(
                label: l10n.assistantAmount,
                unit: '',
                controller: _amount,
                decimal: true,
                style: YamNumberFieldStyle.prominent,
                errorText: _valid ? null : l10n.createProductPositiveAmount,
                onChanged: (text) {
                  final amount = double.tryParse(text.replaceAll(',', '.'));
                  final valid = amount != null && amount.isFinite && amount > 0;
                  setState(() => _valid = valid);
                  widget.onValidity(valid);
                  if (valid) widget.onChanged(item.copyWith(amount: amount));
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              YamSelectField<String>(
                label: l10n.assistantUnit,
                value: item.servingId,
                items: [
                  for (final serving in item.food.servings)
                    YamDropdownOption(
                      value: serving.id,
                      label: _servingLabel(l10n, serving),
                    ),
                ],
                onChanged: (id) {
                  final serving = item.food.serving(id);
                  setState(() => _valid = true);
                  widget.onValidity(true);
                  widget.onChanged(
                    item.copyWith(
                      servingId: id,
                      amount: item.canonicalQuantity / serving.baseAmount,
                    ),
                  );
                },
              ),
              if (item.food.serving(item.servingId).baseAmount != 1)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '${formatFoodSearchNumber(context, item.canonicalQuantity)} ${item.food.baseUnit == DiaryBaseUnit.grams ? l10n.unitGrams : l10n.unitMilliliters}',
                    style: AppTypography.caption,
                  ),
                ),
              if (item.newFood != null) ...[
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    l10n.assistantSaveToCatalog,
                    style: AppTypography.label,
                  ),
                  value: item.saveToCatalog,
                  onChanged: (value) =>
                      widget.onChanged(item.copyWith(saveToCatalog: value)),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    l10n.assistantAddToDiary,
                    style: AppTypography.label,
                  ),
                  value: item.addToDiary,
                  onChanged: (value) =>
                      widget.onChanged(item.copyWith(addToDiary: value)),
                ),
                YamTextButton(
                  label: l10n.assistantEditProduct,
                  icon: Icons.edit_outlined,
                  onPressed: widget.onEdit,
                ),
              ],
            ],
          ),
        ),
        if (item.addToDiary)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _NutritionLine(nutrition: item.nutrition),
          ),
      ],
    );
  }
}

class _NutritionLine extends StatelessWidget {
  const _NutritionLine({required this.nutrition});
  final DiaryNutrition nutrition;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final macro = AppSemanticColors.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xxs,
      children: [
        Text(
          '${formatFoodSearchNumber(context, nutrition.kcal)} ${l10n.unitKilocalories}',
          style: AppTypography.productTitle,
        ),
        for (final entry in [
          (l10n.macroProteinShort, nutrition.protein, macro.protein),
          (l10n.macroFatShort, nutrition.fat, macro.fat),
          (l10n.macroCarbsShort, nutrition.carbs, macro.carbs),
        ])
          Text(
            '${entry.$1} ${formatFoodSearchNumber(context, entry.$2)} ${l10n.unitGrams}',
            style: AppTypography.label.copyWith(color: entry.$3),
          ),
      ],
    );
  }
}

String _editNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
String _servingLabel(AppLocalizations l10n, DiaryServingSnapshot serving) =>
    serving.label ??
    foodSearchUnitLabel(
      l10n,
      FoodSearchPrototypeUnit.values.firstWhere(
        (unit) => unit.name == serving.unit,
        orElse: () => FoodSearchPrototypeUnit.servings,
      ),
    );

class _NewFoodEditor extends StatefulWidget {
  const _NewFoodEditor({required this.food});
  final CustomFoodDraft food;
  @override
  State<_NewFoodEditor> createState() => _NewFoodEditorState();
}

class _NewFoodEditorState extends State<_NewFoodEditor> {
  late final TextEditingController _name,
      _brand,
      _category,
      _basisAmount,
      _protein,
      _fat,
      _carbs;
  late final List<TextEditingController> _servingAmounts;
  late CustomFoodBasis _basis;
  String? _error;
  @override
  void initState() {
    super.initState();
    final food = widget.food;
    _name = TextEditingController(text: food.name);
    _brand = TextEditingController(text: food.brand);
    _category = TextEditingController(text: food.category);
    _basisAmount = TextEditingController(text: _editNumber(food.basisAmount));
    _protein = TextEditingController(text: _editNumber(food.proteinG));
    _fat = TextEditingController(text: _editNumber(food.fatG));
    _carbs = TextEditingController(text: _editNumber(food.carbsG));
    _servingAmounts = [
      for (final serving in food.servings)
        TextEditingController(text: _editNumber(serving.baseAmount)),
    ];
    _basis = food.basis;
  }

  @override
  void dispose() {
    for (final field in [
      _name,
      _brand,
      _category,
      _basisAmount,
      _protein,
      _fat,
      _carbs,
      ..._servingAmounts,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController field) =>
      double.tryParse(field.text.replaceAll(',', '.')) ?? double.nan;
  void _save() {
    final amount = _number(_basisAmount);
    final food = widget.food;
    final draft = CustomFoodDraft(
      name: _name.text.trim(),
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      category: _category.text.trim(),
      barcode: food.barcode,
      description: food.description,
      basis: _basis,
      basisAmount: amount,
      displayBasis: amount == 100
          ? (_basis == CustomFoodBasis.grams
                ? CustomFoodDisplayBasis.perHundredGrams
                : CustomFoodDisplayBasis.perHundredMilliliters)
          : CustomFoodDisplayBasis.perServing,
      proteinG: _number(_protein),
      fatG: _number(_fat),
      carbsG: _number(_carbs),
      servings: [
        for (var i = 0; i < food.servings.length; i++)
          CustomServingDraft(
            unit: food.servings[i].unit,
            label: food.servings[i].label,
            baseAmount: _number(_servingAmounts[i]),
            defaultAmount: food.servings[i].defaultAmount,
          ),
      ],
    );
    try {
      draft.validate();
      Navigator.pop(context, draft);
    } on ArgumentError {
      setState(
        () => _error = AppLocalizations.of(context).assistantInvalidDraft,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = _basis == CustomFoodBasis.grams
        ? l10n.unitGrams
        : l10n.unitMilliliters;
    return AlertDialog(
      title: Text(l10n.assistantEditProduct),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YamTextField(label: l10n.createProductName, controller: _name),
              const SizedBox(height: AppSpacing.md),
              YamTextField(label: l10n.createProductBrand, controller: _brand),
              const SizedBox(height: AppSpacing.md),
              YamTextField(
                label: l10n.createProductCategory,
                controller: _category,
              ),
              const SizedBox(height: AppSpacing.md),
              YamSelectField<CustomFoodBasis>(
                label: l10n.assistantUnit,
                value: _basis,
                items: [
                  YamDropdownOption(
                    value: CustomFoodBasis.grams,
                    label: l10n.unitGrams,
                  ),
                  YamDropdownOption(
                    value: CustomFoodBasis.milliliters,
                    label: l10n.unitMilliliters,
                  ),
                ],
                onChanged: (basis) => setState(() => _basis = basis),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final field in [
                (l10n.createProductNutritionBasis, _basisAmount, unit),
                (l10n.macroProtein, _protein, l10n.unitGrams),
                (l10n.macroFat, _fat, l10n.unitGrams),
                (l10n.macroCarbs, _carbs, l10n.unitGrams),
              ]) ...[
                YamNumberField(
                  label: field.$1,
                  unit: field.$3,
                  controller: field.$2,
                  decimal: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              for (var i = 0; i < widget.food.servings.length; i++) ...[
                YamNumberField(
                  label:
                      '${l10n.createProductServingAmount}: ${widget.food.servings[i].label ?? switch (widget.food.servings[i].unit) {
                            CustomServingUnit.serving => l10n.unitServings,
                            CustomServingUnit.piece => l10n.unitPieces,
                            CustomServingUnit.glass => l10n.unitGlasses,
                            CustomServingUnit.scoop => l10n.unitScoops,
                          }}',
                  unit: unit,
                  controller: _servingAmounts[i],
                  decimal: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.backupCancel),
        ),
        TextButton(onPressed: _save, child: Text(l10n.diaryEditSave)),
      ],
    );
  }
}
