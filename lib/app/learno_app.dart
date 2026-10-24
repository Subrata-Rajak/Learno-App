import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/home/presentation/screens/home_screen.dart';

/// Root application widget for Learno.
///
/// Sets up the light-only Material 3 theme and presents the primary Home screen.
class LearnoApp extends StatelessWidget {
  const LearnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
