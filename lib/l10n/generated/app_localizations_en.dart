// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'YAM';

  @override
  String get startupLoadingLabel => 'YAM is starting';

  @override
  String get navigationDiary => 'Diary';

  @override
  String get navigationStatistics => 'Stats';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get diaryToday => 'Today';

  @override
  String get diaryPreviousDay => 'Previous day';

  @override
  String get diaryNextDay => 'Next day';

  @override
  String get diaryOpenCalendar => 'Open calendar';

  @override
  String get diaryReturnToToday => 'Return to today';

  @override
  String get diaryConsumed => 'Consumed';

  @override
  String diaryCalorieGoalSuffix(String target) {
    return '/ $target kcal';
  }

  @override
  String diaryCaloriesRemaining(String remaining) {
    return '$remaining kcal left';
  }

  @override
  String diaryCaloriesOverTarget(String excess) {
    return '$excess kcal over';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroFat => 'Fat';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroProteinShort => 'P';

  @override
  String get macroFatShort => 'F';

  @override
  String get macroCarbsShort => 'C';

  @override
  String macroGramsProgress(String consumed, String target) {
    return '$consumed / $target g';
  }

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String mealCalories(String calories) {
    return '$calories kcal';
  }

  @override
  String get diaryAddFood => 'Add food';

  @override
  String diaryAddFoodToMeal(String meal) {
    return 'Add food to $meal';
  }

  @override
  String get diaryAddFoodPrototypeMessage =>
      'Food search will open here in the next prototype.';

  @override
  String get diaryNoFoods => 'No foods yet';

  @override
  String get foodSearchTitle => 'Add food';

  @override
  String get foodSearchHint => 'Search foods or dishes';

  @override
  String get foodSearchBack => 'Back to diary';

  @override
  String get foodSearchClear => 'Clear search';

  @override
  String get foodSearchChooseMeal => 'Choose meal';

  @override
  String foodSearchSelectedMeal(String meal) {
    return 'Meal: $meal';
  }

  @override
  String get foodSearchSelectMealTitle => 'Where should this food go?';

  @override
  String get foodSearchMealRequired => 'Choose a meal first';

  @override
  String get foodSearchCreateFood => 'Create food';

  @override
  String get createProductBack => 'Back to food search';

  @override
  String get createProductStubMessage =>
      'Product creation will be implemented in a later slice.';

  @override
  String get foodSearchForYou => 'For you';

  @override
  String get foodSearchFrequent => 'Frequently added';

  @override
  String foodSearchFrequentForMeal(String meal) {
    return 'Frequent for $meal';
  }

  @override
  String get foodSearchRecent => 'Recent';

  @override
  String get foodSearchMyDishes => 'My dishes';

  @override
  String get foodSearchFavorites => 'Favorites';

  @override
  String get foodSearchResults => 'Search results';

  @override
  String get foodSearchNoResultsTitle => 'Nothing found';

  @override
  String get foodSearchNoResultsMessage =>
      'Try another name or create your own food.';

  @override
  String get foodSearchTabEmptyTitle => 'Nothing here yet';

  @override
  String get foodSearchTabEmptyMessage =>
      'Foods matching this filter will appear here.';

  @override
  String get foodSearchLoading => 'Loading foods';

  @override
  String get foodSearchErrorTitle => 'Foods could not be loaded';

  @override
  String get foodSearchErrorMessage => 'Try loading the local catalog again.';

  @override
  String get foodSearchVerified => 'Verified food';

  @override
  String get foodSearchSourceLocal => 'Local catalog';

  @override
  String get foodSearchSourceUser => 'Your food';

  @override
  String foodSearchCaloriesPerReference(String calories, String quantity) {
    return '$calories kcal / $quantity';
  }

  @override
  String foodSearchQuickAdd(String quantity) {
    return '+ $quantity';
  }

  @override
  String foodSearchQuickAddSemantics(String food, String quantity) {
    return 'Add $food, $quantity';
  }

  @override
  String get quickAddTitle => 'Add to diary';

  @override
  String get quickAddQuantity => 'Quantity';

  @override
  String get quickAddUnit => 'Unit';

  @override
  String get quickAddMeal => 'Meal';

  @override
  String get quickAddNutrition => 'For this amount';

  @override
  String get quickAddDecrease => 'Decrease quantity';

  @override
  String get quickAddIncrease => 'Increase quantity';

  @override
  String get quickAddAmountInvalid => 'Enter a quantity greater than zero';

  @override
  String get quickAddAdd => 'Add';

  @override
  String get quickAddQuickSelect => 'Quick select';

  @override
  String quickAddUsualAmount(String quantity) {
    return 'Usually: $quantity';
  }

  @override
  String quickAddSelectedMeal(String meal) {
    return 'In $meal';
  }

  @override
  String get quickAddClose => 'Close quick add';

  @override
  String quickAddAddCalories(String calories) {
    return 'Add · $calories kcal';
  }

  @override
  String quickAddAddToMeal(String meal, String calories) {
    return 'Add to $meal · $calories kcal';
  }

  @override
  String foodAdded(String food, String meal) {
    return '$food added to $meal';
  }

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionRetry => 'Retry';

  @override
  String get unitKilocalories => 'kcal';

  @override
  String get unitGrams => 'g';

  @override
  String get unitMilliliters => 'ml';

  @override
  String get unitPieces => 'pcs';

  @override
  String get unitServings => 'serving';

  @override
  String get unitScoops => 'scoop';

  @override
  String get unitGlasses => 'glass';

  @override
  String quantityServings(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String quantityScoops(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value scoops',
      one: '1 scoop',
    );
    return '$_temp0';
  }

  @override
  String quantityGlasses(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value glasses',
      one: '1 glass',
    );
    return '$_temp0';
  }

  @override
  String quantityGrams(num value) {
    return '$value g';
  }

  @override
  String quantityMilliliters(num value) {
    return '$value ml';
  }

  @override
  String quantityPieces(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value pcs',
      one: '1 pc',
    );
    return '$_temp0';
  }

  @override
  String get demoEggs => 'Boiled eggs';

  @override
  String get demoBread => 'Whole-grain bread';

  @override
  String get demoMilk => 'Pasteurized milk 2.5%';

  @override
  String get demoChickenBreast => 'Grilled chicken breast';

  @override
  String get demoRice => 'Rice';

  @override
  String get demoCottageCheese => 'Cottage cheese';

  @override
  String get demoBanana => 'Banana';

  @override
  String get demoYogurt => 'Natural Greek yogurt 2%';

  @override
  String get demoProtein => 'Protein powder';

  @override
  String get demoApple => 'Green apple';

  @override
  String get diaryDemoBuckwheat => 'Buckwheat porridge';

  @override
  String get diaryDemoVegetableSalad => 'Fresh vegetable salad';

  @override
  String get diaryDemoOliveOil => 'Extra virgin olive oil';

  @override
  String get diaryDemoSteamedSalmon => 'Steamed salmon fillet';

  @override
  String get diaryDemoSteamedVegetables => 'Steamed broccoli and carrots';

  @override
  String get diaryDemoAvocado => 'Hass avocado';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsPrototypeMessage =>
      'Nutrition and weight trends will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGoalsSection => 'Goals';

  @override
  String get settingsGoalsNutrition => 'Goals & nutrition';

  @override
  String settingsGoalsSummary(
    String calories,
    String protein,
    String fat,
    String carbs,
  ) {
    return '$calories kcal · P $protein · F $fat · C $carbs';
  }

  @override
  String get settingsWeight => 'Weight';

  @override
  String settingsWeightSummary(String current, String target) {
    return '$current kg → $target kg';
  }

  @override
  String get settingsApplicationSection => 'App';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsUnitsMetric => 'Metric';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsDeleteAllData => 'Delete all data';

  @override
  String get settingsUnavailable => 'Unavailable';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutYam => 'About YAM';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAboutDescription =>
      'A fast, local-first nutrition tracker.';
}
