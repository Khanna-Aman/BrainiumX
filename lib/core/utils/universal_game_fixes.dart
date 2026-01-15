// Universal fixes for all games to address critical Play Store issues
// This file contains patterns to fix memory leaks, timer issues, and crashes

import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class UniversalGameFixes {
  // Fix 1: Safe timer creation that prevents setState after dispose
  static Timer createSafeTimer(
    Duration duration,
    VoidCallback callback, {
    required bool Function() mounted,
    required bool Function() disposed,
  }) {
    return Timer(duration, () {
      if (mounted() && !disposed()) {
        try {
          callback();
        } catch (error, stackTrace) {
          debugPrint('Safe timer error: $error\n$stackTrace');
        }
      }
    });
  }

  // Fix 2: Safe periodic timer with automatic cleanup
  static Timer createSafePeriodicTimer(
    Duration duration,
    void Function(Timer) callback, {
    required bool Function() mounted,
    required bool Function() disposed,
    required bool Function() paused,
  }) {
    late Timer timer;
    timer = Timer.periodic(duration, (t) {
      if (!mounted() || disposed()) {
        t.cancel();
        return;
      }

      if (!paused()) {
        try {
          callback(t);
        } catch (error, stackTrace) {
          debugPrint('Safe periodic timer error: $error\n$stackTrace');
          t.cancel();
        }
      }
    });
    return timer;
  }

  // Fix 3: Safe setState wrapper
  static void safeSetState(
    VoidCallback callback, {
    required bool Function() mounted,
  }) {
    if (mounted()) {
      try {
        callback();
      } catch (error, stackTrace) {
        debugPrint('Safe setState error: $error\n$stackTrace');
      }
    }
  }

  // Fix 4: Universal timer cleanup
  static void cleanupTimers(List<Timer?> timers) {
    for (final timer in timers) {
      try {
        timer?.cancel();
      } catch (error) {
        debugPrint('Timer cleanup error: $error');
      }
    }
  }

  // Fix 5: Safe async operation wrapper
  static Future<void> safeAsyncOperation(
    Future<void> Function() operation, {
    required bool Function() mounted,
    String? operationName,
  }) async {
    try {
      if (mounted()) {
        await operation();
      }
    } catch (error, stackTrace) {
      debugPrint(
          'Safe async operation error ${operationName ?? ''}: $error\n$stackTrace');
    }
  }

  // Fix 6: Memory leak prevention for lists
  static void clearAndReleaseLists(Map<String, List<dynamic>> lists) {
    for (final entry in lists.entries) {
      try {
        entry.value.clear();
      } catch (error) {
        debugPrint('List cleanup error for ${entry.key}: $error');
      }
    }
  }

  // Fix 7: Safe widget building with error boundaries
  static Widget buildSafeWidget(
    Widget Function() builder, {
    Widget? fallback,
    String? widgetName,
  }) {
    try {
      return builder();
    } catch (error, stackTrace) {
      debugPrint('Widget build error ${widgetName ?? ''}: $error\n$stackTrace');
      return fallback ?? const SizedBox.shrink();
    }
  }

  // Fix 8: Universal error handling for game operations
  static T? safeGameOperation<T>(
    T Function() operation, {
    String? operationName,
    T? fallback,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      debugPrint(
          'Game operation error ${operationName ?? ''}: $error\n$stackTrace');
      return fallback;
    }
  }

  // Fix 9: Safe navigation with mounted checks
  static void safeNavigate(
    BuildContext context,
    VoidCallback navigation, {
    required bool Function() mounted,
  }) {
    if (mounted() && context.mounted) {
      try {
        navigation();
      } catch (error, stackTrace) {
        debugPrint('Navigation error: $error\n$stackTrace');
      }
    }
  }

  // Fix 10: Placeholder for removed haptic feedback
  static void safeHapticFeedback() {
    // Haptic feedback has been removed from the app
  }

  // Fix 11: Safe score calculation
  static double calculateSafeAccuracy(
    List<bool> responses,
    List<bool> correctAnswers,
  ) {
    try {
      if (responses.isEmpty || correctAnswers.isEmpty) return 0.0;

      final minLength = responses.length < correctAnswers.length
          ? responses.length
          : correctAnswers.length;

      int correct = 0;
      for (int i = 0; i < minLength; i++) {
        if (responses[i] == correctAnswers[i]) {
          correct++;
        }
      }

      return correct / minLength;
    } catch (error) {
      debugPrint('Accuracy calculation error: $error');
      return 0.0;
    }
  }

  // Fix 12: Safe resource disposal
  static void safeDispose(List<void Function()> disposers) {
    for (final dispose in disposers) {
      try {
        dispose();
      } catch (error) {
        debugPrint('Resource disposal error: $error');
      }
    }
  }

  // Fix 13: Universal constants for timing
  static const Duration safeStimulusTime = GameConstants.stimulusDisplayTime;
  static const Duration safeResponseTime = GameConstants.responseWindow;
  static const Duration safeInterTrialTime = GameConstants.interTrialInterval;
  static const Duration safeBriefPause = GameConstants.briefPause;

  // Fix 14: Safe game state transitions
  static void safeStateTransition(
    VoidCallback transition, {
    required bool Function() canTransition,
    String? transitionName,
  }) {
    if (canTransition()) {
      try {
        transition();
      } catch (error, stackTrace) {
        debugPrint(
            'State transition error ${transitionName ?? ''}: $error\n$stackTrace');
      }
    }
  }

  // Fix 15: Universal error recovery
  static void handleGameError(
    Object error,
    StackTrace stackTrace, {
    VoidCallback? onError,
    String? context,
  }) {
    debugPrint(
        'Game error in ${context ?? 'unknown context'}: $error\n$stackTrace');

    try {
      onError?.call();
    } catch (recoveryError) {
      debugPrint('Error recovery failed: $recoveryError');
    }
  }
}
