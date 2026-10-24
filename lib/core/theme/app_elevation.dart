import 'package:flutter/material.dart';
import 'package:learno/core/theme/app_colors.dart';

/// Centralized elevation and soft shadow tokens for Learno.
///
/// Uses soft, layered diffusions rather than harsh drop-shadows to preserve
/// a light, friendly, and premium feel.
abstract final class AppElevation {
  /// Flat / zero shadow.
  static const List<BoxShadow> none = [];

  /// Gentle elevation for hover states or resting elevated cards.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 10,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  /// Standard card elevation.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Elevated floating controls (e.g. FAB, floating navigation, bottom sheets).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  /// Playful cobalt brand accent glow for primary callouts/buttons.
  static const List<BoxShadow> cobaltGlow = [
    BoxShadow(
      color: AppColors.shadowCobalt,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Playful coral accent glow for highlights or badges.
  static const List<BoxShadow> coralGlow = [
    BoxShadow(
      color: AppColors.shadowCoral,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Playful sunny yellow accent glow.
  static const List<BoxShadow> yellowGlow = [
    BoxShadow(
      color: AppColors.shadowYellow,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
