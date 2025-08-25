import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_profile_provider.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final profile = ref.watch(userProfileProvider);
  final isDark = profile?.preferredTheme == 'dark';
  
  final colorScheme = isDark 
    ? ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      )
    : ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
});

final isDarkModeProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.preferredTheme == 'dark';
});
