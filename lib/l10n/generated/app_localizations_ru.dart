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
  String get foodSearchForYou => 'Для вас';

  @override
  String get foodSearchFrequent => 'Часто добавляют';

  @override
  String foodSearchFrequentForMeal(String meal) {
    return 'Часто добавляют: $meal';
  }

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
  String get foodSearchVerified => 'Проверенный продукт';

  @override
  String get foodSearchSourceLocal => 'Локальный каталог';

  @override
  String get foodSearchSourceUser => 'Ваш продукт';

  @override
  String foodSearchCaloriesPerReference(String calories, String quantity) {
    return '$calories ккал / $quantity';
  }

  @override
  String foodSearchQuickAdd(String quantity) {
    return '+ $quantity';
  }

  @override
  String foodSearchQuickAddSemantics(String food, String quantity) {
    return 'Добавить $food, $quantity';
  }

  @override
  String get quickAddTitle => 'Добавить в дневник';

  @override
  String get quickAddQuantity => 'Количество';

  @override
  String get quickAddUnit => 'Единица';

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
  String foodAdded(String food, String meal) {
    return '$food добавлен в раздел «$meal»';
  }

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionRetry => 'Повторить';

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
  String get settingsPrototypeMessage =>
      'Здесь будут настраиваться цели, единицы и внешний вид.';
}
