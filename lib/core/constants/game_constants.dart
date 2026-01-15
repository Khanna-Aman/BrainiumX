class GameConstants {
  // Timing constants
  static const Duration sequenceDelay = Duration(milliseconds: 800);
  static const Duration briefPause = Duration(milliseconds: 500);
  static const Duration longPause = Duration(milliseconds: 1000);
  static const Duration resultDisplayDuration = Duration(milliseconds: 1500);
  static const Duration stimulusDisplayTime = Duration(milliseconds: 1000);
  static const Duration interTrialInterval = Duration(milliseconds: 500);
  static const Duration responseWindow = Duration(seconds: 3);
  static const Duration patternDisplayTime = Duration(seconds: 2);

  // Game configuration
  static const int maxRetries = 3;
  static const int defaultTimeLimit = 120;
  static const int minSequenceLength = 3;
  static const int maxSequenceLength = 8;
  static const int defaultTrialCount = 15;
  static const int defaultRoundCount = 5;
  static const int maxTrialCount = 50;

  // Visual constants
  static const double gridSpacing = 16.0;
  static const double cardPadding = 16.0;
  static const double iconSize = 48.0;
  static const int gridCrossAxisCount = 3;
  static const double buttonHeight = 56.0;
  static const double borderRadius = 12.0;

  // Performance constants
  static const int maxPoolSize = 100;
  static const int gridOptimizationThreshold = 50;
  static const int maxErrorLogSize = 100;
  static const int maxPerformanceMetrics = 1000;

  // Game-specific constants
  static const double targetProbability = 0.7; // For Go/No-Go games
  static const int defaultGridSize = 4; // For memory grid games
  static const int defaultNLevel = 1; // For N-Back games
  static const int maxArithmeticNumber = 100;
  static const int minArithmeticNumber = 1;

  // Accessibility constants
  static const Duration semanticAnnouncementDelay = Duration(milliseconds: 100);
  static const double minimumTouchTargetSize = 44.0;
}

/// Configuration for game timing to prevent hardcoded values
class GameTimingConfig {
  static const Duration patternDisplayTime = Duration(seconds: 2);
  static const Duration resultDisplayTime = Duration(seconds: 2);
  static const Duration autoAdvanceDelay = Duration(seconds: 2);
  static const Duration falseStartPenalty = Duration(milliseconds: 1000);
  static const Duration stimulusWaitTime = Duration(milliseconds: 1500);
  static const Duration responseTimeout = Duration(seconds: 5);

  // Memory grid specific
  static const Duration memoryGridPatternTime = Duration(seconds: 2);

  // Speed tap specific
  static const Duration speedTapMinWait = Duration(milliseconds: 1000);
  static const Duration speedTapMaxWait = Duration(milliseconds: 4000);

  // Trail connect specific
  static const Duration trailConnectTimeout = Duration(seconds: 30);
}

/// Safe math operations to prevent division by zero and overflow
class SafeMath {
  static double safeDivision(num numerator, num denominator,
      {double fallback = 0.0}) {
    if (denominator == 0 || denominator.isNaN || denominator.isInfinite) {
      return fallback;
    }
    final result = numerator / denominator;
    if (result.isNaN || result.isInfinite) {
      return fallback;
    }
    return result.toDouble();
  }

  static double safePercentage(num part, num total, {double fallback = 0.0}) {
    return safeDivision(part * 100, total, fallback: fallback);
  }

  static double safeAccuracy(int correct, int total, {double fallback = 0.0}) {
    return safeDivision(correct, total, fallback: fallback);
  }

  static int safeClamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
