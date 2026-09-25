import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'YAM'**
  String get appName;

  /// Screen reader label for the animated startup screen
  ///
  /// In en, this message translates to:
  /// **'YAM is starting'**
  String get startupLoadingLabel;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStepOf(int step, int total);

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to change?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'This helps set your daily calorie and macro goals'**
  String get onboardingGoalDescription;

  /// No description provided for @onboardingGoalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get onboardingGoalLose;

  /// No description provided for @onboardingGoalLoseDescription.
  ///
  /// In en, this message translates to:
  /// **'For gradual weight loss'**
  String get onboardingGoalLoseDescription;

  /// No description provided for @onboardingGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get onboardingGoalMaintain;

  /// No description provided for @onboardingGoalMaintainDescription.
  ///
  /// In en, this message translates to:
  /// **'To keep your current weight'**
  String get onboardingGoalMaintainDescription;

  /// No description provided for @onboardingGoalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get onboardingGoalGain;

  /// No description provided for @onboardingGoalGainDescription.
  ///
  /// In en, this message translates to:
  /// **'For gradual weight gain'**
  String get onboardingGoalGainDescription;

  /// No description provided for @onboardingWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get onboardingWeightTitle;

  /// No description provided for @onboardingWeightDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current and target weight'**
  String get onboardingWeightDescription;

  /// No description provided for @onboardingCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get onboardingCurrentWeight;

  /// No description provided for @onboardingTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get onboardingTargetWeight;

  /// No description provided for @onboardingWeightDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference to goal'**
  String get onboardingWeightDifference;

  /// No description provided for @onboardingWeightUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Maintain current weight'**
  String get onboardingWeightUnchanged;

  /// No description provided for @onboardingNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition goals'**
  String get onboardingNutritionTitle;

  /// No description provided for @onboardingNutritionDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your daily targets for your routine'**
  String get onboardingNutritionDescription;

  /// No description provided for @onboardingCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get onboardingCalories;

  /// No description provided for @onboardingMacros.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get onboardingMacros;

  /// No description provided for @onboardingEnergyFromMacros.
  ///
  /// In en, this message translates to:
  /// **'From macros: {calories} kcal'**
  String onboardingEnergyFromMacros(String calories);

  /// No description provided for @onboardingEnergyAbove.
  ///
  /// In en, this message translates to:
  /// **'+{difference} kcal vs target'**
  String onboardingEnergyAbove(String difference);

  /// No description provided for @onboardingEnergyBelow.
  ///
  /// In en, this message translates to:
  /// **'−{difference} kcal vs target'**
  String onboardingEnergyBelow(String difference);

  /// No description provided for @onboardingEnergyMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches target'**
  String get onboardingEnergyMatches;

  /// No description provided for @onboardingEnergyFormulaHint.
  ///
  /// In en, this message translates to:
  /// **'Calculation: protein and carbs × 4, fat × 9 kcal/g.'**
  String get onboardingEnergyFormulaHint;

  /// No description provided for @onboardingNutritionHint.
  ///
  /// In en, this message translates to:
  /// **'You can change these later in Settings.'**
  String get onboardingNutritionHint;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingClose.
  ///
  /// In en, this message translates to:
  /// **'Close onboarding'**
  String get onboardingClose;

  /// No description provided for @onboardingInvalidPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than zero'**
  String get onboardingInvalidPositive;

  /// No description provided for @onboardingInvalidNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of zero or more'**
  String get onboardingInvalidNonNegative;

  /// No description provided for @unitKilograms.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilograms;

  /// No description provided for @navigationDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get navigationDiary;

  /// No description provided for @navigationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navigationStatistics;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryTitle;

  /// No description provided for @diaryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get diaryToday;

  /// No description provided for @diaryPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get diaryPreviousDay;

  /// No description provided for @diaryNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get diaryNextDay;

  /// No description provided for @diaryOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get diaryOpenCalendar;

  /// No description provided for @diaryReturnToToday.
  ///
  /// In en, this message translates to:
  /// **'Return to today'**
  String get diaryReturnToToday;

  /// No description provided for @diaryConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get diaryConsumed;

  /// No description provided for @diaryCalorieGoalSuffix.
  ///
  /// In en, this message translates to:
  /// **'/ {target} kcal'**
  String diaryCalorieGoalSuffix(String target);

  /// No description provided for @diaryCaloriesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} kcal left'**
  String diaryCaloriesRemaining(String remaining);

  /// No description provided for @diaryCaloriesOverTarget.
  ///
  /// In en, this message translates to:
  /// **'{excess} kcal over'**
  String diaryCaloriesOverTarget(String excess);

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// No description provided for @macroProteinShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get macroProteinShort;

  /// No description provided for @macroFatShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get macroFatShort;

  /// No description provided for @macroCarbsShort.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get macroCarbsShort;

  /// No description provided for @macroGramsProgress.
  ///
  /// In en, this message translates to:
  /// **'{consumed} / {target} g'**
  String macroGramsProgress(String consumed, String target);

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get mealSnacks;

  /// No description provided for @mealCalories.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String mealCalories(String calories);

  /// No description provided for @diaryAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get diaryAddFood;

  /// No description provided for @diaryAddFoodToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add food to {meal}'**
  String diaryAddFoodToMeal(String meal);

  /// No description provided for @diaryAddFoodPrototypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Food search will open here in the next prototype.'**
  String get diaryAddFoodPrototypeMessage;

  /// No description provided for @diaryNoFoods.
  ///
  /// In en, this message translates to:
  /// **'No foods yet'**
  String get diaryNoFoods;

  /// No description provided for @diaryEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get diaryEditEntry;

  /// No description provided for @diaryEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get diaryEditSave;

  /// No description provided for @diaryEditClose.
  ///
  /// In en, this message translates to:
  /// **'Close editing'**
  String get diaryEditClose;

  /// No description provided for @diaryDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get diaryDeleteEntry;

  /// No description provided for @diaryEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'{food} deleted from diary'**
  String diaryEntryDeleted(String food);

  /// No description provided for @diaryEntryUpdated.
  ///
  /// In en, this message translates to:
  /// **'{food} updated in diary'**
  String diaryEntryUpdated(String food);

  /// No description provided for @diarySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save diary entry'**
  String get diarySaveFailed;

  /// No description provided for @diaryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete diary entry'**
  String get diaryDeleteFailed;

  /// No description provided for @foodSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get foodSearchTitle;

  /// No description provided for @foodSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods or dishes'**
  String get foodSearchHint;

  /// No description provided for @foodSearchBack.
  ///
  /// In en, this message translates to:
  /// **'Back to diary'**
  String get foodSearchBack;

  /// No description provided for @foodSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get foodSearchClear;

  /// No description provided for @foodSearchChooseMeal.
  ///
  /// In en, this message translates to:
  /// **'Choose meal'**
  String get foodSearchChooseMeal;

  /// No description provided for @foodSearchSelectedMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal: {meal}'**
  String foodSearchSelectedMeal(String meal);

  /// No description provided for @foodSearchSelectMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should this food go?'**
  String get foodSearchSelectMealTitle;

  /// No description provided for @foodSearchMealRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a meal first'**
  String get foodSearchMealRequired;

  /// No description provided for @foodSearchCreateFood.
  ///
  /// In en, this message translates to:
  /// **'Create food'**
  String get foodSearchCreateFood;

  /// No description provided for @createProductName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get createProductName;

  /// No description provided for @createProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, rolled oats'**
  String get createProductNameHint;

  /// No description provided for @createProductBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get createProductBrand;

  /// No description provided for @createProductBrandHint.
  ///
  /// In en, this message translates to:
  /// **'If applicable'**
  String get createProductBrandHint;

  /// No description provided for @createProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get createProductCategory;

  /// No description provided for @createProductNutritionBasis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values for'**
  String get createProductNutritionBasis;

  /// No description provided for @createProductPerHundredGrams.
  ///
  /// In en, this message translates to:
  /// **'100 g'**
  String get createProductPerHundredGrams;

  /// No description provided for @createProductPerHundredMilliliters.
  ///
  /// In en, this message translates to:
  /// **'100 ml'**
  String get createProductPerHundredMilliliters;

  /// No description provided for @createProductPerServing.
  ///
  /// In en, this message translates to:
  /// **'1 serving'**
  String get createProductPerServing;

  /// No description provided for @createProductServingSize.
  ///
  /// In en, this message translates to:
  /// **'Size of this serving'**
  String get createProductServingSize;

  /// No description provided for @createProductNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts'**
  String get createProductNutrition;

  /// No description provided for @createProductCalculatedCalories.
  ///
  /// In en, this message translates to:
  /// **'From macros: {calories} kcal'**
  String createProductCalculatedCalories(String calories);

  /// No description provided for @createProductServings.
  ///
  /// In en, this message translates to:
  /// **'Additional units'**
  String get createProductServings;

  /// No description provided for @createProductAddServing.
  ///
  /// In en, this message translates to:
  /// **'Add a unit'**
  String get createProductAddServing;

  /// No description provided for @createProductServingName.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get createProductServingName;

  /// No description provided for @createProductServingNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, bottle'**
  String get createProductServingNameHint;

  /// No description provided for @createProductServingAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount in one unit'**
  String get createProductServingAmount;

  /// No description provided for @createProductRemoveServing.
  ///
  /// In en, this message translates to:
  /// **'Remove unit'**
  String get createProductRemoveServing;

  /// No description provided for @createProductBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get createProductBarcode;

  /// No description provided for @createProductSave.
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get createProductSave;

  /// No description provided for @createProductSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get createProductSaving;

  /// No description provided for @createProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a food name'**
  String get createProductNameRequired;

  /// No description provided for @createProductInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of zero or more'**
  String get createProductInvalidNumber;

  /// No description provided for @createProductPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get createProductPositiveAmount;

  /// No description provided for @createProductInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Use digits for the barcode'**
  String get createProductInvalidBarcode;

  /// No description provided for @createProductDuplicateBarcode.
  ///
  /// In en, this message translates to:
  /// **'A food with this barcode already exists'**
  String get createProductDuplicateBarcode;

  /// No description provided for @createProductSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save food'**
  String get createProductSaveFailed;

  /// No description provided for @createProductSaved.
  ///
  /// In en, this message translates to:
  /// **'{food} saved'**
  String createProductSaved(String food);

  /// No description provided for @createProductDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete food?'**
  String get createProductDeleteTitle;

  /// No description provided for @createProductDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{food} will disappear from My dishes, search and favorites.'**
  String createProductDeleteMessage(String food);

  /// No description provided for @createProductDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get createProductDelete;

  /// No description provided for @createProductDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createProductDeleteCancel;

  /// No description provided for @createProductDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete food'**
  String get createProductDeleteAction;

  /// No description provided for @createProductDeleted.
  ///
  /// In en, this message translates to:
  /// **'{food} deleted'**
  String createProductDeleted(String food);

  /// No description provided for @createProductDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete food'**
  String get createProductDeleteFailed;

  /// No description provided for @createProductUnitServing.
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get createProductUnitServing;

  /// No description provided for @createProductUnitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get createProductUnitPiece;

  /// No description provided for @createProductUnitGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get createProductUnitGlass;

  /// No description provided for @createProductUnitScoop.
  ///
  /// In en, this message translates to:
  /// **'Scoop'**
  String get createProductUnitScoop;

  /// No description provided for @createProductBack.
  ///
  /// In en, this message translates to:
  /// **'Back to food search'**
  String get createProductBack;

  /// No description provided for @createProductStubMessage.
  ///
  /// In en, this message translates to:
  /// **'Product creation will be implemented in a later slice.'**
  String get createProductStubMessage;

  /// No description provided for @foodSearchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get foodSearchRecent;

  /// No description provided for @foodSearchMyDishes.
  ///
  /// In en, this message translates to:
  /// **'My dishes'**
  String get foodSearchMyDishes;

  /// No description provided for @foodSearchFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get foodSearchFavorites;

  /// No description provided for @foodSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get foodSearchResults;

  /// No description provided for @foodSearchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get foodSearchNoResultsTitle;

  /// No description provided for @foodSearchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another name or create your own food.'**
  String get foodSearchNoResultsMessage;

  /// No description provided for @foodSearchTabEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get foodSearchTabEmptyTitle;

  /// No description provided for @foodSearchTabEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Foods matching this filter will appear here.'**
  String get foodSearchTabEmptyMessage;

  /// No description provided for @foodSearchLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading foods'**
  String get foodSearchLoading;

  /// No description provided for @foodSearchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Foods could not be loaded'**
  String get foodSearchErrorTitle;

  /// No description provided for @foodSearchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Try loading the local catalog again.'**
  String get foodSearchErrorMessage;

  /// No description provided for @foodSearchCaloriesPerReference.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal / {quantity}'**
  String foodSearchCaloriesPerReference(String calories, String quantity);

  /// No description provided for @foodCategoryGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get foodCategoryGrains;

  /// No description provided for @foodCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get foodCategoryOther;

  /// No description provided for @foodCategoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get foodCategoryDairy;

  /// No description provided for @foodCategorySportsNutrition.
  ///
  /// In en, this message translates to:
  /// **'Sports nutrition'**
  String get foodCategorySportsNutrition;

  /// No description provided for @foodCategoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get foodCategoryFruit;

  /// No description provided for @foodCategoryPoultry.
  ///
  /// In en, this message translates to:
  /// **'Meat & poultry'**
  String get foodCategoryPoultry;

  /// No description provided for @foodCategoryEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get foodCategoryEggs;

  /// No description provided for @foodCategoryBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get foodCategoryBread;

  /// No description provided for @foodCategoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get foodCategoryDrinks;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get quickAddTitle;

  /// No description provided for @quickAddQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quickAddQuantity;

  /// No description provided for @quickAddUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get quickAddUnit;

  /// No description provided for @quickAddUnitEquivalent.
  ///
  /// In en, this message translates to:
  /// **'{unit} = {quantity}'**
  String quickAddUnitEquivalent(String unit, String quantity);

  /// No description provided for @quickAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get quickAddMeal;

  /// No description provided for @quickAddNutrition.
  ///
  /// In en, this message translates to:
  /// **'For this amount'**
  String get quickAddNutrition;

  /// No description provided for @quickAddDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get quickAddDecrease;

  /// No description provided for @quickAddIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get quickAddIncrease;

  /// No description provided for @quickAddAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than zero'**
  String get quickAddAmountInvalid;

  /// No description provided for @quickAddAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAddAdd;

  /// No description provided for @quickAddQuickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick select'**
  String get quickAddQuickSelect;

  /// No description provided for @quickAddUsualAmount.
  ///
  /// In en, this message translates to:
  /// **'Usually: {quantity}'**
  String quickAddUsualAmount(String quantity);

  /// No description provided for @quickAddSelectedMeal.
  ///
  /// In en, this message translates to:
  /// **'In {meal}'**
  String quickAddSelectedMeal(String meal);

  /// No description provided for @quickAddClose.
  ///
  /// In en, this message translates to:
  /// **'Close quick add'**
  String get quickAddClose;

  /// No description provided for @quickAddAddToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String quickAddAddToMeal(String meal);

  /// No description provided for @quickAddFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get quickAddFavoriteAdd;

  /// No description provided for @quickAddFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get quickAddFavoriteRemove;

  /// No description provided for @foodFavoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'{food} added to favorites'**
  String foodFavoriteAdded(String food);

  /// No description provided for @foodFavoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'{food} removed from favorites'**
  String foodFavoriteRemoved(String food);

  /// No description provided for @foodFavoriteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites'**
  String get foodFavoriteSaveFailed;

  /// No description provided for @foodAdded.
  ///
  /// In en, this message translates to:
  /// **'{food} added to {meal}'**
  String foodAdded(String food, String meal);

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @unitKilocalories.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKilocalories;

  /// No description provided for @unitGrams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGrams;

  /// No description provided for @unitMilliliters.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMilliliters;

  /// No description provided for @unitPieces.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPieces;

  /// No description provided for @unitServings.
  ///
  /// In en, this message translates to:
  /// **'serving'**
  String get unitServings;

  /// No description provided for @unitScoops.
  ///
  /// In en, this message translates to:
  /// **'scoop'**
  String get unitScoops;

  /// No description provided for @unitGlasses.
  ///
  /// In en, this message translates to:
  /// **'glass'**
  String get unitGlasses;

  /// No description provided for @quantityServings.
  ///
  /// In en, this message translates to:
  /// **'{value, plural, =1{1 serving} other{{value} servings}}'**
  String quantityServings(num value);

  /// No description provided for @quantityScoops.
  ///
  /// In en, this message translates to:
  /// **'{value, plural, =1{1 scoop} other{{value} scoops}}'**
  String quantityScoops(num value);

  /// No description provided for @quantityGlasses.
  ///
  /// In en, this message translates to:
  /// **'{value, plural, =1{1 glass} other{{value} glasses}}'**
  String quantityGlasses(num value);

  /// No description provided for @quantityGrams.
  ///
  /// In en, this message translates to:
  /// **'{value} g'**
  String quantityGrams(num value);

  /// No description provided for @quantityMilliliters.
  ///
  /// In en, this message translates to:
  /// **'{value} ml'**
  String quantityMilliliters(num value);

  /// No description provided for @quantityPieces.
  ///
  /// In en, this message translates to:
  /// **'{value, plural, =1{1 pc} other{{value} pcs}}'**
  String quantityPieces(num value);

  /// No description provided for @demoEggs.
  ///
  /// In en, this message translates to:
  /// **'Boiled eggs'**
  String get demoEggs;

  /// No description provided for @demoBread.
  ///
  /// In en, this message translates to:
  /// **'Whole-grain bread'**
  String get demoBread;

  /// No description provided for @demoMilk.
  ///
  /// In en, this message translates to:
  /// **'Pasteurized milk 2.5%'**
  String get demoMilk;

  /// No description provided for @demoChickenBreast.
  ///
  /// In en, this message translates to:
  /// **'Grilled chicken breast'**
  String get demoChickenBreast;

  /// No description provided for @demoRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get demoRice;

  /// No description provided for @demoCottageCheese.
  ///
  /// In en, this message translates to:
  /// **'Cottage cheese'**
  String get demoCottageCheese;

  /// No description provided for @demoBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get demoBanana;

  /// No description provided for @demoYogurt.
  ///
  /// In en, this message translates to:
  /// **'Natural Greek yogurt 2%'**
  String get demoYogurt;

  /// No description provided for @demoProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein powder'**
  String get demoProtein;

  /// No description provided for @demoApple.
  ///
  /// In en, this message translates to:
  /// **'Green apple'**
  String get demoApple;

  /// No description provided for @diaryDemoBuckwheat.
  ///
  /// In en, this message translates to:
  /// **'Buckwheat porridge'**
  String get diaryDemoBuckwheat;

  /// No description provided for @diaryDemoVegetableSalad.
  ///
  /// In en, this message translates to:
  /// **'Fresh vegetable salad'**
  String get diaryDemoVegetableSalad;

  /// No description provided for @diaryDemoOliveOil.
  ///
  /// In en, this message translates to:
  /// **'Extra virgin olive oil'**
  String get diaryDemoOliveOil;

  /// No description provided for @diaryDemoSteamedSalmon.
  ///
  /// In en, this message translates to:
  /// **'Steamed salmon fillet'**
  String get diaryDemoSteamedSalmon;

  /// No description provided for @diaryDemoSteamedVegetables.
  ///
  /// In en, this message translates to:
  /// **'Steamed broccoli and carrots'**
  String get diaryDemoSteamedVegetables;

  /// No description provided for @diaryDemoAvocado.
  ///
  /// In en, this message translates to:
  /// **'Hass avocado'**
  String get diaryDemoAvocado;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsPrototypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Nutrition and weight trends will appear here.'**
  String get statisticsPrototypeMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGoalsSection.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get settingsGoalsSection;

  /// No description provided for @settingsOpenOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Go through onboarding'**
  String get settingsOpenOnboarding;

  /// No description provided for @settingsGoalsNutrition.
  ///
  /// In en, this message translates to:
  /// **'Goals & nutrition'**
  String get settingsGoalsNutrition;

  /// No description provided for @settingsGoalsSummary.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal · P {protein} · F {fat} · C {carbs}'**
  String settingsGoalsSummary(
    String calories,
    String protein,
    String fat,
    String carbs,
  );

  /// No description provided for @settingsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get settingsWeight;

  /// No description provided for @settingsWeightSummary.
  ///
  /// In en, this message translates to:
  /// **'{current} kg → {target} kg'**
  String settingsWeightSummary(String current, String target);

  /// No description provided for @settingsApplicationSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApplicationSection;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsUnitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get settingsUnitsMetric;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get settingsUnavailable;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAboutYam.
  ///
  /// In en, this message translates to:
  /// **'About YAM'**
  String get settingsAboutYam;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A fast, local-first nutrition tracker.'**
  String get settingsAboutDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
