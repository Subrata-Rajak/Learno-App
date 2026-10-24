import 'package:flutter/material.dart';
import 'package:learno/core/theme/app_colors.dart';
import 'package:learno/core/theme/app_radii.dart';
import 'package:learno/core/theme/app_spacing.dart';
import 'package:learno/core/theme/app_typography.dart';

/// Central theme builder configuring Learno's light-only Material 3 visual system.
abstract final class AppTheme {
  /// The unified light theme for Learno.
  static ThemeData get lightTheme {
    final colorScheme = AppColors.lightColorScheme;
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.warmIvory,
      textTheme: textTheme,

      // --- App Bar Theme ---
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmIvory,
        foregroundColor: AppColors.deepInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: IconThemeData(color: AppColors.deepInk),
      ),

      // --- Card Theme ---
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderCard,
          side: BorderSide(color: AppColors.outlineLight, width: 1.0),
        ),
      ),

      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cobalt,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.outlineLight,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: AppColors.shadowCobalt,
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderButton,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cobalt,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.outlineLight,
          disabledForegroundColor: AppColors.textTertiary,
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderButton,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cobalt,
          side: const BorderSide(color: AppColors.cobalt, width: 1.5),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderButton,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.cobalt,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cobalt,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.cobalt,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Input Decoration Theme ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.borderInput,
          borderSide: BorderSide(color: AppColors.outline, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderInput,
          borderSide: BorderSide(color: AppColors.outline, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderInput,
          borderSide: BorderSide(color: AppColors.cobalt, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderInput,
          borderSide: BorderSide(color: AppColors.coral, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderInput,
          borderSide: BorderSide(color: AppColors.coral, width: 2.0),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.cobalt,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --- Navigation Bar (Material 3) ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.skyBlue,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.deepInk,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.deepInk, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),

      // --- Bottom Navigation Bar (Legacy/Alternative) ---
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.cobalt,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // --- Chip Theme ---
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.lavenderLight,
        secondarySelectedColor: AppColors.sunnyYellowLight,
        labelStyle: AppTypography.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderChip,
          side: BorderSide(color: AppColors.outlineLight, width: 1.0),
        ),
      ),

      // --- Floating Action Button ---
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cobalt,
        foregroundColor: AppColors.white,
        elevation: 3,
        hoverElevation: 4,
        focusElevation: 4,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      ),

      // --- Dialog Theme ---
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderDialog),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // --- Divider Theme ---
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineLight,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
