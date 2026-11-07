import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.proteinText,
    required this.fatText,
    required this.carbsText,
    required this.success,
    required this.warning,
    required this.goalWithin,
    required this.goalBelow,
    required this.goalAbove,
  });

  final Color protein;
  final Color fat;
  final Color carbs;
  final Color proteinText;
  final Color fatText;
  final Color carbsText;
  final Color success;
  final Color warning;
  final Color goalWithin;
  final Color goalBelow;
  final Color goalAbove;

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>()!;
  }

  @override
  AppSemanticColors copyWith({
    Color? protein,
    Color? fat,
    Color? carbs,
    Color? proteinText,
    Color? fatText,
    Color? carbsText,
    Color? success,
    Color? warning,
    Color? goalWithin,
    Color? goalBelow,
    Color? goalAbove,
  }) {
    return AppSemanticColors(
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      proteinText: proteinText ?? this.proteinText,
      fatText: fatText ?? this.fatText,
      carbsText: carbsText ?? this.carbsText,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      goalWithin: goalWithin ?? this.goalWithin,
      goalBelow: goalBelow ?? this.goalBelow,
      goalAbove: goalAbove ?? this.goalAbove,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      protein: Color.lerp(protein, other.protein, t)!,
      fat: Color.lerp(fat, other.fat, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      proteinText: Color.lerp(proteinText, other.proteinText, t)!,
      fatText: Color.lerp(fatText, other.fatText, t)!,
      carbsText: Color.lerp(carbsText, other.carbsText, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      goalWithin: Color.lerp(goalWithin, other.goalWithin, t)!,
      goalBelow: Color.lerp(goalBelow, other.goalBelow, t)!,
      goalAbove: Color.lerp(goalAbove, other.goalAbove, t)!,
    );
  }
}
