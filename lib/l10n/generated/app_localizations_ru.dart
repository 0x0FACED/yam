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
  String get startupDataLoading => 'Открываем локальные данные';

  @override
  String get startupDataErrorTitle => 'Не удалось открыть данные';

  @override
  String get startupDataErrorMessage =>
      'Попробуйте повторить загрузку локальной базы данных.';

  @override
  String get updateSection => 'Обновления приложения';

  @override
  String get updateCheckAction => 'Проверить обновления';

  @override
  String get updateSource => 'GitHub · 0x0FACED/yam';

  @override
  String get updateCheckHint => 'Проверьте наличие новой Android-версии.';

  @override
  String get updateChecking => 'Проверяем обновления…';

  @override
  String get updateUpToDate => 'У вас последняя версия.';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String updateDownloading(String percent) {
    return 'Скачивание: $percent';
  }

  @override
  String updateReady(String version) {
    return 'Версия $version готова к установке';
  }

  @override
  String get updateOpeningInstaller => 'Открываем системный установщик…';

  @override
  String updateDownloadAction(String size) {
    return 'Скачать · $size МБ';
  }

  @override
  String get updateInstallAction => 'Установить обновление';

  @override
  String get updateInstallHint =>
      'Android попросит подтвердить установку. После успешного обновления APK удалится автоматически.';

  @override
  String get updateUnavailable =>
      'Публичный релиз недоступен. Возможно, репозиторий ещё приватный или релизы пока не опубликованы.';

  @override
  String get updateNetworkError =>
      'Не удалось проверить обновления. Проверьте подключение к интернету и повторите попытку.';

  @override
  String get updateRateLimited =>
      'Достигнут лимит запросов GitHub. Попробуйте позже.';

  @override
  String get updateInvalidRelease =>
      'В релизе нет корректного Android-пакета и контрольной суммы.';

  @override
  String get updateDownloadError =>
      'Не удалось скачать или сохранить обновление. Проверьте подключение и свободное место, затем попробуйте ещё раз.';

  @override
  String get updateChecksumError =>
      'Скачанный файл повреждён. Скачайте обновление заново.';

  @override
  String get updatePermissionHint =>
      'Разрешите YAM установку приложений в настройках Android, вернитесь сюда и снова нажмите «Установить обновление».';

  @override
  String get updateSignatureError =>
      'APK подписан другим ключом и не может обновить эту установку. Перед ручной переустановкой экспортируйте резервную копию.';

  @override
  String get updateInvalidApk =>
      'APK не соответствует приложению или ожидаемой новой версии. Скачайте обновление заново.';

  @override
  String get updateInstallError =>
      'Не удалось открыть системный установщик. Попробуйте ещё раз.';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get onboardingGoalTitle => 'Что хочешь изменить?';

  @override
  String get onboardingGoalRequired => 'Выберите цель';

  @override
  String get onboardingSaveFailed => 'Не удалось сохранить цели и вес';

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
  String get diaryGoalNotSet => 'Цель пока не задана';

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
  String get diaryEditEntry => 'Редактировать запись';

  @override
  String get diaryEditSave => 'Сохранить изменения';

  @override
  String get diaryEditClose => 'Закрыть редактирование';

  @override
  String get diaryDeleteEntry => 'Удалить запись';

  @override
  String diaryEntryDeleted(String food) {
    return 'Запись «$food» удалена';
  }

  @override
  String diaryEntryUpdated(String food) {
    return 'Запись «$food» изменена';
  }

  @override
  String get diarySaveFailed => 'Не удалось сохранить запись';

  @override
  String get diaryDeleteFailed => 'Не удалось удалить запись';

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
  String get createProductEditTitle => 'Изменить продукт';

  @override
  String get createProductName => 'Название продукта';

  @override
  String get createProductNameHint => 'Например, овсяные хлопья';

  @override
  String get createProductBrand => 'Бренд';

  @override
  String get createProductBrandHint => 'Если есть';

  @override
  String get createProductCategory => 'Категория';

  @override
  String get createProductCategoryHint => 'Введите или выберите категорию';

  @override
  String get createProductCategoryRequired => 'Укажите категорию';

  @override
  String get createProductDescription => 'Описание (необязательно)';

  @override
  String get createProductDescriptionHint =>
      'Ингредиенты, приготовление или другие заметки';

  @override
  String get foodDescription => 'Описание';

  @override
  String get createProductNutritionBasis => 'Значения указаны на';

  @override
  String get createProductPerHundredGrams => '100 г';

  @override
  String get createProductPerHundredMilliliters => '100 мл';

  @override
  String get createProductPerServing => '1 порцию';

  @override
  String get createProductServingSize => 'Размер этой порции';

  @override
  String get createProductNutrition => 'Пищевая ценность';

  @override
  String createProductCalculatedCalories(String calories) {
    return 'По БЖУ: $calories ккал';
  }

  @override
  String get createProductServings => 'Дополнительные единицы';

  @override
  String get createProductAddServing => 'Добавить единицу';

  @override
  String get createProductServingName => 'Название (необязательно)';

  @override
  String get createProductServingNameHint => 'Например, бутылка';

  @override
  String get createProductServingAmount => 'В одной единице';

  @override
  String get createProductRemoveServing => 'Удалить единицу';

  @override
  String get createProductBarcode => 'Штрихкод (необязательно)';

  @override
  String get createProductSave => 'Сохранить продукт';

  @override
  String get createProductUpdate => 'Сохранить изменения';

  @override
  String get createProductSaving => 'Сохранение…';

  @override
  String get createProductNameRequired => 'Укажите название';

  @override
  String get createProductInvalidNumber => 'Введите число не меньше нуля';

  @override
  String get createProductPositiveAmount => 'Укажите размер больше нуля';

  @override
  String get createProductInvalidBarcode => 'Введите штрихкод цифрами';

  @override
  String get createProductDuplicateBarcode =>
      'Продукт с таким штрихкодом уже есть';

  @override
  String get createProductSaveFailed => 'Не удалось сохранить продукт';

  @override
  String createProductSaved(String food) {
    return 'Продукт «$food» сохранён';
  }

  @override
  String createProductUpdated(String food) {
    return 'Продукт «$food» обновлён';
  }

  @override
  String get createProductMore => 'Ещё';

  @override
  String get createProductEdit => 'Изменить';

  @override
  String get createProductDeleteTitle => 'Удалить продукт?';

  @override
  String createProductDeleteMessage(String food) {
    return '«$food» исчезнет из ваших блюд, поиска и избранного.';
  }

  @override
  String get createProductDelete => 'Удалить';

  @override
  String get createProductDeleteCancel => 'Отмена';

  @override
  String get createProductDeleteAction => 'Удалить продукт';

  @override
  String createProductDeleted(String food) {
    return 'Продукт «$food» удалён';
  }

  @override
  String get createProductDeleteFailed => 'Не удалось удалить продукт';

  @override
  String get createProductUnitServing => 'Порция';

  @override
  String get createProductUnitPiece => 'Штука';

  @override
  String get createProductUnitGlass => 'Стакан';

  @override
  String get createProductUnitScoop => 'Мерная ложка';

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
  String get foodSearchOpenFoodFacts => 'Open Food Facts';

  @override
  String get foodSearchRemoteLoading => 'Ищем в Open Food Facts';

  @override
  String get foodSearchRemoteShortQuery =>
      'Введите не менее 3 символов для поиска в Open Food Facts.';

  @override
  String get foodSearchRemoteEmpty =>
      'В Open Food Facts нет продуктов с полными данными для добавления.';

  @override
  String get foodSearchRemoteError =>
      'Open Food Facts недоступен. Локальные продукты по-прежнему доступны.';

  @override
  String get foodSearchRemoteAttribution => 'Данные: Open Food Facts';

  @override
  String get foodSearchRemoteLicense => 'Лицензия ODbL';

  @override
  String get foodSearchRemoteLinkError => 'Не удалось открыть ссылку.';

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
  String get foodCategoryOther => 'Другое';

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
  String get foodFavoriteSaveFailed => 'Не удалось изменить избранное';

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
  String get statsPeriod7 => '7Д';

  @override
  String get statsPeriod30 => '30Д';

  @override
  String get statsPeriod90 => '3М';

  @override
  String get statsPeriod365 => '1Г';

  @override
  String get statsPeriodAll => 'Всё';

  @override
  String get statsNoData => 'Нет записей';

  @override
  String get statsLoading => 'Загружаем статистику';

  @override
  String statsCurrentGoal(String value) {
    return 'Текущая цель: $value';
  }

  @override
  String get statsGoalLegend => 'Цель';

  @override
  String statsAverageGoal(String value) {
    return 'Средняя цель: $value';
  }

  @override
  String statsGoalDifference(String value) {
    return 'Отклонение от цели: $value';
  }

  @override
  String statsNutritionDetails(String protein, String fat, String carbs) {
    return 'Б $protein г · Ж $fat г · У $carbs г';
  }

  @override
  String statsGoalDaysSummary(String within, String total, String percent) {
    return 'В цели: $within из $total дней ($percent%)';
  }

  @override
  String get statsWeight => 'Вес';

  @override
  String get statsAverageCalories => 'Средние калории';

  @override
  String get statsAverageProtein => 'Средний белок';

  @override
  String get statsDaysInGoal => 'Дни в цели';

  @override
  String get statsWeightChart => 'Вес тела';

  @override
  String get statsCaloriesChart => 'Калории';

  @override
  String get statsAverageMacros => 'Среднее БЖУ';

  @override
  String get statsRegularity => 'Регулярность';

  @override
  String get statsFrequentFoods => 'Часто в рационе';

  @override
  String statsGoal(String value) {
    return 'Цель: $value';
  }

  @override
  String get statsDailyAverage => 'ккал/день';

  @override
  String get statsGramsPerDay => 'г/день';

  @override
  String statsPercentOfGoal(String percent) {
    return '$percent% от цели';
  }

  @override
  String statsInGoalCount(String within, String total) {
    return '$within / $total';
  }

  @override
  String statsLoggedDays(String days) {
    return 'Дней с едой: $days';
  }

  @override
  String statsDaysWithFood(String days) {
    return 'Дней: $days';
  }

  @override
  String get statsNoWeight => 'Пока нет измерений веса';

  @override
  String get statsNoWeightInPeriod => 'В этом периоде нет измерений веса';

  @override
  String get statsNoWeightHint => 'Запишите вес, чтобы увидеть его изменение.';

  @override
  String get statsNoNutrition => 'Пока нет записей питания за этот период';

  @override
  String get statsNoGoal => 'Цель не задана';

  @override
  String get statsNoGoalDays => 'Задайте цель, чтобы видеть регулярность.';

  @override
  String get statsNoFrequent => 'Здесь появятся продукты из дневника.';

  @override
  String get statsAddWeight => 'Записать вес';

  @override
  String get statsEditWeight => 'Изменить взвешивание';

  @override
  String get statsWeightDate => 'Дата взвешивания';

  @override
  String get statsSaveWeight => 'Сохранить вес';

  @override
  String get statsWeightClose => 'Закрыть ввод веса';

  @override
  String get statsDeleteWeight => 'Удалить взвешивание';

  @override
  String get statsInvalidWeight => 'Введите вес больше нуля';

  @override
  String get statsWeightSaved => 'Вес сохранён';

  @override
  String get statsWeightDeleted => 'Взвешивание удалено';

  @override
  String get statsWeightFailed => 'Не удалось изменить вес';

  @override
  String get statsGoalWithin => 'В цели';

  @override
  String get statsGoalBelow => 'Недобор';

  @override
  String get statsGoalAbove => 'Превышение';

  @override
  String get statsNoEntry => 'Нет записи';

  @override
  String statsWeightChange(String change) {
    return '$change кг за период';
  }

  @override
  String statsWeightLastDate(String date) {
    return 'Последнее: $date';
  }

  @override
  String statsWindow(String start, String end) {
    return 'Показано: $start — $end';
  }

  @override
  String statsAveragePortion(String amount, String unit) {
    return '~$amount $unit';
  }

  @override
  String statsPercentOfTrackedDays(String percent) {
    return '$percent% дней с едой';
  }

  @override
  String get statsBucketAverage => 'Среднее за дни с записями';

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
  String get settingsGoalsNotSet => 'Цели не заданы';

  @override
  String get settingsWeightNotSet => 'Вес пока не записан';

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
  String get settingsImportData => 'Импорт данных';

  @override
  String get backupSaveDialogTitle => 'Сохранить копию YAM';

  @override
  String get backupOpenDialogTitle => 'Открыть копию YAM';

  @override
  String get backupExportSuccess => 'Резервная копия сохранена.';

  @override
  String get backupExportFailed =>
      'Не удалось сохранить копию. Попробуйте ещё раз.';

  @override
  String get backupExportInvalidData =>
      'Не удалось подготовить сохранённые данные для экспорта. Исходные данные не изменены.';

  @override
  String get backupImportFailed =>
      'Не удалось импортировать копию. Данные не изменены.';

  @override
  String get backupInvalidFile =>
      'Это не резервная копия YAM или файл повреждён. Данные не импортированы.';

  @override
  String get backupUnsupportedVersion =>
      'Эта версия резервной копии не поддерживается. Попробуйте обновить YAM.';

  @override
  String get backupTooLarge =>
      'Размер резервной копии превышает допустимый предел.';

  @override
  String get backupPersonalDataNote =>
      'Файл .yam содержит дневник, вес, цели и данные продуктов, включая удалённые записи. Файл не зашифрован — храните его в безопасном месте. Тема приложения в копию не входит.';

  @override
  String get backupReplaceTitle => 'Заменить локальные данные?';

  @override
  String get backupReplaceWarning =>
      'Все локальные продукты, порции, записи дневника, цели, записи веса и кешированные продукты будут удалены и заменены данными из копии. Это действие нельзя отменить. Пустая копия очистит эти записи. Если в копии нет целей, потребуется снова пройти онбординг.';

  @override
  String get backupReplaceConfirm => 'Заменить все данные';

  @override
  String get backupSaveAction => 'Выбрать место сохранения';

  @override
  String get backupCancel => 'Отмена';

  @override
  String get backupClose => 'Закрыть';

  @override
  String get backupDone => 'Готово';

  @override
  String get backupPreviewTitle => 'Импорт резервной копии';

  @override
  String backupExportedAt(String date) {
    return 'Создана: $date';
  }

  @override
  String get backupCountsNote =>
      'Количество включает удалённые записи. Данные не изменятся до подтверждения импорта ниже.';

  @override
  String get backupSupplementDescription =>
      'Все текущие записи, включая отметки об удалении, останутся без изменений. Добавятся только отсутствующие записи. Совпадающие идентификаторы, конфликты штрихкодов и кешированных продуктов будут пропущены. Порции добавятся только вместе с новыми продуктами.';

  @override
  String get backupSupplementAction => 'Дополнить локальные данные';

  @override
  String get backupReplaceDescription =>
      'Удалить все перечисленные выше локальные записи и загрузить данные из копии. Потребуется дополнительное подтверждение.';

  @override
  String get backupReplaceAction => 'Заменить локальные данные…';

  @override
  String get backupImportComplete => 'Копия импортирована';

  @override
  String backupImportResult(String imported, String skipped) {
    return 'Импортировано: $imported. Пропущено: $skipped.';
  }

  @override
  String get backupImportedRecords => 'Импортированные записи';

  @override
  String get backupSkippedRecords => 'Пропущенные записи';

  @override
  String get backupSkippedNote =>
      'Не импортированы существующие записи, конфликты штрихкодов и кешированных продуктов, а также порции пропущенных продуктов. Текущие записи сохранены без изменений.';

  @override
  String get backupWaitingForConfirmation => 'Ожидаем подтверждения';

  @override
  String get backupExporting => 'Подготавливаем копию…';

  @override
  String get backupSaving => 'Сохраняем копию…';

  @override
  String get backupOpening => 'Открываем копию…';

  @override
  String get backupInspecting => 'Проверяем копию…';

  @override
  String get backupImporting => 'Импортируем копию…';

  @override
  String get backupCountUserFoods => 'Свои продукты';

  @override
  String get backupCountUserServings => 'Порции продуктов';

  @override
  String get backupCountDiaryEntries => 'Записи дневника';

  @override
  String get backupCountGoals => 'Версии целей';

  @override
  String get backupCountWeights => 'Записи веса';

  @override
  String get backupCountRemoteFoods => 'Кешированные продукты';

  @override
  String get backupRestoreAction => 'Восстановить из копии';

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
