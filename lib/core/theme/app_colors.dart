import 'package:flutter/material.dart';

/// Centralized color palette and semantic tokens for Learno.
///
/// Designed to feel expressive, curious, playful, and premium.
abstract final class AppColors {
  // --- Raw Brand Palette ---
  static const Color cobalt = Color(0xFF465BFF);
  static const Color deepInk = Color(0xFF171A35);
  static const Color warmIvory = Color(0xFFFFF9F0);
  static const Color coral = Color(0xFFFF786B);
  static const Color sunnyYellow = Color(0xFFFFD166);
  static const Color lavender = Color(0xFFC9B8FF);
  static const Color skyBlue = Color(0xFFBDE7FF);
  static const Color white = Color(0xFFFFFFFF);

  // --- Supporting Tonal Variations ---
  static const Color cobaltLight = Color(0xFF6E7FFF);
  static const Color cobaltDark = Color(0xFF2C3ED6);
  static const Color lavenderLight = Color(0xFFEDE5FF);
  static const Color skyBlueLight = Color(0xFFE5F5FF);
  static const Color coralLight = Color(0xFFFFB2A9);
  static const Color sunnyYellowLight = Color(0xFFFFE8A3);
  static const Color warmIvoryDark = Color(0xFFF3ECE0);

  // --- Semantic & Surface Mappings ---
  static const Color background = warmIvory;
  static const Color surface = white;
  static const Color surfaceMuted = warmIvoryDark;

  // --- Typography Colors ---
  static const Color textPrimary = deepInk;
  static const Color textSecondary = Color(0xFF535777);
  static const Color textTertiary = Color(0xFF868BAA);
  static const Color textInverse = white;

  // --- Borders & Outlines ---
  static const Color outline = Color(0x1F171A35); // 12% deep ink
  static const Color outlineLight = Color(0x0F171A35); // 6% deep ink
  static const Color outlineStrong = Color(0x3D171A35); // 24% deep ink

  // --- Shadow Colors ---
  static const Color shadow = Color(0x14171A35); // 8% deep ink
  static const Color shadowCobalt = Color(0x3D465BFF); // 24% cobalt
  static const Color shadowCoral = Color(0x3DFF786B); // 24% coral
  static const Color shadowYellow = Color(0x3DFFD166); // 24% yellow

  /// Light Material 3 ColorScheme mapped to Learno's curated brand colors.
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: cobalt,
    onPrimary: white,
    primaryContainer: skyBlue,
    onPrimaryContainer: deepInk,
    secondary: lavender,
    onSecondary: deepInk,
    secondaryContainer: lavenderLight,
    onSecondaryContainer: deepInk,
    tertiary: coral,
    onTertiary: white,
    tertiaryContainer: sunnyYellow,
    onTertiaryContainer: deepInk,
    error: coral,
    onError: white,
    surface: white,
    onSurface: deepInk,
    surfaceContainerHighest: warmIvoryDark,
    onSurfaceVariant: textSecondary,
    outline: outline,
    outlineVariant: outlineLight,
    shadow: shadow,
  );
}
