import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_feedback_state.dart';
import 'package:yam/core/ui/forms/yam_search_field.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
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
  static const _maxContentWidth = 448.0;

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
  bool _recentCleared = false;

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
                _FoodSearchHeader(
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  selectedMeal: selectedMeal,
                  selectedTab: _selectedTab,
                  onBack: () => Navigator.of(context).maybePop(),
                  onSearchChanged: (_) => setState(_updateVisibleFoods),
                  onClearSearch: _clearSearch,
                  onSelectMeal: _selectMeal,
                  onCreateFood: _openCreateFood,
                  onSelectTab: _selectTab,
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
                    layoutBuilder: (currentChild, previousChildren) =>
                        currentChild ?? const SizedBox.shrink(),
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
                : l10n.foodSearchFrequentForMeal(
                    selectedMeal.name.toLowerCase(),
                  ),
            _frequent,
          ),
          ..._buildSection(
            l10n.foodSearchRecent,
            _recent,
            trailingLabel: l10n.actionClear,
            onTrailingPressed: _clearRecent,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ];
      case _FoodSearchTab.recent:
        return _buildSingleTabSlivers(
          l10n.foodSearchRecent,
          _recent,
          l10n,
          trailingLabel: l10n.actionClear,
          onTrailingPressed: _clearRecent,
        );
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
    AppLocalizations l10n, {
    String? trailingLabel,
    VoidCallback? onTrailingPressed,
  }) {
    if (foods.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: YamFeedbackState(
            icon: Icons.restaurant_menu_rounded,
            title: l10n.foodSearchTabEmptyTitle,
            message: l10n.foodSearchTabEmptyMessage,
          ),
        ),
      ];
    }
    return [
      ..._buildSection(
        title,
        foods,
        trailingLabel: trailingLabel,
        onTrailingPressed: onTrailingPressed,
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  List<Widget> _buildResultSlivers(AppLocalizations l10n) {
    if (_results.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: YamFeedbackState(
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
                    const YamProductRowSkeleton(),
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
        child: YamFeedbackState(
          icon: Icons.error_outline_rounded,
          title: l10n.foodSearchErrorTitle,
          message: l10n.foodSearchErrorMessage,
          actionKey: const ValueKey('food-search-retry'),
          actionLabel: l10n.actionRetry,
          actionIcon: Icons.refresh_rounded,
          error: true,
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
    List<FoodSearchPrototypeFood> foods, {
    String? trailingLabel,
    VoidCallback? onTrailingPressed,
  }) {
    if (foods.isEmpty) {
      return const [];
    }
    return [
      SliverToBoxAdapter(
        child: _SectionHeader(
          title: title,
          trailingLabel: trailingLabel,
          onTrailingPressed: onTrailingPressed,
        ),
      ),
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
    _recent = _recentCleared
        ? const []
        : _foods.where((food) => food.recent).take(6).toList(growable: false);
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

  void _clearRecent() {
    setState(() {
      _recentCleared = true;
      _recent = const [];
    });
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

class _FoodSearchHeader extends StatelessWidget {
  const _FoodSearchHeader({
    required this.searchController,
    required this.searchFocusNode,
    required this.selectedMeal,
    required this.selectedTab,
    required this.onBack,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectMeal,
    required this.onCreateFood,
    required this.onSelectTab,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final FoodSearchPrototypeMeal? selectedMeal;
  final _FoodSearchTab selectedTab;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSelectMeal;
  final VoidCallback onCreateFood;
  final ValueChanged<_FoodSearchTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xxs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                YamIconButton(
                  key: const ValueKey('food-search-back'),
                  icon: Icons.chevron_left_rounded,
                  tooltip: l10n.foodSearchBack,
                  onPressed: onBack,
                  surface: false,
                  iconSize: 26,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: YamSearchField(
                    fieldKey: const ValueKey('food-search-field'),
                    controller: searchController,
                    focusNode: searchFocusNode,
                    hintText: l10n.foodSearchHint,
                    clearTooltip: l10n.foodSearchClear,
                    onChanged: onSearchChanged,
                    onClear: onClearSearch,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stackActions =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(12) > 16;
                  final mealSelector = YamMealChip(
                    key: const ValueKey('food-search-meal'),
                    icon: selectedMeal?.icon ?? Icons.restaurant_menu_rounded,
                    label: selectedMeal == null
                        ? l10n.foodSearchChooseMeal
                        : l10n.foodSearchSelectedMeal(selectedMeal!.name),
                    onPressed: onSelectMeal,
                  );
                  final createAction = YamTextButton(
                    key: const ValueKey('food-search-create-food'),
                    label: l10n.foodSearchCreateFood,
                    icon: Icons.add_rounded,
                    onPressed: onCreateFood,
                    tone: YamTextButtonTone.accent,
                  );

                  if (stackActions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [mealSelector, createAction],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: mealSelector,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      createAction,
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in _FoodSearchTab.values) ...[
                      YamFilterChip(
                        key: ValueKey('food-search-tab-${tab.name}'),
                        label: _foodSearchTabLabel(l10n, tab),
                        selected: selectedTab == tab,
                        onPressed: () => onSelectTab(tab),
                      ),
                      if (tab != _FoodSearchTab.values.last)
                        const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _foodSearchTabLabel(AppLocalizations l10n, _FoodSearchTab tab) {
  return switch (tab) {
    _FoodSearchTab.forYou => l10n.foodSearchForYou,
    _FoodSearchTab.recent => l10n.foodSearchRecent,
    _FoodSearchTab.myDishes => l10n.foodSearchMyDishes,
    _FoodSearchTab.favorites => l10n.foodSearchFavorites,
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailingLabel,
    this.onTrailingPressed,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
            if (trailingLabel != null && onTrailingPressed != null)
              YamTextButton(
                label: trailingLabel!,
                onPressed: onTrailingPressed,
              ),
          ],
        ),
      ),
    );
  }
}
