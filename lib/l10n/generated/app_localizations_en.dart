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
  String get macroProtein => 'Protein';

  @override
  String get macroFat => 'Fat';

  @override
  String get macroCarbs => 'Carbs';

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
  String get foodSearchHint => 'Search foods';

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
  String get foodSearchCreateFoodPlaceholder =>
      'Custom food creation will be available in the functional version.';

  @override
  String get foodSearchFrequent => 'Frequently added';

  @override
  String get foodSearchRecent => 'Recent';

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
  String foodSearchMacrosSummary(String protein, String fat, String carbs) {
    return 'P $protein · F $fat · C $carbs';
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
  String foodAdded(String food, String meal) {
    return '$food added to $meal';
  }

  @override
  String get actionUndo => 'Undo';

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
  String get demoEggs => 'Eggs';

  @override
  String get demoBread => 'Bread';

  @override
  String get demoMilk => 'Milk 2.5%';

  @override
  String get demoChickenBreast => 'Chicken breast';

  @override
  String get demoRice => 'Rice';

  @override
  String get demoCottageCheese => 'Cottage cheese';

  @override
  String get demoBanana => 'Banana';

  @override
  String get demoYogurt => 'Greek yogurt';

  @override
  String get demoProtein => 'Protein powder';

  @override
  String get demoApple => 'Apple';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsPrototypeMessage =>
      'Nutrition and weight trends will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrototypeMessage =>
      'Goals, units and appearance will be configured here.';
}
