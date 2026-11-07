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
  String get startupDataLoading => 'Opening local data';

  @override
  String get startupDataErrorTitle => 'Could not open local data';

  @override
  String get startupDataErrorMessage => 'Try loading the local database again.';

  @override
  String get updateSection => 'App updates';

  @override
  String get updateCheckAction => 'Check for updates';

  @override
  String get updateSource => 'GitHub · 0x0FACED/yam';

  @override
  String get updateCheckHint => 'Check for a new Android version.';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateUpToDate => 'You have the latest version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String updateDownloading(String percent) {
    return 'Downloading: $percent';
  }

  @override
  String updateReady(String version) {
    return 'Version $version is ready to install';
  }

  @override
  String get updateOpeningInstaller => 'Opening the system installer…';

  @override
  String updateDownloadAction(String size) {
    return 'Download · $size MB';
  }

  @override
  String get updateInstallAction => 'Install update';

  @override
  String get updateInstallHint =>
      'Android will ask you to confirm installation. The APK is removed automatically after a successful update.';

  @override
  String get updateUnavailable =>
      'No public release is available. The repository may still be private or have no published releases.';

  @override
  String get updateNetworkError =>
      'Could not check for updates. Check your internet connection and try again.';

  @override
  String get updateRateLimited =>
      'GitHub\'s request limit has been reached. Try again later.';

  @override
  String get updateInvalidRelease =>
      'The release does not contain a valid Android package and checksum.';

  @override
  String get updateDownloadError =>
      'Could not download or save the update. Check your connection and free space, then try again.';

  @override
  String get updateChecksumError =>
      'The downloaded file is damaged. Download the update again.';

  @override
  String get updatePermissionHint =>
      'Allow YAM to install apps in Android settings, return here, and tap Install update again.';

  @override
  String get updateSignatureError =>
      'This APK uses a different signing key. It cannot update this installation. Export a backup before reinstalling manually.';

  @override
  String get updateInvalidApk =>
      'The APK does not match this app or the expected newer version. Download the update again.';

  @override
  String get updateInstallError =>
      'Could not open the system installer. Try again.';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingGoalTitle => 'What would you like to change?';

  @override
  String get onboardingGoalRequired => 'Choose a goal';

  @override
  String get onboardingSaveFailed => 'Could not save goals and weight';

  @override
  String get onboardingGoalDescription =>
      'This helps set your daily calorie and macro goals';

  @override
  String get onboardingGoalLose => 'Lose weight';

  @override
  String get onboardingGoalLoseDescription => 'For gradual weight loss';

  @override
  String get onboardingGoalMaintain => 'Maintain weight';

  @override
  String get onboardingGoalMaintainDescription => 'To keep your current weight';

  @override
  String get onboardingGoalGain => 'Gain weight';

  @override
  String get onboardingGoalGainDescription => 'For gradual weight gain';

  @override
  String get onboardingWeightTitle => 'Weight';

  @override
  String get onboardingWeightDescription =>
      'Enter your current and target weight';

  @override
  String get onboardingCurrentWeight => 'Current weight';

  @override
  String get onboardingTargetWeight => 'Target weight';

  @override
  String get onboardingWeightDifference => 'Difference to goal';

  @override
  String get onboardingWeightUnchanged => 'Maintain current weight';

  @override
  String get onboardingNutritionTitle => 'Nutrition goals';

  @override
  String get onboardingNutritionDescription =>
      'Set your daily targets for your routine';

  @override
  String get onboardingCalories => 'Daily calories';

  @override
  String get onboardingMacros => 'Macronutrients';

  @override
  String onboardingEnergyFromMacros(String calories) {
    return 'From macros: $calories kcal';
  }

  @override
  String onboardingEnergyAbove(String difference) {
    return '+$difference kcal vs target';
  }

  @override
  String onboardingEnergyBelow(String difference) {
    return '−$difference kcal vs target';
  }

  @override
  String get onboardingEnergyMatches => 'Matches target';

  @override
  String get onboardingEnergyFormulaHint =>
      'Calculation: protein and carbs × 4, fat × 9 kcal/g.';

  @override
  String get onboardingNutritionHint =>
      'You can change these later in Settings.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingClose => 'Close onboarding';

  @override
  String get onboardingInvalidPositive => 'Enter a number greater than zero';

  @override
  String get onboardingInvalidNonNegative => 'Enter a number of zero or more';

  @override
  String get unitKilograms => 'kg';

  @override
  String get navigationDiary => 'Diary';

  @override
  String get navigationStatistics => 'Stats';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get diaryReadErrorTitle => 'Diary could not be loaded';

  @override
  String get diaryReadErrorMessage =>
      'Entries or goals are unavailable. Try loading local diary data again.';

  @override
  String get dayDetailsTitle => 'Day details';

  @override
  String get dayDetailsOpen => 'Open day details';

  @override
  String get dayDetailsByMeal => 'By meal';

  @override
  String get dayDetailsByContribution => 'By contribution';

  @override
  String get dayDetailsCalories => 'Calories';

  @override
  String get dayDetailsDistribution => 'Meal distribution';

  @override
  String get dayDetailsFood => 'Food logged';

  @override
  String get dayDetailsContributionHint =>
      'Share of the logged daily total, not the goal';

  @override
  String dayDetailsShare(String percent) {
    return '$percent of the day';
  }

  @override
  String get dayDetailsNoShare => 'No share: the daily total is zero';

  @override
  String get dayDetailsFacts => 'Day at a glance';

  @override
  String get dayDetailsSoFar => 'So far today';

  @override
  String dayDetailsLargestMeal(String meal, String calories) {
    return 'Most calories — $meal: $calories kcal';
  }

  @override
  String dayDetailsProteinRemaining(String grams) {
    return 'Protein to goal — $grams g';
  }

  @override
  String dayDetailsEstimatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries with estimated values',
      one: '$count entry with estimated values',
    );
    return '$_temp0';
  }

  @override
  String get dayDetailsEmptyTitle => 'No entries for this day';

  @override
  String get dayDetailsEmptyBody =>
      'Log food in the diary to see this day\'s details.';

  @override
  String get actionClose => 'Close';

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
  String get diaryGoalNotSet => 'No goal set yet';

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
  String get diaryEditEntry => 'Edit entry';

  @override
  String get diaryEditSave => 'Save changes';

  @override
  String get diaryEditClose => 'Close editing';

  @override
  String get diaryDeleteEntry => 'Delete entry';

  @override
  String diaryEntryDeleted(String food) {
    return '$food deleted from diary';
  }

  @override
  String diaryEntryUpdated(String food) {
    return '$food updated in diary';
  }

  @override
  String get diarySaveFailed => 'Could not save diary entry';

  @override
  String get diaryDeleteFailed => 'Could not delete diary entry';

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
  String get createProductEditTitle => 'Edit food';

  @override
  String get createProductName => 'Food name';

  @override
  String get createProductNameHint => 'For example, rolled oats';

  @override
  String get createProductBrand => 'Brand';

  @override
  String get createProductBrandHint => 'If applicable';

  @override
  String get createProductCategory => 'Category';

  @override
  String get createProductCategoryHint => 'Enter or choose a category';

  @override
  String get createProductCategoryRequired => 'Enter a category';

  @override
  String get createProductDescription => 'Description (optional)';

  @override
  String get createProductDescriptionHint =>
      'Ingredients, preparation steps, or other notes';

  @override
  String get foodDescription => 'Description';

  @override
  String get createProductNutritionBasis => 'Nutrition values for';

  @override
  String get createProductPerHundredGrams => '100 g';

  @override
  String get createProductPerHundredMilliliters => '100 ml';

  @override
  String get createProductPerServing => '1 serving';

  @override
  String get createProductServingSize => 'Size of this serving';

  @override
  String get createProductNutrition => 'Nutrition facts';

  @override
  String createProductCalculatedCalories(String calories) {
    return 'From macros: $calories kcal';
  }

  @override
  String get createProductServings => 'Additional units';

  @override
  String get createProductAddServing => 'Add a unit';

  @override
  String get createProductServingName => 'Serving name (optional)';

  @override
  String get createProductServingNameHint => 'For example, sandwich';

  @override
  String get createProductServingNameHelper =>
      'Enter just the name; set its weight or volume separately below.';

  @override
  String get createProductServingAmount => 'Amount in one unit';

  @override
  String get createProductRemoveServing => 'Remove unit';

  @override
  String get createProductBarcode => 'Barcode (optional)';

  @override
  String get createProductSave => 'Save food';

  @override
  String get createProductUpdate => 'Save changes';

  @override
  String get createProductSaving => 'Saving…';

  @override
  String get createProductNameRequired => 'Enter a food name';

  @override
  String get createProductInvalidNumber => 'Enter a number of zero or more';

  @override
  String get createProductPositiveAmount => 'Enter an amount greater than zero';

  @override
  String get createProductInvalidBarcode => 'Use digits for the barcode';

  @override
  String get createProductDuplicateBarcode =>
      'A food with this barcode already exists';

  @override
  String get createProductSaveFailed => 'Could not save food';

  @override
  String createProductSaved(String food) {
    return '$food saved';
  }

  @override
  String createProductUpdated(String food) {
    return 'Updated $food';
  }

  @override
  String get createProductMore => 'More';

  @override
  String get createProductEdit => 'Edit';

  @override
  String get createProductDeleteTitle => 'Delete food?';

  @override
  String createProductDeleteMessage(String food) {
    return '$food will disappear from My dishes, search and favorites.';
  }

  @override
  String get createProductDelete => 'Delete';

  @override
  String get createProductDeleteCancel => 'Cancel';

  @override
  String get createProductDeleteAction => 'Delete food';

  @override
  String createProductDeleted(String food) {
    return '$food deleted';
  }

  @override
  String get createProductDeleteFailed => 'Could not delete food';

  @override
  String get createProductUnitServing => 'Serving';

  @override
  String get createProductUnitPiece => 'Piece';

  @override
  String get createProductUnitGlass => 'Glass';

  @override
  String get createProductUnitScoop => 'Scoop';

  @override
  String get createProductBack => 'Back to food search';

  @override
  String get createProductStubMessage =>
      'Product creation will be implemented in a later slice.';

  @override
  String get foodSearchRecent => 'Recent';

  @override
  String get foodSearchMyDishes => 'My dishes';

  @override
  String get foodSearchFavorites => 'Favorites';

  @override
  String get foodSearchResults => 'Search results';

  @override
  String get foodSearchOpenFoodFacts => 'Open Food Facts';

  @override
  String get foodSearchRemoteLoading => 'Searching Open Food Facts';

  @override
  String get foodSearchRemoteShortQuery =>
      'Enter at least 3 characters to search Open Food Facts.';

  @override
  String get foodSearchRemoteEmpty =>
      'No addable products found on Open Food Facts.';

  @override
  String get foodSearchRemoteError =>
      'Open Food Facts is unavailable. Your local foods are still here.';

  @override
  String get foodSearchRemoteAttribution => 'Data: Open Food Facts';

  @override
  String get foodSearchRemoteLicense => 'ODbL license';

  @override
  String get foodSearchRemoteLinkError => 'Could not open the link.';

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
  String foodSearchCaloriesPerReference(String calories, String quantity) {
    return '$calories kcal / $quantity';
  }

  @override
  String get foodCategoryGrains => 'Grains';

  @override
  String get foodCategoryOther => 'Other';

  @override
  String get foodCategoryDairy => 'Dairy';

  @override
  String get foodCategorySportsNutrition => 'Sports nutrition';

  @override
  String get foodCategoryFruit => 'Fruit';

  @override
  String get foodCategoryPoultry => 'Meat & poultry';

  @override
  String get foodCategoryEggs => 'Eggs';

  @override
  String get foodCategoryBread => 'Bread';

  @override
  String get foodCategoryDrinks => 'Drinks';

  @override
  String get quickAddTitle => 'Add to diary';

  @override
  String get quickAddQuantity => 'Quantity';

  @override
  String get quickAddUnit => 'Unit';

  @override
  String quickAddUnitEquivalent(String unit, String quantity) {
    return '$unit = $quantity';
  }

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
  String quickAddAddToMeal(String meal) {
    return 'Add to $meal';
  }

  @override
  String get quickAddFavoriteAdd => 'Add to favorites';

  @override
  String get quickAddFavoriteRemove => 'Remove from favorites';

  @override
  String foodFavoriteAdded(String food) {
    return '$food added to favorites';
  }

  @override
  String foodFavoriteRemoved(String food) {
    return '$food removed from favorites';
  }

  @override
  String get foodFavoriteSaveFailed => 'Could not update favorites';

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
  String get statsPeriod7 => '7D';

  @override
  String get statsPeriod30 => '30D';

  @override
  String get statsPeriod90 => '3M';

  @override
  String get statsPeriod365 => '1Y';

  @override
  String get statsPeriodAll => 'All';

  @override
  String get statsNoData => 'No entries yet';

  @override
  String get statsLoading => 'Loading statistics';

  @override
  String get statsReadErrorTitle => 'Statistics could not be loaded';

  @override
  String get statsReadErrorMessage =>
      'Some local data is unavailable. Try loading your statistics again.';

  @override
  String statsCurrentGoal(String value) {
    return 'Current goal: $value';
  }

  @override
  String get statsGoalLegend => 'Goal';

  @override
  String statsAverageGoal(String value) {
    return 'Average goal: $value';
  }

  @override
  String statsGoalDifference(String value) {
    return 'Difference from goal: $value';
  }

  @override
  String statsNutritionDetails(String protein, String fat, String carbs) {
    return 'P $protein g · F $fat g · C $carbs g';
  }

  @override
  String statsGoalDaysSummary(String within, String total, String percent) {
    return 'In goal: $within of $total days ($percent%)';
  }

  @override
  String get statsWeight => 'Weight';

  @override
  String get statsAverageCalories => 'Average calories';

  @override
  String get statsAverageProtein => 'Average protein';

  @override
  String get statsDaysInGoal => 'Days in goal';

  @override
  String get statsWeightChart => 'Body weight';

  @override
  String get statsCaloriesChart => 'Calories';

  @override
  String get statsAverageMacros => 'Average macros';

  @override
  String get statsRegularity => 'Regularity';

  @override
  String get statsFrequentFoods => 'Often eaten';

  @override
  String statsGoal(String value) {
    return 'Goal: $value';
  }

  @override
  String get statsDailyAverage => 'kcal/day';

  @override
  String get statsGramsPerDay => 'g/day';

  @override
  String statsPercentOfGoal(String percent) {
    return '$percent% of goal';
  }

  @override
  String statsInGoalCount(String within, String total) {
    return '$within / $total';
  }

  @override
  String statsLoggedDays(String days) {
    return 'Days with food: $days';
  }

  @override
  String statsDaysWithFood(String days) {
    return 'Days: $days';
  }

  @override
  String get statsNoWeight => 'No weight measurements yet';

  @override
  String get statsNoWeightInPeriod => 'No weight measurements in this period';

  @override
  String get statsNoWeightHint => 'Log your weight to see its changes.';

  @override
  String get statsNoNutrition => 'No food entries in this period';

  @override
  String get statsNoGoal => 'No goal set';

  @override
  String get statsNoGoalDays => 'Set a goal to track regularity.';

  @override
  String get statsNoFrequent => 'Foods from your diary will appear here.';

  @override
  String get statsAddWeight => 'Log weight';

  @override
  String get statsEditWeight => 'Edit weight entry';

  @override
  String get statsWeightDate => 'Measurement date';

  @override
  String get statsSaveWeight => 'Save weight';

  @override
  String get statsWeightClose => 'Close weight entry';

  @override
  String get statsDeleteWeight => 'Delete weight entry';

  @override
  String get statsInvalidWeight => 'Enter a weight greater than zero';

  @override
  String get statsWeightSaved => 'Weight saved';

  @override
  String get statsWeightDeleted => 'Weight entry deleted';

  @override
  String get statsWeightFailed => 'Could not change weight';

  @override
  String get statsGoalWithin => 'In goal';

  @override
  String get statsGoalBelow => 'Below';

  @override
  String get statsGoalAbove => 'Above';

  @override
  String get statsNoEntry => 'No entry';

  @override
  String statsWeightChange(String change) {
    return '$change kg in this period';
  }

  @override
  String statsWeightLastDate(String date) {
    return 'Last: $date';
  }

  @override
  String statsWindow(String start, String end) {
    return 'Shown: $start – $end';
  }

  @override
  String statsAveragePortion(String amount, String unit) {
    return '~$amount $unit';
  }

  @override
  String statsPercentOfTrackedDays(String percent) {
    return '$percent% of logged days';
  }

  @override
  String get statsBucketAverage => 'Average on logged days';

  @override
  String get statisticsPrototypeMessage =>
      'Nutrition and weight trends will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGoalsSection => 'Goals';

  @override
  String get settingsOpenOnboarding => 'Go through onboarding';

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
  String get settingsGoalsNotSet => 'No goals set';

  @override
  String get settingsWeightNotSet => 'No weight recorded yet';

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
  String get settingsImportData => 'Import data';

  @override
  String get foodLibrarySection => 'Food library';

  @override
  String get foodLibraryExport => 'Export foods';

  @override
  String get foodLibraryExportHint => 'Only My dishes, as editable JSON';

  @override
  String get foodLibraryImport => 'Import foods';

  @override
  String get foodLibraryImportHint => 'Replace or merge a library from JSON';

  @override
  String get foodLibrarySaveDialog => 'Save YAM food library';

  @override
  String get foodLibraryOpenDialog => 'Open food library JSON';

  @override
  String get foodLibraryExportSuccess => 'Food library saved.';

  @override
  String get foodLibraryExportFailed => 'Could not save the food library.';

  @override
  String get foodLibraryImportFailed =>
      'Could not import foods. No data was changed.';

  @override
  String get foodLibraryInvalidFile =>
      'Invalid food file. Expected yam-foods JSON. No data was changed.';

  @override
  String foodLibraryInvalidField(String path) {
    return 'Invalid or missing field: $path. No data was changed.';
  }

  @override
  String get foodLibraryUnsupportedVersion =>
      'This food format version is not supported. Try a newer version of YAM.';

  @override
  String get foodLibraryTooLarge =>
      'Limit exceeded: 64 MiB, 50,000 foods or 250,000 servings.';

  @override
  String get foodLibraryPreviewTitle => 'Import foods';

  @override
  String foodLibraryPreviewCounts(String foods, String servings) {
    return 'Foods: $foods. Servings: $servings.';
  }

  @override
  String get foodLibraryScopeNote =>
      'Added foods will appear in My dishes. Your diary, weights, goals, built-in catalog and saved Open Food Facts foods will not change.';

  @override
  String get foodLibraryDeduplicate => 'Merge without duplicates';

  @override
  String get foodLibraryDeduplicateDescription =>
      'Skip matching names, brands, units, basis amounts and nutrition, including repeats within the file. Name and brand matching ignores case and extra whitespace. Existing foods stay unchanged.';

  @override
  String get foodLibraryMergeAll => 'Merge keeping duplicates';

  @override
  String get foodLibraryMergeAllDescription =>
      'Add every record as a new food, even if the same food or barcode already exists.';

  @override
  String get foodLibraryReplace => 'Replace food library…';

  @override
  String get foodLibraryReplaceDescription =>
      'Remove current My dishes and load every food from the file, keeping repeats. Requires another confirmation.';

  @override
  String get foodLibraryReplaceTitle => 'Replace My dishes?';

  @override
  String get foodLibraryReplaceWarning =>
      'All current foods and their servings in My dishes will be removed and replaced with this file. This cannot be undone. An empty list clears My dishes. Diary history, weights, goals and other catalogs stay unchanged.';

  @override
  String get foodLibraryReplaceConfirm => 'Replace My dishes';

  @override
  String get foodLibraryImportComplete => 'Foods imported';

  @override
  String foodLibraryImportResult(
    String imported,
    String skipped,
    String replaced,
  ) {
    return 'Added: $imported. Duplicates skipped: $skipped. Previous foods removed: $replaced.';
  }

  @override
  String get foodLibraryResultNote =>
      'Added foods are editable and available for diary logging in My dishes.';

  @override
  String get foodLibraryWorking =>
      'Food transfer: preparing a file or waiting for confirmation…';

  @override
  String get foodLibraryFormatTitle => 'File format and example';

  @override
  String get foodLibraryFormatDescription =>
      'A plain UTF-8 .json file, editable by hand or generated with AI. Nutrition is per basisAmount grams (g) or milliliters (ml). Use numbers without quotes and a decimal point. Calories are imported as written, not recalculated from macros.';

  @override
  String get foodLibraryOptionalFields =>
      'Optional fields: brand, barcode (a string of digits), description; servings with unit (serving/piece/glass/scoop), baseAmount in g/ml, defaultAmount (1 if omitted) and label. displayBasis: per100 (basis 100) or perServing; if omitted, basis 100 displays per 100 g/ml, otherwise per serving. A missing per-serving equivalent is created automatically.';

  @override
  String get foodLibraryCopyExample => 'Copy JSON example';

  @override
  String get foodLibraryExampleName => 'Cottage cheese 5%';

  @override
  String get foodLibraryExampleCategory => 'Dairy';

  @override
  String get backupSaveDialogTitle => 'Save YAM backup';

  @override
  String get backupOpenDialogTitle => 'Open YAM backup';

  @override
  String get backupExportSuccess => 'Backup saved.';

  @override
  String get backupExportFailed =>
      'Could not save the backup. Please try again.';

  @override
  String get backupExportInvalidData =>
      'Could not prepare the saved data for export. Your data has not been changed.';

  @override
  String get backupImportFailed =>
      'Could not import the backup. No data was changed.';

  @override
  String get backupInvalidFile =>
      'This is not a valid YAM backup. No data was imported.';

  @override
  String get backupUnsupportedVersion =>
      'This backup version is not supported. Try a newer version of YAM.';

  @override
  String get backupTooLarge => 'This backup exceeds the supported size limit.';

  @override
  String get backupPersonalDataNote =>
      'The .yam file contains your diary, weights, goals, food data and saved AI chat text, including deleted-record metadata. Photos, drafts and credentials are not included. It is not encrypted. Store it privately. The app theme is not included.';

  @override
  String get backupReplaceTitle => 'Replace local data?';

  @override
  String get backupReplaceWarning =>
      'All local foods, servings, diary entries, goals, weight records, cached foods and saved AI chats will be removed and replaced with this backup. This cannot be undone. An empty backup clears these records. Older backups without chats also clear local chats. If the backup has no goals, you will need to go through onboarding again.';

  @override
  String get backupReplaceConfirm => 'Replace all data';

  @override
  String get backupSaveAction => 'Choose where to save';

  @override
  String get backupCancel => 'Cancel';

  @override
  String get backupClose => 'Close';

  @override
  String get backupDone => 'Done';

  @override
  String get backupPreviewTitle => 'Import backup';

  @override
  String backupExportedAt(String date) {
    return 'Created: $date';
  }

  @override
  String get backupCountsNote =>
      'Counts include deleted records. Nothing changes until you confirm an import below.';

  @override
  String get backupSupplementDescription =>
      'Keep all current records, including deletions, unchanged. Add only missing records. Existing IDs, barcode conflicts and cached-food conflicts are skipped. Servings are added only with newly added foods.';

  @override
  String get backupSupplementAction => 'Supplement local data';

  @override
  String get backupReplaceDescription =>
      'Remove all current records listed above and load this backup instead. Requires another confirmation.';

  @override
  String get backupReplaceAction => 'Replace local data…';

  @override
  String get backupImportComplete => 'Backup imported';

  @override
  String backupImportResult(String imported, String skipped) {
    return 'Imported: $imported. Skipped: $skipped.';
  }

  @override
  String get backupImportedRecords => 'Imported records';

  @override
  String get backupSkippedRecords => 'Skipped records';

  @override
  String get backupSkippedNote =>
      'Existing records, barcode conflicts, cached-food conflicts and servings of skipped foods were not imported. Your current records were kept unchanged.';

  @override
  String get backupWaitingForConfirmation => 'Waiting for your confirmation';

  @override
  String get backupExporting => 'Preparing backup…';

  @override
  String get backupSaving => 'Saving backup…';

  @override
  String get backupOpening => 'Opening backup…';

  @override
  String get backupInspecting => 'Checking backup…';

  @override
  String get backupImporting => 'Importing backup…';

  @override
  String get backupCountUserFoods => 'Your foods';

  @override
  String get backupCountUserServings => 'Food servings';

  @override
  String get backupCountDiaryEntries => 'Diary entries';

  @override
  String get backupCountGoals => 'Goal versions';

  @override
  String get backupCountWeights => 'Weight records';

  @override
  String get backupCountRemoteFoods => 'Cached foods';

  @override
  String get backupCountAssistantConversations => 'AI chats';

  @override
  String get backupRestoreAction => 'Restore from backup';

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
  String get assistantTitle => 'YAM';

  @override
  String get assistantSettings => 'AI connection';

  @override
  String get assistantSettingsSubtitle => 'ChatGPT or your own OpenAI API key';

  @override
  String get assistantPrivacy =>
      'The provider receives the messages you send, attached photos, and only requested YAM data. Saved chats are not sent automatically; when reopening a chat, sending its saved text requires turning on history context. Your full database is not sent in advance. The regular diary works without AI or a network.';

  @override
  String get assistantSessionNote =>
      'Chat text is saved on this device and included in .yam backups. Photos, unfinished input and unsaved drafts are not saved. Reopened chats are for viewing until you send a message; sending their saved text as context is off by default.';

  @override
  String get assistantHistory => 'Chat history';

  @override
  String get assistantHistoryEmpty => 'No saved chats yet';

  @override
  String get assistantHistoryEmptyNote =>
      'Your conversations will appear here after you send a message. Saved chat text is available offline.';

  @override
  String get assistantHistoryPhotoTitle => 'Photo conversation';

  @override
  String get assistantPhotoNotStored => 'Photo not saved';

  @override
  String get assistantUseHistory => 'Saved chat context';

  @override
  String get assistantUseHistoryNote =>
      'Up to 12 messages / 12,000 characters. On for this chat.';

  @override
  String get assistantHistoryOffNote => 'Saved messages are not sent.';

  @override
  String get assistantHistoryStorageError =>
      'Could not load or save local chat history. Try again. Saved messages are not sent automatically.';

  @override
  String get assistantHistoryLoading => 'Loading saved chats…';

  @override
  String get assistantHistoryLoadError => 'Could not load chats';

  @override
  String get assistantHistoryRetry => 'Try again';

  @override
  String assistantHistoryUpdatedAt(String date, String time) {
    return '$date, $time';
  }

  @override
  String get assistantHistoryDeleteTitle => 'Delete conversation?';

  @override
  String assistantHistoryDeleteMessage(String title) {
    return '“$title” will be removed from saved chats. Its text will be erased from local history. Diary entries will not change. This cannot be undone.';
  }

  @override
  String get assistantHistoryDelete => 'Delete';

  @override
  String assistantHistoryDeleteAction(String title) {
    return 'Delete conversation: $title';
  }

  @override
  String get assistantHistoryDeleting => 'Deleting conversation…';

  @override
  String get assistantHistoryDeleteError =>
      'Could not delete the conversation. Try deleting it again.';

  @override
  String get assistantPrompt => 'What did you eat?';

  @override
  String get assistantPromptHint => 'E.g. 200 g cottage cheese';

  @override
  String get assistantSend => 'Send';

  @override
  String get assistantStop => 'Stop';

  @override
  String get assistantRetry => 'Retry request';

  @override
  String get assistantThinking => 'Preparing a response…';

  @override
  String get assistantPhoto => 'Choose a photo';

  @override
  String get assistantCamera => 'Take a photo';

  @override
  String get assistantRemovePhoto => 'Remove photo';

  @override
  String get assistantPhotoAttached => 'Photo attached';

  @override
  String get assistantVoice => 'Dictate';

  @override
  String get assistantVoiceStop => 'Finish dictation';

  @override
  String get assistantListening =>
      'Speak, then stop dictation and review the text.';

  @override
  String get assistantApiKey => 'Own API key';

  @override
  String get assistantApiKeyLabel => 'OpenAI API key';

  @override
  String get assistantApiKeyNote =>
      'API-key requests are billed separately by OpenAI. The key is stored securely on this device and excluded from backups. A saved key also transcribes voice when system recognition is unavailable.';

  @override
  String get assistantSaveKey => 'Connect API key';

  @override
  String get assistantChatGpt => 'ChatGPT plan';

  @override
  String get assistantChatGptContinue => 'Continue with ChatGPT';

  @override
  String get assistantOAuthReturn => 'Return to YAM to continue connecting.';

  @override
  String get assistantChatGptAccount => 'ChatGPT account';

  @override
  String get assistantAddChatGptAccount => 'Add another account';

  @override
  String get assistantPlanNote =>
      'For eligible ChatGPT plans. Uses your shared plan limit; voice recognition is separate. Sign-in opens in your system browser.';

  @override
  String get assistantPlanWelcomeTitle => 'You are using your ChatGPT plan';

  @override
  String get assistantPlanWelcome =>
      'Eligible YAM AI requests will use your ChatGPT plan allowance. You can manage app access and limits in ChatGPT settings.';

  @override
  String get assistantManageUsage => 'Manage ChatGPT usage';

  @override
  String get assistantDisconnect => 'Disconnect selected connection';

  @override
  String get assistantConnected => 'Connected';

  @override
  String get assistantNotConnected => 'Choose a connection to start';

  @override
  String get assistantModel => 'Model';

  @override
  String get assistantRefreshModels => 'Refresh models';

  @override
  String get assistantConnectionMode => 'Use';

  @override
  String get assistantDraftTitle => 'Review before saving';

  @override
  String get assistantDraftNote =>
      'Check the food, quantity, date, and meal. This is a draft; nothing has been saved.';

  @override
  String get assistantDate => 'Date';

  @override
  String get assistantMeal => 'Meal';

  @override
  String get assistantAmount => 'Quantity';

  @override
  String get assistantUnit => 'Unit';

  @override
  String get assistantEstimatedLabel => 'AI estimate';

  @override
  String get assistantEstimateNote =>
      'A photo estimate is not a measurement. Check ingredients, added oil, and portion size.';

  @override
  String get assistantSaveToCatalog => 'Save new food to My dishes';

  @override
  String get assistantAddToDiary => 'Add to diary';

  @override
  String get assistantSaveProducts => 'Save foods';

  @override
  String get assistantRemoveItem => 'Remove from draft';

  @override
  String get assistantEditProduct => 'Edit food details';

  @override
  String get assistantDiscard => 'Discard draft';

  @override
  String get assistantSaved => 'The confirmed batch has been saved';

  @override
  String get assistantDraftDiscarded => 'Draft discarded. Nothing was saved.';

  @override
  String get assistantCloseTitle => 'Close assistant?';

  @override
  String get assistantCloseNote =>
      'The current request will stop. Chat text stays in local history. Attached photos, unfinished input and the unsaved draft will be discarded. Saved entries remain in the diary.';

  @override
  String get assistantCloseConfirm => 'Close';

  @override
  String get assistantKeepEditing => 'Keep editing';

  @override
  String get assistantClearTitle => 'Start a new conversation?';

  @override
  String get assistantClear => 'New conversation';

  @override
  String get assistantSwitchNote =>
      'The current request will stop, and changing the connection starts a new conversation. Chat text stays in local history; attached photos, unfinished input and the unsaved draft will be discarded.';

  @override
  String get assistantInvalidDraft =>
      'Check the draft fields: quantities must be greater than zero and food details must be complete.';

  @override
  String get assistantErrorNetwork =>
      'Cannot reach the provider. Check your connection and retry. The manual diary is available.';

  @override
  String get assistantErrorAuth =>
      'The connection is invalid or access was denied. Reconnect your key or sign in again.';

  @override
  String get assistantErrorLimit =>
      'The request limit has been reached. Check your connection limits and try again later.';

  @override
  String get assistantErrorModels =>
      'No available models could be loaded. Refresh the list or check your connection.';

  @override
  String get assistantErrorInterrupted =>
      'The response did not complete. Nothing was saved; you can retry.';

  @override
  String get assistantErrorCancelled => 'Request stopped. Nothing was saved.';

  @override
  String get assistantErrorStorage =>
      'Secure storage is unavailable. Check the system keyring; secrets have not been stored in ordinary files.';

  @override
  String get assistantErrorRevocation =>
      'The local connection was removed, but remote revocation was not confirmed. Disconnect YAM in ChatGPT settings.';

  @override
  String get assistantErrorSpeechPermission =>
      'Microphone or speech recognition access was denied. Check system permissions.';

  @override
  String get assistantErrorSpeechKey =>
      'Voice recognition on this platform requires your own API key. Add it in AI settings or type your message.';

  @override
  String get assistantErrorSpeech =>
      'Could not recognize speech. Check your microphone and system support, or type your message.';

  @override
  String get assistantErrorImage =>
      'Choose a JPEG, PNG, or WebP photo up to 10 MB. If the file is already smaller, reduce its resolution.';

  @override
  String get assistantErrorMedia =>
      'Could not open the photo or microphone. Check permissions and retry.';

  @override
  String get assistantErrorSave =>
      'Could not save the batch. Nothing was added; check the draft and retry.';

  @override
  String get assistantErrorGeneric =>
      'The request failed. Your input and draft remain on this screen; try again.';

  @override
  String get proxySettingsTitle => 'Proxy';

  @override
  String get proxySettingsSubtitle => 'HTTP, HTTPS or SOCKS5 for app requests';

  @override
  String get proxyScopeNote =>
      'Applies to HTTP requests made by YAM. Browser sign-in and system speech recognition still use the operating system’s network settings. The local diary works without a network.';

  @override
  String get proxyLoading => 'Loading saved proxy settings…';

  @override
  String get proxyRouting => 'Connection';

  @override
  String get proxyDisabled => 'Off — direct connection';

  @override
  String get proxyEnabled => 'On — use proxy';

  @override
  String get proxyDisabledHelp =>
      'Save to use direct connections. No network connection is needed to turn the proxy off.';

  @override
  String get proxyEnabledHelp =>
      'If the proxy is unavailable, requests fail instead of connecting directly.';

  @override
  String get proxyProtocol => 'Proxy protocol';

  @override
  String get proxyProtocolHttp => 'HTTP';

  @override
  String get proxyProtocolHttps => 'HTTPS';

  @override
  String get proxyProtocolSocks5 => 'SOCKS5';

  @override
  String get proxyProtocolHelp =>
      'HTTP also supports HTTPS sites. HTTP and SOCKS5 do not encrypt the connection to the proxy, including proxy credentials; HTTPS encrypts this hop. HTTPS sites keep their own TLS protection.';

  @override
  String get proxyHost => 'Host';

  @override
  String get proxyHostHint => 'Hostname or IP address, without a URL scheme';

  @override
  String get proxyPort => 'Port';

  @override
  String get proxyAuthentication => 'Authentication (optional)';

  @override
  String get proxyAuthenticationHelp =>
      'Leave both fields blank if the proxy does not require authentication. Password spaces are preserved.';

  @override
  String get proxyUsername => 'Username';

  @override
  String get proxyPassword => 'Password';

  @override
  String get proxyStorageNote =>
      'Settings and credentials are kept in secure storage on this device and excluded from diary backups.';

  @override
  String get proxyApplyNote =>
      'Saving applies the settings immediately and closes existing connections. Requests in progress may need to be retried.';

  @override
  String get proxyErrorHost =>
      'Enter a valid hostname or IP address without a URL scheme, path or port.';

  @override
  String get proxyErrorPort => 'Enter a port number from 1 to 65535.';

  @override
  String get proxyErrorCredentials =>
      'Check the username and password: this proxy protocol cannot use these credentials.';

  @override
  String get proxyErrorStorage =>
      'Could not load or save proxy settings securely. Check the system keyring and try saving again. Active routing has not changed; the local diary remains available.';

  @override
  String get proxySave => 'Save settings';

  @override
  String get proxySaving => 'Saving settings…';

  @override
  String get proxySaved => 'Proxy settings saved.';

  @override
  String get settingsAboutDescription =>
      'A fast, local-first nutrition tracker.';
}
