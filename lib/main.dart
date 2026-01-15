import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/models.dart';
import 'core/services/error_service.dart';
import 'core/services/performance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  setupGlobalErrorHandling();

  // Initialize services
  PerformanceService.startTimer('app_initialization');

  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(GameIdAdapter());
    Hive.registerAdapter(GameConfigAdapter());
    Hive.registerAdapter(SessionPlanAdapter());
    Hive.registerAdapter(SessionResultAdapter());

    // Open Hive boxes
    await Hive.openBox<UserProfile>('user_profile');
    await Hive.openBox<GameConfig>('game_configs');
    await Hive.openBox<SessionPlan>('session_plans');
    await Hive.openBox<SessionResult>('session_results');

    PerformanceService.stopTimer('app_initialization');

    runApp(
      const ProviderScope(
        child: BrainiumXApp(),
      ),
    );
  } catch (error, stackTrace) {
    ErrorService.logError(
      error,
      stackTrace,
      context: 'App Initialization',
    );

    // Still try to run the app with error state
    runApp(
      const ProviderScope(
        child: BrainiumXApp(),
      ),
    );
  }
}
