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

  /// No description provided for @foodSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get foodSearchTitle;

  /// No description provided for @foodSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
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

  /// No description provided for @foodSearchCreateFoodPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Custom food creation will be available in the functional version.'**
  String get foodSearchCreateFoodPlaceholder;

  /// No description provided for @foodSearchFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequently added'**
  String get foodSearchFrequent;

  /// No description provided for @foodSearchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get foodSearchRecent;

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

  /// No description provided for @foodSearchVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified food'**
  String get foodSearchVerified;

  /// No description provided for @foodSearchSourceLocal.
  ///
  /// In en, this message translates to:
  /// **'Local catalog'**
  String get foodSearchSourceLocal;

  /// No description provided for @foodSearchSourceUser.
  ///
  /// In en, this message translates to:
  /// **'Your food'**
  String get foodSearchSourceUser;

  /// No description provided for @foodSearchCaloriesPerReference.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal / {quantity}'**
  String foodSearchCaloriesPerReference(String calories, String quantity);

  /// No description provided for @foodSearchMacrosSummary.
  ///
  /// In en, this message translates to:
  /// **'P {protein} · F {fat} · C {carbs}'**
  String foodSearchMacrosSummary(String protein, String fat, String carbs);

  /// No description provided for @foodSearchQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'+ {quantity}'**
  String foodSearchQuickAdd(String quantity);

  /// No description provided for @foodSearchQuickAddSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add {food}, {quantity}'**
  String foodSearchQuickAddSemantics(String food, String quantity);

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
  /// **'Eggs'**
  String get demoEggs;

  /// No description provided for @demoBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get demoBread;

  /// No description provided for @demoMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk 2.5%'**
  String get demoMilk;

  /// No description provided for @demoChickenBreast.
  ///
  /// In en, this message translates to:
  /// **'Chicken breast'**
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
  /// **'Greek yogurt'**
  String get demoYogurt;

  /// No description provided for @demoProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein powder'**
  String get demoProtein;

  /// No description provided for @demoApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get demoApple;

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

  /// No description provided for @settingsPrototypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Goals, units and appearance will be configured here.'**
  String get settingsPrototypeMessage;
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
