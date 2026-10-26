import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/feedback/yam_feedback_state.dart';
import 'package:yam/core/ui/forms/yam_search_field.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/custom_food_adapter.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';
import 'package:yam/features/food_search/data/remote_food_repository.dart';
import 'package:yam/features/food_search/presentation/remote_food_adapter.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/widgets/food_quick_add_sheet.dart';
import 'package:yam/features/food_search/presentation/widgets/food_search_result_row.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

enum _FoodSearchTab { recent, myDishes, favorites }

enum _RemoteSearchState { idle, shortQuery, loading, ready, error }

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    this.arguments = const FoodSearchPrototypeArguments(),
    this.userFoodRepository,
    this.remoteFoodRepository,
    this.openFoodFactsClient,
    this.diaryRepository,
    super.key,
  });

  final FoodSearchPrototypeArguments arguments;
  final UserFoodRepository? userFoodRepository;
  final RemoteFoodRepository? remoteFoodRepository;
  final OpenFoodFactsSearchClient? openFoodFactsClient;
  final DiaryRepository? diaryRepository;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  static const _maxContentWidth = 448.0;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  StreamSubscription<List<SavedUserFood>>? _savedFoodSubscription;
  StreamSubscription<List<StoredRemoteFood>>? _remoteFoodSubscription;
  StreamSubscription<List<String>>? _recentSubscription;
  List<SavedUserFood> _savedFoods = const [];
  List<StoredRemoteFood> _savedRemoteFoods = const [];
  List<OpenFoodFactsProduct> _remoteResults = const [];
  _RemoteSearchState _remoteState = _RemoteSearchState.idle;
  Timer? _remoteDebounce;
  int _remoteGeneration = 0;

  static const _minRemoteQueryLength = 3;
  static const _remoteDelay = Duration(milliseconds: 650);
  late List<String> _recentFoodIds;
  late Set<String> _favoriteOverrides;

  Locale? _catalogLocale;
  List<FoodSearchPrototypeFood> _foods = const [];
  List<FoodSearchPrototypeFood> _results = const [];
  List<FoodSearchPrototypeFood> _recent = const [];
  List<FoodSearchPrototypeFood> _myDishes = const [];
  List<FoodSearchPrototypeFood> _favorites = const [];
  bool _recentHasRemoteFood = false;
  bool _favoritesHaveRemoteFood = false;
  late FoodSearchPrototypeCatalogState _catalogState;
  _FoodSearchTab _selectedTab = _FoodSearchTab.recent;
  String? _selectedMealId;

  @override
  void initState() {
    super.initState();
    _selectedMealId = widget.arguments.initialMealId;
    _catalogState = widget.arguments.initialCatalogState;
    _recentFoodIds = List.of(widget.arguments.recentFoodIds);
    _recentSubscription = widget.diaryRepository?.watchRecentFoodIds().listen((
      ids,
    ) {
      if (mounted) {
        setState(() {
          _recentFoodIds = ids;
          _updateVisibleFoods();
        });
      }
    });
    _favoriteOverrides = Set.of(widget.arguments.favoriteOverrides);
    _savedFoodSubscription = widget.userFoodRepository?.watchFoods().listen((
      foods,
    ) {
      if (!mounted) return;
      setState(() {
        _savedFoods = foods;
        _refreshFoods();
      });
    });
    _remoteFoodSubscription = widget.remoteFoodRepository?.watchFoods().listen((
      foods,
    ) {
      if (!mounted) return;
      setState(() {
        _savedRemoteFoods = foods;
        _refreshFoods();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_catalogLocale != locale) {
      _catalogLocale = locale;
      _refreshFoods();
    }
  }

  @override
  void dispose() {
    _savedFoodSubscription?.cancel();
    _remoteFoodSubscription?.cancel();
    _recentSubscription?.cancel();
    _remoteDebounce?.cancel();
    _remoteGeneration++;
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _refreshFoods() {
    final locale = _catalogLocale;
    if (locale == null) return;
    _foods = [
      ...buildFoodSearchPrototypeFoods(locale),
      ...adaptUserFoods(_savedFoods, AppLocalizations.of(context)),
      for (final remote in _savedRemoteFoods)
        adaptRemoteFood(
          productFromStoredRemoteFood(remote),
          favorite: remote.isFavorite,
          lastAmount: remote.lastAmount,
        ),
    ];
    _updateVisibleFoods();
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
                  onSearchChanged: _onSearchChanged,
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
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior(),
                      child: CustomScrollView(
                        key: ValueKey(_contentKey),
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: _buildContentSlivers(l10n),
                      ),
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

  List<Widget> _buildContentSlivers(AppLocalizations l10n) {
    return switch (_catalogState) {
      FoodSearchPrototypeCatalogState.loading => _buildLoadingSlivers(l10n),
      FoodSearchPrototypeCatalogState.error => _buildErrorSlivers(l10n),
      FoodSearchPrototypeCatalogState.ready =>
        _searchController.text.trim().isEmpty
            ? _buildLandingSlivers(l10n)
            : _buildResultSlivers(l10n),
    };
  }

  List<Widget> _buildLandingSlivers(AppLocalizations l10n) {
    switch (_selectedTab) {
      case _FoodSearchTab.recent:
        return _buildSingleTabSlivers(
          l10n.foodSearchRecent,
          _recent,
          l10n,
          showRemoteAttribution: _recentHasRemoteFood,
        );
      case _FoodSearchTab.myDishes:
        return _buildSingleTabSlivers(l10n.foodSearchMyDishes, _myDishes, l10n);
      case _FoodSearchTab.favorites:
        return _buildSingleTabSlivers(
          l10n.foodSearchFavorites,
          _favorites,
          l10n,
          showRemoteAttribution: _favoritesHaveRemoteFood,
        );
    }
  }

  List<Widget> _buildSingleTabSlivers(
    String title,
    List<FoodSearchPrototypeFood> foods,
    AppLocalizations l10n, {
    bool showRemoteAttribution = false,
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
      ..._buildSection(title, foods),
      if (showRemoteAttribution)
        SliverToBoxAdapter(child: _buildRemoteAttribution(l10n)),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  List<Widget> _buildResultSlivers(AppLocalizations l10n) {
    final remoteEnabled = widget.openFoodFactsClient != null;
    if (_results.isEmpty && !remoteEnabled) {
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

    final remoteFoods = [
      for (final result in _remoteResults)
        adaptRemoteFood(result, favorite: _remoteFavorite(result.code)),
    ];
    return [
      if (_results.isNotEmpty)
        ..._buildSection(l10n.foodSearchResults, _results),
      if (remoteEnabled) ...[
        SliverToBoxAdapter(
          child: _SectionHeader(title: l10n.foodSearchOpenFoodFacts),
        ),
        if (remoteFoods.isNotEmpty)
          SliverList.builder(
            itemCount: remoteFoods.length,
            itemBuilder: (context, index) => _buildFoodRow(remoteFoods[index]),
          ),
        if (_remoteState == _RemoteSearchState.loading)
          SliverToBoxAdapter(
            child: Semantics(
              liveRegion: true,
              label: l10n.foodSearchRemoteLoading,
              child: const YamProductRowSkeleton(),
            ),
          ),
        if (_remoteState == _RemoteSearchState.shortQuery ||
            (_remoteState == _RemoteSearchState.ready && remoteFoods.isEmpty) ||
            _remoteState == _RemoteSearchState.error)
          SliverToBoxAdapter(child: _buildRemoteFeedback(l10n)),
        SliverToBoxAdapter(child: _buildRemoteAttribution(l10n)),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }

  Widget _buildRemoteFeedback(AppLocalizations l10n) {
    final error = _remoteState == _RemoteSearchState.error;
    final message = switch (_remoteState) {
      _RemoteSearchState.shortQuery => l10n.foodSearchRemoteShortQuery,
      _RemoteSearchState.error => l10n.foodSearchRemoteError,
      _ => l10n.foodSearchRemoteEmpty,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (error)
            YamTextButton(
              key: const ValueKey('food-search-off-retry'),
              label: l10n.actionRetry,
              icon: Icons.refresh_rounded,
              onPressed: _retryRemote,
              tone: YamTextButtonTone.accent,
            ),
        ],
      ),
    );
  }

  Widget _buildRemoteAttribution(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: Wrap(
      children: [
        YamTextButton(
          label: l10n.foodSearchRemoteAttribution,
          onPressed: () => unawaited(
            _openRemoteLink(Uri.https('world.openfoodfacts.org', '/')),
          ),
        ),
        YamTextButton(
          label: l10n.foodSearchRemoteLicense,
          onPressed: () => unawaited(
            _openRemoteLink(
              Uri.https('opendatacommons.org', '/licenses/odbl/1.0/'),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _openRemoteLink(Uri url) async {
    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
    } on Object {
      // Keep the local search usable if no browser is available.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).foodSearchRemoteLinkError),
        ),
      );
    }
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
    final editable =
        food.source == FoodSearchPrototypeSource.userCreated &&
        widget.userFoodRepository != null;
    return FoodSearchResultRow(
      key: ValueKey('food-row-${food.id}'),
      food: food,
      favorite: _isFavorite(food),
      onOpen: () => _openQuickAdd(food),
      onEdit: editable ? () => _openEditFood(food.id) : null,
      onDelete: editable ? () => _confirmDelete(food) : null,
    );
  }

  void _onSearchChanged(String _) {
    setState(_updateVisibleFoods);
    _scheduleRemote();
  }

  void _scheduleRemote({bool immediate = false}) {
    _remoteDebounce?.cancel();
    final generation = ++_remoteGeneration;
    final query = _searchController.text.trim();
    if (widget.openFoodFactsClient == null) return;
    setState(() {
      _remoteResults = const [];
      _remoteState = query.isEmpty
          ? _RemoteSearchState.idle
          : query.runes.length < _minRemoteQueryLength
          ? _RemoteSearchState.shortQuery
          : _RemoteSearchState.loading;
    });
    if (_remoteState != _RemoteSearchState.loading) return;
    if (immediate) {
      unawaited(_loadRemote(query, generation));
    } else {
      _remoteDebounce = Timer(
        _remoteDelay,
        () => unawaited(_loadRemote(query, generation)),
      );
    }
  }

  void _retryRemote() => _scheduleRemote(immediate: true);

  Future<void> _loadRemote(String query, int generation) async {
    try {
      final results = await widget.openFoodFactsClient!.search(
        query,
        Localizations.localeOf(context).languageCode,
      );
      if (!mounted || generation != _remoteGeneration) return;
      setState(() {
        _remoteResults = results;
        _remoteState = _RemoteSearchState.ready;
      });
    } on Object {
      if (!mounted || generation != _remoteGeneration) return;
      setState(() => _remoteState = _RemoteSearchState.error);
    }
  }

  Future<void> _confirmDelete(FoodSearchPrototypeFood food) async {
    final repository = widget.userFoodRepository;
    if (repository == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createProductDeleteTitle),
        content: Text(l10n.createProductDeleteMessage(food.name)),
        actions: [
          YamTextButton(
            label: l10n.createProductDeleteCancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          YamTextButton(
            label: l10n.createProductDelete,
            tone: YamTextButtonTone.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await repository.delete(food.id);
      if (!mounted) return;
      showYamSuccessSnackBar(
        context: context,
        message: l10n.createProductDeleted(food.name),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createProductDeleteFailed)));
    }
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

    final foodsById = {for (final food in _foods) food.id: food};
    _recent = [
      for (final id in _recentFoodIds.take(foodSearchRecentLimit))
        ?foodsById[id],
    ];
    _myDishes = _foods
        .where((food) => food.source == FoodSearchPrototypeSource.userCreated)
        .toList(growable: false);
    _favorites = _foods.where(_isFavorite).toList(growable: false);
    _recentHasRemoteFood = _recent.any(
      (food) => food.source == FoodSearchPrototypeSource.openFoodFacts,
    );
    _favoritesHaveRemoteFood = _favorites.any(
      (food) => food.source == FoodSearchPrototypeSource.openFoodFacts,
    );
  }

  bool _isFavorite(FoodSearchPrototypeFood food) =>
      food.source == FoodSearchPrototypeSource.openFoodFacts
      ? _remoteFavorite(food.id.substring(4))
      : _favoriteOverrides.contains(food.id) != food.favorite;

  bool _remoteFavorite(String code) => _savedRemoteFoods.any(
    (saved) => saved.sourceCode == code && saved.isFavorite,
  );

  OpenFoodFactsProduct _offProductFor(FoodSearchPrototypeFood food) {
    final code = food.id.substring(4);
    // Use the food opened in the sheet, even if the search changed meanwhile.
    return OpenFoodFactsProduct(
      code: code,
      name: food.name,
      brand: food.brand,
      category: food.category,
      energyKcal: food.nutrition.calories,
      proteinG: food.nutrition.protein,
      fatG: food.nutrition.fat,
      carbsG: food.nutrition.carbs,
    );
  }

  Future<void> _setFavorite(FoodSearchPrototypeFood food, bool favorite) async {
    if (food.source == FoodSearchPrototypeSource.openFoodFacts) {
      final repository = widget.remoteFoodRepository!;
      await repository.setFavorite(_offProductFor(food), favorite);
      final foods = await repository.loadFoods();
      if (mounted) {
        setState(() {
          _savedRemoteFoods = foods;
          _refreshFoods();
        });
      }
      return;
    }
    final repository = widget.userFoodRepository;
    if (food.source == FoodSearchPrototypeSource.userCreated &&
        repository != null) {
      await repository.setFavorite(food.id, favorite);
      final updated = await repository.loadFoods();
      if (mounted) {
        setState(() {
          _savedFoods = updated;
          _refreshFoods();
        });
      }
      return;
    }
    setState(() {
      if (favorite == food.favorite) {
        _favoriteOverrides.remove(food.id);
      } else {
        _favoriteOverrides.add(food.id);
      }
      _updateVisibleFoods();
    });
    widget.arguments.onFavoritesChanged?.call(
      Set.unmodifiable(_favoriteOverrides),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(_updateVisibleFoods);
    _scheduleRemote();
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
    dismissYamSnackBar(context);
    final result = await showFoodQuickAddSheet(
      context: context,
      food: food,
      initialMealId: _selectedMealId,
      favorite: _isFavorite(food),
      onFavoriteChanged: (favorite) => _setFavorite(food, favorite),
    );
    if (!mounted || result == null) return;

    final repository = widget.diaryRepository;
    String? entryId;
    try {
      if (repository != null) {
        final draft = DiaryEntryDraft(
          day: widget.arguments.diaryDay ?? DateTime.now(),
          mealId: result.mealId,
          food: result.snapshot,
          servingId: result.servingId,
          amount: result.amount,
          canonicalQuantity: result.canonicalQuantity,
        );
        entryId = food.source == FoodSearchPrototypeSource.openFoodFacts
            ? await widget.remoteFoodRepository!.addToDiary(
                _offProductFor(food),
                draft,
              )
            : await repository.create(draft);
        if (food.source == FoodSearchPrototypeSource.openFoodFacts) {
          _savedRemoteFoods = await widget.remoteFoodRepository!.loadFoods();
          if (mounted) setState(_refreshFoods);
        }
        widget.arguments.onEntryCreated?.call(entryId);
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).diarySaveFailed)),
        );
      }
      return;
    }
    if (!mounted) return;
    final previousRecent = List<String>.of(_recentFoodIds);
    setState(() {
      _selectedMealId = result.mealId;
      _recentFoodIds = [
        result.foodId,
        for (final id in _recentFoodIds)
          if (id != result.foodId) id,
      ].take(foodSearchRecentLimit).toList(growable: false);
      _updateVisibleFoods();
    });
    final l10n = AppLocalizations.of(context);
    showYamUndoSnackBar(
      context: context,
      message: l10n.foodAdded(
        result.name,
        foodSearchPrototypeMealName(l10n, result.mealId),
      ),
      undoLabel: l10n.actionUndo,
      onUndo: () {
        if (repository != null && entryId != null) {
          unawaited(_undoAddedEntry(repository, entryId));
        }
        if (mounted) {
          setState(() {
            _recentFoodIds = previousRecent;
            _updateVisibleFoods();
          });
        }
      },
    );
  }

  Future<void> _undoAddedEntry(DiaryRepository repository, String id) async {
    try {
      await repository.delete(id);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).diaryDeleteFailed)),
      );
    }
  }

  Future<void> _openEditFood(String foodId) async {
    final repository = widget.userFoodRepository;
    if (repository == null) return;
    final initialFood = _savedFoods
        .where((saved) => saved.food.id == foodId)
        .firstOrNull;
    if (initialFood == null) return;

    final id = await context.push<String>('/add-food/edit', extra: initialFood);
    if (!mounted || id == null) return;
    final saved = await repository.loadFoods();
    if (!mounted) return;
    final updated = saved.where((food) => food.food.id == id).firstOrNull;
    if (updated == null) return;
    setState(() {
      _savedFoods = saved;
      _searchFocusNode.unfocus();
      _refreshFoods();
    });
    showYamSuccessSnackBar(
      context: context,
      message: AppLocalizations.of(
        context,
      ).createProductUpdated(updated.food.name),
    );
  }

  Future<void> _openCreateFood() async {
    final id = await context.push<String>('/add-food/create');
    final repository = widget.userFoodRepository;
    if (!mounted || id == null || repository == null) return;
    final saved = await repository.loadFoods();
    if (!mounted) return;
    setState(() {
      _savedFoods = saved;
      _searchController.clear();
      _searchFocusNode.unfocus();
      _selectedTab = _FoodSearchTab.myDishes;
      _refreshFoods();
    });
    _scheduleRemote();
    final name = saved.firstWhere((food) => food.food.id == id).food.name;
    showYamSuccessSnackBar(
      context: context,
      message: AppLocalizations.of(context).createProductSaved(name),
    );
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
                    active: selectedMeal != null,
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
    _FoodSearchTab.recent => l10n.foodSearchRecent,
    _FoodSearchTab.myDishes => l10n.foodSearchMyDishes,
    _FoodSearchTab.favorites => l10n.foodSearchFavorites,
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

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
          ],
        ),
      ),
    );
  }
}
