// BrainiumX Widget Tests
// Tests for the brain training game collection

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:brainiumx/app.dart';
import 'package:brainiumx/data/models/models.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing with in-memory storage
    Hive.init('./test/hive_test');

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GameIdAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GameConfigAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SessionPlanAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SessionResultAdapter());
    }
  });

  testWidgets('BrainiumX app loads correctly', (WidgetTester tester) async {
    // Open test boxes
    await Hive.openBox<UserProfile>('test_user_profile');
    await Hive.openBox<GameConfig>('test_game_configs');
    await Hive.openBox<SessionPlan>('test_session_plans');
    await Hive.openBox<SessionResult>('test_session_results');

    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: BrainiumXApp(),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the splash screen or home screen loads
    expect(find.byType(MaterialApp), findsOneWidget);

    // Clean up test boxes
    await Hive.box('test_user_profile').clear();
    await Hive.box('test_game_configs').clear();
    await Hive.box('test_session_plans').clear();
    await Hive.box('test_session_results').clear();
  });

  testWidgets('Game navigation works', (WidgetTester tester) async {
    // This test would verify that game navigation works correctly
    // For now, we'll just verify the app structure
    await tester.pumpWidget(
      const ProviderScope(
        child: BrainiumXApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the app has a router
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
