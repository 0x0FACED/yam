import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_number_field.dart';
import 'package:yam/core/ui/forms/yam_select_field.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({required this.repository, super.key});

  final UserFoodRepository repository;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _ServingEditor {
  _ServingEditor(this.unit);

  final CustomServingUnit unit;
  final name = TextEditingController();
  final amount = TextEditingController();

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _brandFocus = FocusNode();
  final _barcode = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _carbs = TextEditingController();
  final _servingSize = TextEditingController();
  final List<_ServingEditor> _servings = [];

  FoodSearchPrototypeCategory _category = FoodSearchPrototypeCategory.other;
  CustomFoodDisplayBasis _displayBasis = CustomFoodDisplayBasis.perHundredGrams;
  CustomFoodBasis _servingBasis = CustomFoodBasis.grams;
  Map<String, String> _errors = const {};
  bool _attempted = false;
  bool _saving = false;
  String? _saveError;
  late Future<List<String>> _brands;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void didUpdateWidget(CreateProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _loadBrands();
  }

  void _loadBrands() {
    _brands = widget.repository.loadBrands().catchError(
      (Object _) => <String>[],
    );
  }

  @override
  void dispose() {
    _brandFocus.dispose();
    for (final serving in _servings) {
      serving.dispose();
    }
    for (final controller in [
      _name,
      _brand,
      _barcode,
      _protein,
      _fat,
      _carbs,
      _servingSize,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  static double? _number(String text, {bool zeroAllowed = false}) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value != null &&
            value.isFinite &&
            (zeroAllowed ? value >= 0 : value > 0)
        ? value
        : null;
  }

  void _changed(String _) {
    setState(() {
      if (_attempted) _errors = _validate();
    });
  }

  Map<String, String> _validate() {
    final l10n = AppLocalizations.of(context);
    final errors = <String, String>{};
    if (_name.text.trim().isEmpty) {
      errors['name'] = l10n.createProductNameRequired;
    }
    for (final field in {
      'protein': _protein,
      'fat': _fat,
      'carbs': _carbs,
    }.entries) {
      if (_number(field.value.text, zeroAllowed: true) == null) {
        errors[field.key] = l10n.createProductInvalidNumber;
      }
    }
    if (errors['protein'] == null &&
        errors['fat'] == null &&
        errors['carbs'] == null &&
        _calculatedEnergy == null) {
      errors['carbs'] = l10n.createProductInvalidNumber;
    }
    if (_displayBasis == CustomFoodDisplayBasis.perServing &&
        _number(_servingSize.text) == null) {
      errors['servingSize'] = l10n.createProductPositiveAmount;
    }
    for (var index = 0; index < _servings.length; index++) {
      if (_number(_servings[index].amount.text) == null) {
        errors['serving$index'] = l10n.createProductPositiveAmount;
      }
    }
    final barcode = _barcode.text.trim();
    if (barcode.isNotEmpty && !RegExp(r'^\d+$').hasMatch(barcode)) {
      errors['barcode'] = l10n.createProductInvalidBarcode;
    }
    return errors;
  }

  CustomFoodDraft _draft() {
    final basis = _displayBasis == CustomFoodDisplayBasis.perServing
        ? _servingBasis
        : _displayBasis == CustomFoodDisplayBasis.perHundredGrams
        ? CustomFoodBasis.grams
        : CustomFoodBasis.milliliters;
    final basisAmount = _displayBasis == CustomFoodDisplayBasis.perServing
        ? _number(_servingSize.text)!
        : 100.0;
    return CustomFoodDraft(
      name: _name.text.trim(),
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      category: _category.name,
      basis: basis,
      basisAmount: basisAmount,
      displayBasis: _displayBasis,
      proteinG: _number(_protein.text, zeroAllowed: true)!,
      fatG: _number(_fat.text, zeroAllowed: true)!,
      carbsG: _number(_carbs.text, zeroAllowed: true)!,
      servings: [
        if (_displayBasis == CustomFoodDisplayBasis.perServing)
          CustomServingDraft(
            unit: CustomServingUnit.serving,
            baseAmount: basisAmount,
            defaultAmount: 1,
          ),
        for (final serving in _servings)
          CustomServingDraft(
            unit: serving.unit,
            label:
                serving.unit == CustomServingUnit.serving &&
                    serving.name.text.trim().isNotEmpty
                ? serving.name.text.trim()
                : null,
            baseAmount: _number(serving.amount.text)!,
            defaultAmount: 1,
          ),
      ],
    );
  }

  double? get _calculatedEnergy {
    final protein = _number(_protein.text, zeroAllowed: true);
    final fat = _number(_fat.text, zeroAllowed: true);
    final carbs = _number(_carbs.text, zeroAllowed: true);
    if (protein == null || fat == null || carbs == null) return null;
    final energy = energyKcalFromMacros(
      proteinG: protein,
      fatG: fat,
      carbsG: carbs,
    );
    return energy.isFinite ? energy : null;
  }

  Future<void> _save() async {
    if (_saving) return;
    final errors = _validate();
    setState(() {
      _attempted = true;
      _errors = errors;
      _saveError = null;
    });
    if (errors.isNotEmpty) return;

    setState(() => _saving = true);
    try {
      final draft = _draft();
      if (draft.barcode != null &&
          await widget.repository.barcodeExists(draft.barcode!)) {
        if (mounted) {
          setState(() {
            _errors = {
              'barcode': AppLocalizations.of(
                context,
              ).createProductDuplicateBarcode,
            };
            _saving = false;
          });
        }
        return;
      }
      final id = await widget.repository.create(draft);
      if (mounted) context.pop(id);
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = AppLocalizations.of(context).createProductSaveFailed;
        });
      }
    }
  }

  Future<void> _addServing() async {
    final l10n = AppLocalizations.of(context);
    final unit = await showModalBottomSheet<CustomServingUnit>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final candidate in CustomServingUnit.values)
              ListTile(
                title: Text(_servingName(l10n, candidate)),
                onTap: () => Navigator.of(context).pop(candidate),
              ),
          ],
        ),
      ),
    );
    if (unit != null && mounted) {
      setState(() => _servings.add(_ServingEditor(unit)));
    }
  }

  String _servingName(AppLocalizations l10n, CustomServingUnit unit) =>
      switch (unit) {
        CustomServingUnit.serving => l10n.createProductUnitServing,
        CustomServingUnit.piece => l10n.createProductUnitPiece,
        CustomServingUnit.glass => l10n.createProductUnitGlass,
        CustomServingUnit.scoop => l10n.createProductUnitScoop,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final macroColors = AppSemanticColors.of(context);
    final baseUnit =
        _displayBasis == CustomFoodDisplayBasis.perHundredMilliliters ||
            _displayBasis == CustomFoodDisplayBasis.perServing &&
                _servingBasis == CustomFoodBasis.milliliters
        ? l10n.unitMilliliters
        : l10n.unitGrams;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      YamIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.createProductBack,
                        onPressed: () => Navigator.of(context).maybePop(),
                        surface: false,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.foodSearchCreateFood,
                        style: AppTypography.sectionTitle.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        YamTextField(
                          fieldKey: const ValueKey('create-food-name'),
                          label: l10n.createProductName,
                          hintText: l10n.createProductNameHint,
                          controller: _name,
                          errorText: _errors['name'],
                          onChanged: _changed,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        RawAutocomplete<String>(
                          textEditingController: _brand,
                          focusNode: _brandFocus,
                          displayStringForOption: (brand) => brand,
                          optionsBuilder: (value) async =>
                              UserFoodRepository.matchingBrands(
                                await _brands,
                                value.text,
                              ),
                          fieldViewBuilder:
                              (context, controller, focusNode, onSubmitted) =>
                                  YamTextField(
                                    fieldKey: const ValueKey(
                                      'create-food-brand',
                                    ),
                                    label: l10n.createProductBrand,
                                    hintText: l10n.createProductBrandHint,
                                    controller: controller,
                                    focusNode: focusNode,
                                    onSubmitted: (_) => onSubmitted(),
                                  ),
                          optionsViewBuilder: (context, onSelected, options) {
                            final candidates = options.toList();
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                color: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.control,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: AppSpacing.xxl * 5,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: candidates.length,
                                    itemBuilder: (context, index) {
                                      final candidate = candidates[index];
                                      final highlighted =
                                          AutocompleteHighlightedOption.of(
                                            context,
                                          ) ==
                                          index;
                                      return Material(
                                        color: highlighted
                                            ? theme.colorScheme.primaryContainer
                                            : Colors.transparent,
                                        child: InkWell(
                                          onTap: () => onSelected(candidate),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minHeight: 48,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.md,
                                                    vertical: AppSpacing.sm,
                                                  ),
                                              child: Text(
                                                candidate,
                                                style: AppTypography
                                                    .productTitle
                                                    .copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        YamSelectField<FoodSearchPrototypeCategory>(
                          fieldKey: const ValueKey('create-food-category'),
                          label: l10n.createProductCategory,
                          value: _category,
                          items: [
                            for (final category
                                in FoodSearchPrototypeCategory.values)
                              YamDropdownOption(
                                value: category,
                                label: foodSearchCategoryLabel(l10n, category),
                              ),
                          ],
                          onChanged: (category) =>
                              setState(() => _category = category),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Divider(color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.createProductNutrition,
                          style: AppTypography.sectionTitle.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.createProductNutritionBasis,
                          style: AppTypography.label.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final basis
                                  in CustomFoodDisplayBasis.values) ...[
                                YamFilterChip(
                                  key: ValueKey('create-basis-${basis.name}'),
                                  label: switch (basis) {
                                    CustomFoodDisplayBasis.perHundredGrams =>
                                      l10n.createProductPerHundredGrams,
                                    CustomFoodDisplayBasis
                                        .perHundredMilliliters =>
                                      l10n.createProductPerHundredMilliliters,
                                    CustomFoodDisplayBasis.perServing =>
                                      l10n.createProductPerServing,
                                  },
                                  selected: _displayBasis == basis,
                                  onPressed: () => setState(() {
                                    _displayBasis = basis;
                                    _errors = const {};
                                  }),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                            ],
                          ),
                        ),
                        if (_displayBasis ==
                            CustomFoodDisplayBasis.perServing) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              for (final basis in CustomFoodBasis.values) ...[
                                YamFilterChip(
                                  label: basis == CustomFoodBasis.grams
                                      ? l10n.unitGrams
                                      : l10n.unitMilliliters,
                                  selected: _servingBasis == basis,
                                  onPressed: () =>
                                      setState(() => _servingBasis = basis),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          YamNumberField(
                            fieldKey: const ValueKey('create-serving-size'),
                            label: l10n.createProductServingSize,
                            unit: baseUnit,
                            controller: _servingSize,
                            onChanged: _changed,
                            decimal: true,
                            style: YamNumberFieldStyle.compact,
                            errorText: _errors['servingSize'],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked =
                                constraints.maxWidth < 350 ||
                                MediaQuery.textScalerOf(context).scale(14) > 20;
                            final fields = [
                              YamNumberField(
                                fieldKey: const ValueKey('create-food-protein'),
                                label: l10n.macroProtein,
                                unit: l10n.unitGrams,
                                controller: _protein,
                                onChanged: _changed,
                                decimal: true,
                                style: YamNumberFieldStyle.compact,
                                indicatorColor: macroColors.protein,
                                errorText: _errors['protein'],
                              ),
                              YamNumberField(
                                fieldKey: const ValueKey('create-food-fat'),
                                label: l10n.macroFat,
                                unit: l10n.unitGrams,
                                controller: _fat,
                                onChanged: _changed,
                                decimal: true,
                                style: YamNumberFieldStyle.compact,
                                indicatorColor: macroColors.fat,
                                errorText: _errors['fat'],
                              ),
                              YamNumberField(
                                fieldKey: const ValueKey('create-food-carbs'),
                                label: l10n.macroCarbs,
                                unit: l10n.unitGrams,
                                controller: _carbs,
                                onChanged: _changed,
                                decimal: true,
                                style: YamNumberFieldStyle.compact,
                                indicatorColor: macroColors.carbs,
                                errorText: _errors['carbs'],
                              ),
                            ];
                            return stacked
                                ? Column(
                                    children: [
                                      for (final field in fields) ...[
                                        field,
                                        const SizedBox(height: AppSpacing.xs),
                                      ],
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final field in fields) ...[
                                        Expanded(child: field),
                                        if (field != fields.last)
                                          const SizedBox(width: AppSpacing.xs),
                                      ],
                                    ],
                                  );
                          },
                        ),
                        if (_calculatedEnergy case final energy?) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.createProductCalculatedCalories(
                              formatFoodSearchNumber(context, energy),
                            ),
                            style: AppTypography.label.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Divider(color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.createProductServings,
                          style: AppTypography.sectionTitle.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (
                          var index = 0;
                          index < _servings.length;
                          index++
                        ) ...[
                          _buildServing(l10n, index, baseUnit),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        YamSecondaryButton(
                          label: l10n.createProductAddServing,
                          onPressed: _addServing,
                          icon: Icons.add_rounded,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        YamTextField(
                          fieldKey: const ValueKey('create-food-barcode'),
                          label: l10n.createProductBarcode,
                          controller: _barcode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          errorText: _errors['barcode'],
                          onChanged: _changed,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_saveError != null) ...[
                        Text(
                          _saveError!,
                          style: AppTypography.caption.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      YamPrimaryButton(
                        label: _saving
                            ? l10n.createProductSaving
                            : l10n.createProductSave,
                        onPressed: _saving ? null : _save,
                        expanded: true,
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
    );
  }

  Widget _buildServing(AppLocalizations l10n, int index, String baseUnit) {
    final editor = _servings[index];
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _servingName(l10n, editor.unit),
                    style: AppTypography.productTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                YamIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.createProductRemoveServing,
                  visualSize: 32,
                  onPressed: () {
                    setState(() => _servings.removeAt(index));
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => editor.dispose(),
                    );
                  },
                ),
              ],
            ),
            if (editor.unit == CustomServingUnit.serving) ...[
              YamTextField(
                label: l10n.createProductServingName,
                hintText: l10n.createProductServingNameHint,
                controller: editor.name,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            YamNumberField(
              fieldKey: ValueKey('create-serving-$index-amount'),
              label: l10n.createProductServingAmount,
              unit: baseUnit,
              controller: editor.amount,
              decimal: true,
              style: YamNumberFieldStyle.compact,
              onChanged: _changed,
              errorText: _errors['serving$index'],
            ),
          ],
        ),
      ),
    );
  }
}
