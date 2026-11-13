import 'package:flutter/material.dart';
import 'package:learno/app/learno_app.dart';
import 'package:learno/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const LearnoApp());
}

/// Alias for backward compatibility with initial template tests.
typedef MyApp = LearnoApp;
