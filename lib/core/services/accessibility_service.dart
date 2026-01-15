import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityService {
  static bool _highContrastMode = false;
  static double _textScaleFactor = 1.0;
  static bool _reduceAnimations = false;
  static bool _screenReaderEnabled = false;

  static bool get highContrastMode => _highContrastMode;
  static double get textScaleFactor => _textScaleFactor;
  static bool get reduceAnimations => _reduceAnimations;
  static bool get screenReaderEnabled => _screenReaderEnabled;

  static void setHighContrastMode(bool enabled) {
    _highContrastMode = enabled;
  }

  static void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.8, 2.0);
  }

  static void setReduceAnimations(bool enabled) {
    _reduceAnimations = enabled;
  }

  static void setScreenReaderEnabled(bool enabled) {
    _screenReaderEnabled = enabled;
  }

  static ThemeData applyAccessibilityTheme(ThemeData baseTheme) {
    if (!_highContrastMode) return baseTheme;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red[900]!,
        onError: Colors.white,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  static Duration getAnimationDuration(Duration defaultDuration) {
    if (_reduceAnimations) {
      return Duration(
          milliseconds: (defaultDuration.inMilliseconds * 0.3).round());
    }
    return defaultDuration;
  }

  static Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? tooltip,
    bool isDestructive = false,
  }) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.red[700] : null,
        foregroundColor: isDestructive ? Colors.white : null,
        minimumSize: const Size(48, 48), // Minimum touch target
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: button,
    );
  }

  static Widget buildAccessibleCard({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    bool isSelected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: isSelected,
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected && _highContrastMode ? Colors.grey[200] : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  static void announceForScreenReader(String message) {
    if (_screenReaderEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  static Widget buildGameInstructions({
    required String title,
    required List<String> instructions,
    required VoidCallback onStart,
  }) {
    return Semantics(
      container: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            readOnly: true,
            child: Column(
              children: instructions
                  .map((instruction) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          instruction,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          buildAccessibleButton(
            onPressed: onStart,
            semanticLabel: 'Start $title game',
            tooltip: 'Begin playing the game',
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  static Widget buildGameHUD({
    required String gameTitle,
    required Map<String, String> stats,
  }) {
    return Semantics(
      container: true,
      label: 'Game statistics for $gameTitle',
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.entries
              .map((entry) => Semantics(
                    label: '${entry.key}: ${entry.value}',
                    readOnly: true,
                    child: Column(
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  static Widget buildGameResults({
    required String gameTitle,
    required Map<String, String> results,
    required VoidCallback onContinue,
  }) {
    return Semantics(
      container: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Game Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Game results for $gameTitle',
            readOnly: true,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: results.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key),
                                Text(
                                  entry.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          buildAccessibleButton(
            onPressed: onContinue,
            semanticLabel: 'Continue to next activity',
            tooltip: 'Return to the main screen',
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  static void initializeAccessibility() {
    // Check system accessibility settings
    final window = WidgetsBinding.instance.platformDispatcher;
    _textScaleFactor = window.textScaleFactor;
    _reduceAnimations = window.accessibilityFeatures.reduceMotion;
    _screenReaderEnabled = window.accessibilityFeatures.accessibleNavigation;
  }
}
