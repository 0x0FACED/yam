import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/widgets/food_quick_add_sheet.dart';
import 'package:yam/features/food_search/presentation/widgets/food_search_result_row.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    this.arguments = const FoodSearchPrototypeArguments(),
    super.key,
  });

  final FoodSearchPrototypeArguments arguments;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  static const _maxContentWidth = 760.0;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  Locale? _catalogLocale;
  List<FoodSearchPrototypeFood> _foods = const [];
  List<FoodSearchPrototypeFood> _results = const [];
  List<FoodSearchPrototypeFood> _frequent = const [];
  List<FoodSearchPrototypeFood> _recent = const [];
  List<FoodSearchPrototypeFood> _favorites = const [];
  String? _selectedMealId;

  @override
  void initState() {
    super.initState();
    _selectedMealId = widget.arguments.initialMealId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_catalogLocale != locale) {
      _catalogLocale = locale;
      _foods = buildFoodSearchPrototypeFoods(locale);
      _updateVisibleFoods();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedMeal = _selectedMealId == null
        ? null
        : buildFoodSearchPrototypeMeals(
            l10n,
          ).firstWhere((meal) => meal.id == _selectedMealId);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 76,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              tooltip: l10n.foodSearchBack,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: SearchBar(
                  key: const ValueKey('food-search-field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.foodSearchHint,
                  textInputAction: TextInputAction.search,
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainer,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                  ),
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        tooltip: l10n.foodSearchClear,
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                  onChanged: (_) => setState(_updateVisibleFoods),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('food-search-meal'),
                        onPressed: _selectMeal,
                        icon: Icon(
                          selectedMeal?.icon ?? Icons.restaurant_outlined,
                        ),
                        label: Text(
                          selectedMeal == null
                              ? l10n.foodSearchChooseMeal
                              : l10n.foodSearchSelectedMeal(selectedMeal.name),
                        ),
                      ),
                      TextButton.icon(
                        key: const ValueKey('food-search-create-food'),
                        onPressed: _showCreateFoodPlaceholder,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: Text(l10n.foodSearchCreateFood),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: CustomScrollView(
                    key: const ValueKey('food-search-scroll-view'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: _searchController.text.trim().isEmpty
                        ? _buildLandingSlivers(l10n)
                        : _buildResultSlivers(l10n),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLandingSlivers(AppLocalizations l10n) {
    return [
      ..._buildSection(l10n.foodSearchFrequent, _frequent),
      ..._buildSection(l10n.foodSearchRecent, _recent),
      ..._buildSection(l10n.foodSearchFavorites, _favorites),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  List<Widget> _buildResultSlivers(AppLocalizations l10n) {
    if (_results.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptySearchState(
            title: l10n.foodSearchNoResultsTitle,
            message: l10n.foodSearchNoResultsMessage,
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(child: _SectionHeader(title: l10n.foodSearchResults)),
      SliverList.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) => _buildFoodRow(_results[index]),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  List<Widget> _buildSection(
    String title,
    List<FoodSearchPrototypeFood> foods,
  ) {
    if (foods.isEmpty) {
      return const [];
    }
    return [
      SliverToBoxAdapter(child: _SectionHeader(title: title)),
      SliverList.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) => _buildFoodRow(foods[index]),
      ),
    ];
  }

  Widget _buildFoodRow(FoodSearchPrototypeFood food) {
    return FoodSearchResultRow(
      key: ValueKey('food-row-${food.id}'),
      food: food,
      onOpen: () => _openQuickAdd(food),
      onQuickAdd: () => _quickAdd(food),
    );
  }

  void _updateVisibleFoods() {
    final query = _searchController.text.trim().toLowerCase();
    _results = query.isEmpty
        ? const []
        : _foods
              .where(
                (food) =>
                    food.name.toLowerCase().contains(query) ||
                    (food.brand?.toLowerCase().contains(query) ?? false),
              )
              .toList(growable: false);

    final frequent = _selectedMealId == null
        ? _foods.where((food) => food.frequentMealIds.isNotEmpty)
        : _foods.where(
            (food) => food.frequentMealIds.contains(_selectedMealId),
          );
    _frequent = frequent.take(3).toList(growable: false);
    _recent = _foods
        .where((food) => food.recent)
        .take(4)
        .toList(growable: false);
    _favorites = _foods
        .where((food) => food.favorite)
        .take(4)
        .toList(growable: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(_updateVisibleFoods);
    _searchFocusNode.requestFocus();
  }

  Future<void> _selectMeal() async {
    final mealId = await _showMealPicker();
    if (!mounted || mealId == null) {
      return;
    }
    setState(() {
      _selectedMealId = mealId;
      _updateVisibleFoods();
    });
  }

  Future<String?> _showMealPicker() {
    final l10n = AppLocalizations.of(context);
    final meals = buildFoodSearchPrototypeMeals(l10n);
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.foodSearchSelectMealTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          for (final meal in meals)
            ListTile(
              leading: Icon(meal.icon),
              title: Text(meal.name),
              trailing: meal.id == _selectedMealId
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(context).pop(meal.id),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _openQuickAdd(FoodSearchPrototypeFood food) async {
    final result = await showFoodQuickAddSheet(
      context: context,
      food: food,
      initialMealId: _selectedMealId,
    );
    if (mounted && result != null) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _quickAdd(FoodSearchPrototypeFood food) async {
    var mealId = _selectedMealId;
    mealId ??= await _showMealPicker();
    if (!mounted || mealId == null) {
      return;
    }

    final serving = food.lastServing;
    final nutrition = food.nutritionFor(serving, food.lastAmount);
    Navigator.of(context).pop(
      FoodAddPrototypeResult(
        foodId: food.id,
        name: food.name,
        brand: food.brand,
        quantityLabel: formatFoodSearchQuantity(
          context,
          serving.unit,
          food.lastAmount,
        ),
        mealId: mealId,
        calories: nutrition.calories.round(),
        protein: nutrition.protein,
        fat: nutrition.fat,
        carbs: nutrition.carbs,
      ),
    );
  }

  void _showCreateFoodPlaceholder() {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).foodSearchCreateFoodPlaceholder,
          ),
        ),
      );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
