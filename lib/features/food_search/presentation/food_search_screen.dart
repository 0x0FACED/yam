import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/widgets/food_quick_add_sheet.dart';
import 'package:yam/features/food_search/presentation/widgets/food_search_result_row.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

enum _FoodSearchTab { forYou, recent, myDishes, favorites }

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
  List<FoodSearchPrototypeFood> _myDishes = const [];
  List<FoodSearchPrototypeFood> _favorites = const [];
  late FoodSearchPrototypeCatalogState _catalogState;
  _FoodSearchTab _selectedTab = _FoodSearchTab.forYou;
  String? _selectedMealId;

  @override
  void initState() {
    super.initState();
    _selectedMealId = widget.arguments.initialMealId;
    _catalogState = widget.arguments.initialCatalogState;
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              key: const ValueKey('food-search-back'),
                              tooltip: l10n.foodSearchBack,
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: SearchBar(
                                key: const ValueKey('food-search-field'),
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                hintText: l10n.foodSearchHint,
                                textInputAction: TextInputAction.search,
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                                elevation: const WidgetStatePropertyAll(0),
                                backgroundColor: WidgetStatePropertyAll(
                                  theme.colorScheme.surfaceContainer,
                                ),
                                side: WidgetStateProperty.resolveWith((states) {
                                  return BorderSide(
                                    color: states.contains(WidgetState.focused)
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outlineVariant,
                                  );
                                }),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.control,
                                    ),
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
                                onChanged: (_) {
                                  setState(_updateVisibleFoods);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xxs,
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
                                    : l10n.foodSearchSelectedMeal(
                                        selectedMeal.name,
                                      ),
                              ),
                            ),
                            TextButton.icon(
                              key: const ValueKey('food-search-create-food'),
                              onPressed: _openCreateFood,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(l10n.foodSearchCreateFood),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final tab in _FoodSearchTab.values) ...[
                                _FoodSearchTabButton(
                                  key: ValueKey('food-search-tab-${tab.name}'),
                                  label: _tabLabel(l10n, tab),
                                  selected: _selectedTab == tab,
                                  onPressed: () => _selectTab(tab),
                                ),
                                if (tab != _FoodSearchTab.values.last)
                                  const SizedBox(width: AppSpacing.xs),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : AppMotion.smallChange,
                    switchInCurve: AppMotion.standardCurve,
                    switchOutCurve: AppMotion.standardCurve,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [...previousChildren, ?currentChild],
                      );
                    },
                    child: CustomScrollView(
                      key: ValueKey(_contentKey),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: _buildContentSlivers(l10n, selectedMeal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _contentKey {
    if (_catalogState != FoodSearchPrototypeCatalogState.ready) {
      return 'food-search-${_catalogState.name}';
    }
    if (_searchController.text.trim().isNotEmpty) {
      return 'food-search-results';
    }
    return 'food-search-${_selectedTab.name}';
  }

  List<Widget> _buildContentSlivers(
    AppLocalizations l10n,
    FoodSearchPrototypeMeal? selectedMeal,
  ) {
    return switch (_catalogState) {
      FoodSearchPrototypeCatalogState.loading => _buildLoadingSlivers(l10n),
      FoodSearchPrototypeCatalogState.error => _buildErrorSlivers(l10n),
      FoodSearchPrototypeCatalogState.ready =>
        _searchController.text.trim().isEmpty
            ? _buildLandingSlivers(l10n, selectedMeal)
            : _buildResultSlivers(l10n),
    };
  }

  List<Widget> _buildLandingSlivers(
    AppLocalizations l10n,
    FoodSearchPrototypeMeal? selectedMeal,
  ) {
    switch (_selectedTab) {
      case _FoodSearchTab.forYou:
        return [
          ..._buildSection(
            selectedMeal == null
                ? l10n.foodSearchFrequent
                : l10n.foodSearchFrequentForMeal(selectedMeal.name),
            _frequent,
          ),
          ..._buildSection(l10n.foodSearchRecent, _recent),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ];
      case _FoodSearchTab.recent:
        return _buildSingleTabSlivers(l10n.foodSearchRecent, _recent, l10n);
      case _FoodSearchTab.myDishes:
        return _buildSingleTabSlivers(l10n.foodSearchMyDishes, _myDishes, l10n);
      case _FoodSearchTab.favorites:
        return _buildSingleTabSlivers(
          l10n.foodSearchFavorites,
          _favorites,
          l10n,
        );
    }
  }

  List<Widget> _buildSingleTabSlivers(
    String title,
    List<FoodSearchPrototypeFood> foods,
    AppLocalizations l10n,
  ) {
    if (foods.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _FoodSearchFeedbackState(
            icon: Icons.restaurant_menu_rounded,
            title: l10n.foodSearchTabEmptyTitle,
            message: l10n.foodSearchTabEmptyMessage,
          ),
        ),
      ];
    }
    return [
      ..._buildSection(title, foods),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  List<Widget> _buildResultSlivers(AppLocalizations l10n) {
    if (_results.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _FoodSearchFeedbackState(
            icon: Icons.search_off_rounded,
            title: l10n.foodSearchNoResultsTitle,
            message: l10n.foodSearchNoResultsMessage,
            actionKey: const ValueKey('food-search-empty-create-food'),
            actionLabel: l10n.foodSearchCreateFood,
            actionIcon: Icons.add_rounded,
            onAction: _openCreateFood,
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

  List<Widget> _buildLoadingSlivers(AppLocalizations l10n) {
    return [
      SliverToBoxAdapter(
        child: Semantics(
          container: true,
          label: l10n.foodSearchLoading,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (var index = 0; index < 4; index++)
                    const _FoodSearchLoadingRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildErrorSlivers(AppLocalizations l10n) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: _FoodSearchFeedbackState(
          icon: Icons.error_outline_rounded,
          title: l10n.foodSearchErrorTitle,
          message: l10n.foodSearchErrorMessage,
          actionKey: const ValueKey('food-search-retry'),
          actionLabel: l10n.actionRetry,
          actionIcon: Icons.refresh_rounded,
          onAction: () {
            setState(() {
              _catalogState = FoodSearchPrototypeCatalogState.ready;
            });
          },
        ),
      ),
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

  String _tabLabel(AppLocalizations l10n, _FoodSearchTab tab) {
    return switch (tab) {
      _FoodSearchTab.forYou => l10n.foodSearchForYou,
      _FoodSearchTab.recent => l10n.foodSearchRecent,
      _FoodSearchTab.myDishes => l10n.foodSearchMyDishes,
      _FoodSearchTab.favorites => l10n.foodSearchFavorites,
    };
  }

  void _selectTab(_FoodSearchTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
    });
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
    _frequent = frequent.take(4).toList(growable: false);
    _recent = _foods
        .where((food) => food.recent)
        .take(6)
        .toList(growable: false);
    _myDishes = _foods
        .where((food) => food.source == FoodSearchPrototypeSource.userCreated)
        .toList(growable: false);
    _favorites = _foods.where((food) => food.favorite).toList(growable: false);
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
              style: Theme.of(context).textTheme.titleLarge,
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

  void _openCreateFood() {
    context.push<void>('/add-food/create');
  }
}

class _FoodSearchTabButton extends StatelessWidget {
  const _FoodSearchTabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : AppMotion.smallChange,
            curve: AppMotion.standardCurve,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainer,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
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
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _FoodSearchFeedbackState extends StatelessWidget {
  const _FoodSearchFeedbackState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionKey,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Key? actionKey;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

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
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(
                    icon,
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  key: actionKey,
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodSearchLoadingRow extends StatelessWidget {
  const _FoodSearchLoadingRow();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.48,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FractionallySizedBox(
            widthFactor: 0.3,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FractionallySizedBox(
            widthFactor: 0.64,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
