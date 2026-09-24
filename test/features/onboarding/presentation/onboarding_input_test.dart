import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/onboarding/presentation/onboarding_input.dart';

void main() {
  test('macro energy uses 4/9/4 and never overwrites the calorie goal', () {
    final input = OnboardingInput(
      goal: WeightGoal.lose,
      currentWeight: '74,2',
      targetWeight: '72',
      calories: '1950',
      protein: '140',
      fat: '65',
      carbs: '210',
    );

    expect(input.caloriesFromMacros, 1985);
    expect(input.macroCalorieDifference, 35);
    expect(input.profile?.calorieTarget, 1950);
    expect(input.profile?.currentWeightKg, 74.2);
  });

  test('the energy preview stays absent while a value is invalid', () {
    final input = OnboardingInput(
      goal: WeightGoal.maintain,
      currentWeight: '74',
      targetWeight: '74',
      calories: '1950',
      protein: '',
      fat: '65',
      carbs: '210',
    );

    expect(input.caloriesFromMacros, isNull);
    expect(input.macroCalorieDifference, isNull);
    expect(input.profile, isNull);
  });
}
