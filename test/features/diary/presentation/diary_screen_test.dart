import 'dart:ui' show Tristate;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows an empty current day and empty adjacent day', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('ru'), today: DateTime(2026, 9, 23)),
    );

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Завтрак'), findsOneWidget);
    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(find.text('Пока ничего нет'), findsWidgets);
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    final summaryTop = tester.getTopLeft(find.text('Съедено')).dy;

    await tester.tap(find.byTooltip('Предыдущий день'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(find.text('Пока ничего нет'), findsWidgets);
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    expect(tester.getTopLeft(find.text('Съедено')).dy, summaryTop);

    await tester.tap(find.byTooltip('Вернуться к сегодняшнему дню'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(tester.getTopLeft(find.text('Съедено')).dy, summaryTop);
  });

  testWidgets('today remains reachable outside the selected week', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    for (var index = 0; index < 7; index++) {
      await tester.tap(find.byTooltip('Previous day'));
      await tester.pump();
    }

    expect(find.byKey(const ValueKey('diary-today-marker')), findsNothing);
    await tester.tap(find.byTooltip('Return to today'));
    await tester.pump();
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    expect(find.text('Boiled eggs'), findsNothing);
  });

  testWidgets('calendar reacts to entry edits, delete, Undo and goal changes', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(1280, 900));
    final semantics = tester.ensureSemantics();
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final diary = DiaryRepository(database);
    final statistics = StatisticsRepository(database);
    final day = DateTime(2020, 12, 31);
    await statistics.saveOnboarding(_calendarProfile(1000), day);
    await tester.pumpWidget(
      _DiaryTestApp(
        locale: const Locale('en'),
        today: day,
        repository: diary,
        statisticsRepository: statistics,
      ),
    );
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'No entry', today: true);

    await diary.create(_calendarDraft(day, 800));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'Below', today: true);
    await tester.tap(find.text('Calendar food'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('diary-edit-quantity')),
      '900',
    );
    await tester.tap(find.byKey(const ValueKey('diary-edit-save')));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'In goal', today: true);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'Below', today: true);

    await tester.tap(find.text('Calendar food'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('diary-edit-quantity')),
      '1100.000001',
    );
    await tester.tap(find.byKey(const ValueKey('diary-edit-save')));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'Above', today: true);
    await tester.tap(find.text('Calendar food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('diary-edit-delete')));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'No entry', today: true);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'Above', today: true);

    await statistics.saveOnboarding(_calendarProfile(2000), day);
    await tester.pumpAndSettle();
    _expectSelectedDay(tester, day, 'Below', today: true);
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    semantics.dispose();
  });

  testWidgets(
    'calendar navigates year boundaries with historical day statuses',
    (tester) async {
      await _setWindowSize(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final diary = DiaryRepository(database);
      final statistics = StatisticsRepository(database);
      final today = DateTime(2020, 12, 31);
      final noGoalDay = DateTime(2020, 12, 28);
      final nextWeek = DateTime(2021, 1, 4);
      await statistics.saveOnboarding(
        _calendarProfile(1000),
        DateTime(2020, 12, 29),
      );
      await statistics.saveOnboarding(
        _calendarProfile(2000),
        DateTime(2021, 1, 1),
      );
      for (final (day, kcal) in [
        (noGoalDay, 50.0),
        (DateTime(2020, 12, 29), 899.999999),
        (DateTime(2020, 12, 30), 900.0),
        (today, 1100.0),
        (DateTime(2021, 1, 1), 2200.0),
        (DateTime(2021, 1, 2), 2200.000001),
        (nextWeek, 2000.0),
      ]) {
        await diary.create(_calendarDraft(day, kcal));
      }
      final router = createAppRouter(
        appVersion: '1.2.3+4',
        diaryToday: today,
        diaryRepository: diary,
        statisticsRepository: statistics,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _DiaryRouterTestApp(router: router, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, today, 'In goal', today: true);
      expect(_calendarDay(noGoalDay, 'No goal set'), findsOneWidget);
      expect(_calendarDay(DateTime(2020, 12, 29), 'Below'), findsOneWidget);
      expect(_calendarDay(DateTime(2020, 12, 30), 'In goal'), findsOneWidget);
      expect(_calendarDay(DateTime(2021, 1, 1), 'In goal'), findsOneWidget);
      expect(_calendarDay(DateTime(2021, 1, 2), 'Above'), findsOneWidget);
      expect(_calendarDay(DateTime(2021, 1, 3), 'No entry'), findsOneWidget);

      await tester.tap(_calendarDay(noGoalDay, 'No goal set'));
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, noGoalDay, 'No goal set');
      expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
      await diary.create(_calendarDraft(DateTime(2021, 1, 3), 1800));
      await tester.pumpAndSettle();
      expect(_calendarDay(DateTime(2021, 1, 3), 'In goal'), findsOneWidget);
      _expectSelectedDay(tester, noGoalDay, 'No goal set');

      await tester.tap(_calendarDay(DateTime(2021, 1, 3), 'In goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next day'));
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, nextWeek, 'In goal');
      expect(find.byKey(const ValueKey('diary-today-marker')), findsNothing);
      expect(_calendarDay(DateTime(2021, 1, 5), 'No entry'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous day'));
      await tester.pump();
      await tester.tap(find.byTooltip('Next day'));
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, nextWeek, 'In goal');

      await tester.tap(find.byTooltip('Previous day'));
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, DateTime(2021, 1, 3), 'In goal');
      expect(_calendarDay(noGoalDay, 'No goal set'), findsOneWidget);
      await tester.tap(find.byTooltip('Return to today'));
      await tester.pumpAndSettle();
      _expectSelectedDay(tester, today, 'In goal', today: true);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      semantics.dispose();
    },
  );

  testWidgets('diary restores the native Android stretch overscroll', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
  });

  testWidgets('floating add does not cover the last meal at the bottom', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    await tester.drag(
      find.byKey(const ValueKey('diary-scroll-view')),
      const Offset(0, -4000),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(const ValueKey('snacks'))).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const ValueKey('diary-add-food'))).top,
      ),
    );
  });

  testWidgets('add food action opens a task screen above navigation', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter(appVersion: '1.2.3+4');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _DiaryRouterTestApp(router: router, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('diary-add-food')), findsOneWidget);
    await tester.tap(find.byTooltip('Добавить еду в раздел «Завтрак»'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Приём: Завтрак'), findsOneWidget);
    expect(find.text('Недавние'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('floating add opens food search without a preselected meal', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter(
      appVersion: '1.2.3+4',
      diaryToday: DateTime(2026, 9, 23),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _DiaryRouterTestApp(router: router, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('diary-add-food')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Выбрать приём пищи'), findsOneWidget);
    expect(find.text('Недавние'), findsOneWidget);
  });

  testWidgets('supports large text without overflow', (tester) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _DiaryTestApp(
        locale: Locale('en'),
        textScaler: TextScaler.linear(2),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Breakfast'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('diary-scroll-view')),
        matching: find.byType(Scrollable),
      ),
    );

    expect(find.text('Breakfast'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the wide approved hierarchy in dark theme', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(1280, 900));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), theme: AppTheme.dark),
    );

    expect(find.text('YAM'), findsOneWidget);
    expect(find.text('Consumed'), findsOneWidget);
    expect(find.text('Buckwheat porridge'), findsNothing);
    expect(find.text('Water'), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final layout in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('meal headers have no placeholder times at $layout', (
      tester,
    ) async {
      await _setWindowSize(tester, layout);
      await tester.pumpWidget(const _DiaryTestApp(locale: Locale('en')));
      await tester.dragUntilVisible(
        find.text('Snacks'),
        find.byKey(const ValueKey('diary-scroll-view')),
        const Offset(0, -200),
      );
      expect(find.text('Snacks'), findsOneWidget);
      for (final time in ['8:30', '13:15', '19:20', '16:40']) {
        expect(find.text(time), findsNothing);
      }
    });
  }

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('calendar uses YAM surfaces in ${theme.brightness}', (
      tester,
    ) async {
      await _setWindowSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _DiaryTestApp(
          locale: const Locale('en'),
          today: DateTime(2026, 9, 23),
          theme: theme,
        ),
      );

      await tester.tap(
        find
            .ancestor(of: find.text('Today'), matching: find.byType(InkWell))
            .first,
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(DatePickerDialog));
      final picker = DatePickerTheme.of(context);
      expect(picker.backgroundColor, theme.colorScheme.surface);
      expect(picker.headerBackgroundColor, theme.colorScheme.surfaceContainer);
      expect(picker.headerForegroundColor, theme.colorScheme.onSurface);
      expect(picker.todayBorder?.color, theme.colorScheme.primary);
      expect(find.text('23'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected today stays legible in ${theme.brightness}', (
      tester,
    ) async {
      await _setWindowSize(tester, const Size(390, 844));
      final today = DateTime.now();
      await tester.pumpWidget(
        _DiaryTestApp(locale: const Locale('en'), today: today, theme: theme),
      );

      await tester.tap(
        find
            .ancestor(of: find.text('Today'), matching: find.byType(InkWell))
            .first,
      );
      await tester.pumpAndSettle();

      final selectedToday = find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.text('${today.day}'),
      );
      expect(selectedToday, findsOneWidget);
      expect(
        tester.widget<Text>(selectedToday).style?.color,
        theme.colorScheme.onPrimary,
      );
    });
  }
}

class _DiaryRouterTestApp extends StatelessWidget {
  const _DiaryRouterTestApp({required this.router, required this.locale});

  final GoRouter router;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      theme: AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class _DiaryTestApp extends StatelessWidget {
  const _DiaryTestApp({
    required this.locale,
    this.today,
    this.textScaler,
    this.theme,
    this.repository,
    this.statisticsRepository,
  });

  final Locale locale;
  final DateTime? today;
  final TextScaler? textScaler;
  final ThemeData? theme;
  final DiaryRepository? repository;
  final StatisticsRepository? statisticsRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final textScaler = this.textScaler;
        if (textScaler == null) {
          return child!;
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        );
      },
      home: DiaryScreen(
        today: today,
        repository: repository,
        statisticsRepository: statisticsRepository,
      ),
    );
  }
}

Future<void> _setWindowSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Finder _calendarDay(DateTime day, String status, {bool today = false}) =>
    find.bySemanticsLabel(
      [
        DateFormat.yMMMMEEEEd('en').format(day),
        if (today) 'Today',
        status,
      ].join(', '),
    );

void _expectSelectedDay(
  WidgetTester tester,
  DateTime day,
  String status, {
  bool today = false,
}) {
  final finder = _calendarDay(day, status, today: today);
  expect(finder, findsOneWidget);
  expect(
    tester.getSemantics(finder).flagsCollection.isSelected,
    Tristate.isTrue,
  );
}

SessionProfile _calendarProfile(int kcal) => SessionProfile(
  goal: WeightGoal.maintain,
  currentWeightKg: 75,
  targetWeightKg: 75,
  calorieTarget: kcal,
  proteinTarget: 100,
  fatTarget: 50,
  carbsTarget: 250,
);

DiaryEntryDraft _calendarDraft(DateTime day, double kcal) => DiaryEntryDraft(
  day: day,
  mealId: 'breakfast',
  food: const DiaryFoodSnapshot(
    foodId: 'calendar-food',
    name: 'Calendar food',
    baseUnit: DiaryBaseUnit.grams,
    basisAmount: 1,
    nutritionPerBasis: DiaryNutrition(kcal: 1, protein: 0, fat: 0, carbs: 0),
    servings: [DiaryServingSnapshot(id: 'g', unit: 'grams', baseAmount: 1)],
  ),
  servingId: 'g',
  amount: kcal,
  canonicalQuantity: kcal,
);
