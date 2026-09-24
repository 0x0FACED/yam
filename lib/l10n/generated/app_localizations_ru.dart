// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'YAM';

  @override
  String get startupLoadingLabel => 'YAM запускается';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get onboardingGoalTitle => 'Что хочешь изменить?';

  @override
  String get onboardingGoalDescription =>
      'Это определит баланс калорий и макронутриентов на каждый день';

  @override
  String get onboardingGoalLose => 'Снизить вес';

  @override
  String get onboardingGoalLoseDescription => 'Для постепенного снижения веса';

  @override
  String get onboardingGoalMaintain => 'Поддерживать вес';

  @override
  String get onboardingGoalMaintainDescription => 'Чтобы сохранять текущий вес';

  @override
  String get onboardingGoalGain => 'Набрать вес';

  @override
  String get onboardingGoalGainDescription => 'Для постепенного набора веса';

  @override
  String get onboardingWeightTitle => 'Вес';

  @override
  String get onboardingWeightDescription => 'Укажи текущий и желаемый вес';

  @override
  String get onboardingCurrentWeight => 'Текущий вес';

  @override
  String get onboardingTargetWeight => 'Целевой вес';

  @override
  String get onboardingWeightDifference => 'Разница до цели';

  @override
  String get onboardingWeightUnchanged => 'Удержание текущего веса';

  @override
  String get onboardingNutritionTitle => 'Цели питания';

  @override
  String get onboardingNutritionDescription =>
      'Задайте базовые суточные ориентиры под ваш режим';

  @override
  String get onboardingCalories => 'Калории в день';

  @override
  String get onboardingMacros => 'Макронутриенты';

  @override
  String onboardingEnergyFromMacros(String calories) {
    return 'По БЖУ: $calories ккал';
  }

  @override
  String onboardingEnergyAbove(String difference) {
    return '+$difference ккал относительно цели';
  }

  @override
  String onboardingEnergyBelow(String difference) {
    return '−$difference ккал относительно цели';
  }

  @override
  String get onboardingEnergyMatches => 'Совпадает с целью';

  @override
  String get onboardingEnergyFormulaHint =>
      'Расчёт: белки и углеводы × 4, жиры × 9 ккал/г.';

  @override
  String get onboardingNutritionHint =>
      'Эти значения можно изменить позже в настройках.';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingClose => 'Закрыть онбординг';

  @override
  String get onboardingInvalidPositive => 'Введите число больше нуля';

  @override
  String get onboardingInvalidNonNegative => 'Введите число не меньше нуля';

  @override
  String get unitKilograms => 'кг';

  @override
  String get navigationDiary => 'Дневник';

  @override
  String get navigationStatistics => 'Статистика';

  @override
  String get navigationSettings => 'Настройки';

  @override
  String get diaryTitle => 'Дневник';

  @override
  String get diaryToday => 'Сегодня';

  @override
  String get diaryPreviousDay => 'Предыдущий день';

  @override
  String get diaryNextDay => 'Следующий день';

  @override
  String get diaryOpenCalendar => 'Открыть календарь';

  @override
  String get diaryReturnToToday => 'Вернуться к сегодняшнему дню';

  @override
  String get diaryConsumed => 'Съедено';

  @override
  String diaryCalorieGoalSuffix(String target) {
    return '/ $target ккал';
  }

  @override
  String diaryCaloriesRemaining(String remaining) {
    return 'Осталось $remaining ккал';
  }

  @override
  String diaryCaloriesOverTarget(String excess) {
    return 'Сверх цели на $excess ккал';
  }

  @override
  String get macroProtein => 'Белки';

  @override
  String get macroFat => 'Жиры';

  @override
  String get macroCarbs => 'Углеводы';

  @override
  String get macroProteinShort => 'Б';

  @override
  String get macroFatShort => 'Ж';

  @override
  String get macroCarbsShort => 'У';

  @override
  String macroGramsProgress(String consumed, String target) {
    return '$consumed / $target г';
  }

  @override
  String get mealBreakfast => 'Завтрак';

  @override
  String get mealLunch => 'Обед';

  @override
  String get mealDinner => 'Ужин';

  @override
  String get mealSnacks => 'Перекус';

  @override
  String mealCalories(String calories) {
    return '$calories ккал';
  }

  @override
  String get diaryAddFood => 'Добавить еду';

  @override
  String diaryAddFoodToMeal(String meal) {
    return 'Добавить еду в раздел «$meal»';
  }

  @override
  String get diaryAddFoodPrototypeMessage =>
      'Здесь откроется поиск еды в следующем прототипе.';

  @override
  String get diaryNoFoods => 'Пока ничего нет';

  @override
  String get foodSearchTitle => 'Добавить еду';

  @override
  String get foodSearchHint => 'Найти продукт или блюдо';

  @override
  String get foodSearchBack => 'Назад в дневник';

  @override
  String get foodSearchClear => 'Очистить поиск';

  @override
  String get foodSearchChooseMeal => 'Выбрать приём пищи';

  @override
  String foodSearchSelectedMeal(String meal) {
    return 'Приём: $meal';
  }

  @override
  String get foodSearchSelectMealTitle => 'Куда добавить продукт?';

  @override
  String get foodSearchMealRequired => 'Сначала выберите приём пищи';

  @override
  String get foodSearchCreateFood => 'Создать продукт';

  @override
  String get createProductBack => 'Назад к поиску еды';

  @override
  String get createProductStubMessage =>
      'Создание продукта будет реализовано в следующем этапе.';

  @override
  String get foodSearchRecent => 'Недавние';

  @override
  String get foodSearchMyDishes => 'Мои блюда';

  @override
  String get foodSearchFavorites => 'Избранное';

  @override
  String get foodSearchResults => 'Результаты поиска';

  @override
  String get foodSearchNoResultsTitle => 'Ничего не нашли';

  @override
  String get foodSearchNoResultsMessage =>
      'Попробуйте другое название или создайте свой продукт.';

  @override
  String get foodSearchTabEmptyTitle => 'Здесь пока пусто';

  @override
  String get foodSearchTabEmptyMessage =>
      'Здесь появятся продукты из выбранного раздела.';

  @override
  String get foodSearchLoading => 'Загрузка продуктов';

  @override
  String get foodSearchErrorTitle => 'Не удалось загрузить продукты';

  @override
  String get foodSearchErrorMessage =>
      'Попробуйте снова загрузить локальный каталог.';

  @override
  String foodSearchCaloriesPerReference(String calories, String quantity) {
    return '$calories ккал / $quantity';
  }

  @override
  String get foodCategoryGrains => 'Крупы';

  @override
  String get foodCategoryDairy => 'Молочные продукты';

  @override
  String get foodCategorySportsNutrition => 'Спортивное питание';

  @override
  String get foodCategoryFruit => 'Фрукты';

  @override
  String get foodCategoryPoultry => 'Мясо и птица';

  @override
  String get foodCategoryEggs => 'Яйца';

  @override
  String get foodCategoryBread => 'Хлеб';

  @override
  String get foodCategoryDrinks => 'Напитки';

  @override
  String get quickAddTitle => 'Добавить в дневник';

  @override
  String get quickAddQuantity => 'Количество';

  @override
  String get quickAddUnit => 'Единица';

  @override
  String quickAddUnitEquivalent(String unit, String quantity) {
    return '$unit = $quantity';
  }

  @override
  String get quickAddMeal => 'Приём пищи';

  @override
  String get quickAddNutrition => 'Для этого количества';

  @override
  String get quickAddDecrease => 'Уменьшить количество';

  @override
  String get quickAddIncrease => 'Увеличить количество';

  @override
  String get quickAddAmountInvalid => 'Введите количество больше нуля';

  @override
  String get quickAddAdd => 'Добавить';

  @override
  String get quickAddQuickSelect => 'Быстрый выбор';

  @override
  String quickAddUsualAmount(String quantity) {
    return 'Обычно: $quantity';
  }

  @override
  String quickAddSelectedMeal(String meal) {
    return 'В «$meal»';
  }

  @override
  String get quickAddClose => 'Закрыть добавление';

  @override
  String quickAddAddToMeal(String meal) {
    return 'Добавить в «$meal»';
  }

  @override
  String get quickAddFavoriteAdd => 'Добавить в избранное';

  @override
  String get quickAddFavoriteRemove => 'Убрать из избранного';

  @override
  String foodFavoriteAdded(String food) {
    return '«$food» — в избранном';
  }

  @override
  String foodFavoriteRemoved(String food) {
    return '«$food» убран из избранного';
  }

  @override
  String foodAdded(String food, String meal) {
    return '$food добавлен в раздел «$meal»';
  }

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get unitKilocalories => 'ккал';

  @override
  String get unitGrams => 'г';

  @override
  String get unitMilliliters => 'мл';

  @override
  String get unitPieces => 'шт.';

  @override
  String get unitServings => 'порция';

  @override
  String get unitScoops => 'мерная ложка';

  @override
  String get unitGlasses => 'стакан';

  @override
  String quantityServings(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value порции',
      many: '$value порций',
      few: '$value порции',
      one: '1 порция',
    );
    return '$_temp0';
  }

  @override
  String quantityScoops(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value мерной ложки',
      many: '$value мерных ложек',
      few: '$value мерные ложки',
      one: '1 мерная ложка',
    );
    return '$_temp0';
  }

  @override
  String quantityGlasses(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value стакана',
      many: '$value стаканов',
      few: '$value стакана',
      one: '1 стакан',
    );
    return '$_temp0';
  }

  @override
  String quantityGrams(num value) {
    return '$value г';
  }

  @override
  String quantityMilliliters(num value) {
    return '$value мл';
  }

  @override
  String quantityPieces(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value шт.',
      many: '$value шт.',
      few: '$value шт.',
      one: '1 шт.',
    );
    return '$_temp0';
  }

  @override
  String get demoEggs => 'Яйца куриные вареные';

  @override
  String get demoBread => 'Хлеб цельнозерновой';

  @override
  String get demoMilk => 'Молоко пастеризованное 2,5%';

  @override
  String get demoChickenBreast => 'Куриное филе гриль';

  @override
  String get demoRice => 'Рис';

  @override
  String get demoCottageCheese => 'Творог';

  @override
  String get demoBanana => 'Банан';

  @override
  String get demoYogurt => 'Греческий йогурт натуральный 2%';

  @override
  String get demoProtein => 'Протеин';

  @override
  String get demoApple => 'Яблоко зеленое';

  @override
  String get diaryDemoBuckwheat => 'Гречневая каша рассыпчатая';

  @override
  String get diaryDemoVegetableSalad => 'Салат со свежими овощами';

  @override
  String get diaryDemoOliveOil => 'Оливковое масло Extra Virgin';

  @override
  String get diaryDemoSteamedSalmon => 'Филе лосося на пару';

  @override
  String get diaryDemoSteamedVegetables => 'Овощи на пару (брокколи, морковь)';

  @override
  String get diaryDemoAvocado => 'Авокадо Хасс';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get statisticsPrototypeMessage =>
      'Здесь появятся тренды питания и веса.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGoalsSection => 'Цели';

  @override
  String get settingsOpenOnboarding => 'Пройти онбординг';

  @override
  String get settingsGoalsNutrition => 'Цели и питание';

  @override
  String settingsGoalsSummary(
    String calories,
    String protein,
    String fat,
    String carbs,
  ) {
    return '$calories ккал · Б $protein · Ж $fat · У $carbs';
  }

  @override
  String get settingsWeight => 'Вес';

  @override
  String settingsWeightSummary(String current, String target) {
    return '$current кг → $target кг';
  }

  @override
  String get settingsApplicationSection => 'Приложение';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsUnits => 'Единицы измерения';

  @override
  String get settingsUnitsMetric => 'Метрические';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsDataSection => 'Данные';

  @override
  String get settingsExportData => 'Экспорт данных';

  @override
  String get settingsDeleteAllData => 'Удалить все данные';

  @override
  String get settingsUnavailable => 'Недоступно';

  @override
  String get settingsAboutSection => 'О приложении';

  @override
  String get settingsAboutYam => 'О YAM';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get settingsAboutDescription => 'Быстрый локальный дневник питания.';
}
