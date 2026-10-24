import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Root application widget for Learno.
///
/// Sets up light-only Material 3 theme and app-level configuration.
class LearnoApp extends StatelessWidget {
  const LearnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _DesignSystemPlaceholder(),
    );
  }
}

/// A minimal placeholder widget confirming theme initialization.
///
/// The full Home screen experience will be implemented in a subsequent checkpoint.
class _DesignSystemPlaceholder extends StatelessWidget {
  const _DesignSystemPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Learno')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.cobalt,
                    borderRadius: AppRadii.borderCard,
                    boxShadow: AppElevation.cobaltGlow,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Learno Design System',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'AI-powered learning companion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
