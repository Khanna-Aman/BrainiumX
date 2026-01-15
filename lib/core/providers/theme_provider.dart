import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_provider.dart';
import '../theme/app_theme.dart';

// Theme provider that uses the proper AppTheme with full dark mode support
final themeProvider = Provider<ThemeData>((ref) {
  final profile = ref.watch(userProfileProvider);
  final themePreference = profile?.preferredTheme ?? 'system';

  // Use the proper AppTheme with full dark mode support
  switch (themePreference) {
    case 'dark':
      return AppTheme.darkTheme;
    case 'system':
      // Detect system theme
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
    case 'light':
      return AppTheme.lightTheme;
    case 'default':
    default:
      // Default to system theme
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
  }
});

final isDarkModeProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.preferredTheme == 'dark';
});
