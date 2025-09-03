class DifficultyLevel {
  final String name;
  final String description;
  final double minRating;
  final double maxRating;
  
  const DifficultyLevel({
    required this.name,
    required this.description,
    required this.minRating,
    required this.maxRating,
  });
}

class DifficultyManager {
  static const List<DifficultyLevel> levels = [
    DifficultyLevel(
      name: 'Very Easy',
      description: 'Perfect for beginners - shorter games with simpler challenges',
      minRating: 0,
      maxRating: 999,
    ),
    DifficultyLevel(
      name: 'Easy',
      description: 'Gentle introduction with manageable complexity',
      minRating: 1000,
      maxRating: 1199,
    ),
    DifficultyLevel(
      name: 'Medium',
      description: 'Standard difficulty for regular practice',
      minRating: 1200,
      maxRating: 1499,
    ),
    DifficultyLevel(
      name: 'Hard',
      description: 'Challenging games for advanced players',
      minRating: 1500,
      maxRating: 2200,
    ),
  ];

  static DifficultyLevel getDifficultyLevel(double rating) {
    for (final level in levels) {
      if (rating >= level.minRating && rating <= level.maxRating) {
        return level;
      }
    }
    return levels.first; // Default to Very Easy
  }

  static String getDifficultyName(double rating) {
    return getDifficultyLevel(rating).name;
  }

  // Memory Grid difficulty configuration
  static MemoryGridConfig getMemoryGridConfig(double rating) {
    if (rating < 1000) {
      return const MemoryGridConfig(
        totalRounds: 3,
        timeLimit: 60,
        gridSize: 3,
        startingTargets: 2,
        maxTargets: 3,
      );
    } else if (rating < 1200) {
      return const MemoryGridConfig(
        totalRounds: 5,
        timeLimit: 90,
        gridSize: 4,
        startingTargets: 2,
        maxTargets: 4,
      );
    } else if (rating < 1500) {
      return const MemoryGridConfig(
        totalRounds: 8,
        timeLimit: 120,
        gridSize: 4,
        startingTargets: 2,
        maxTargets: 5,
      );
    } else {
      return const MemoryGridConfig(
        totalRounds: 12,
        timeLimit: 150,
        gridSize: 5,
        startingTargets: 3,
        maxTargets: 7,
      );
    }
  }

  // Speed Tap difficulty configuration
  static SpeedTapConfig getSpeedTapConfig(double rating) {
    if (rating < 1000) {
      return const SpeedTapConfig(
        totalTrials: 5,
        timeLimit: 60,
        minWaitTime: 2000,
        maxWaitTime: 5000,
      );
    } else if (rating < 1200) {
      return const SpeedTapConfig(
        totalTrials: 8,
        timeLimit: 90,
        minWaitTime: 1500,
        maxWaitTime: 4000,
      );
    } else if (rating < 1500) {
      return const SpeedTapConfig(
        totalTrials: 10,
        timeLimit: 120,
        minWaitTime: 1000,
        maxWaitTime: 3000,
      );
    } else {
      return const SpeedTapConfig(
        totalTrials: 15,
        timeLimit: 150,
        minWaitTime: 500,
        maxWaitTime: 2500,
      );
    }
  }

  // N-Back difficulty configuration
  static NBackConfig getNBackConfig(double rating) {
    if (rating < 1000) {
      return const NBackConfig(
        totalTicks: 20,
        timeLimit: 60,
        nLevel: 1,
        stimulusDuration: 2000,
      );
    } else if (rating < 1200) {
      return const NBackConfig(
        totalTicks: 30,
        timeLimit: 90,
        nLevel: 2,
        stimulusDuration: 1500,
      );
    } else if (rating < 1500) {
      return const NBackConfig(
        totalTicks: 40,
        timeLimit: 120,
        nLevel: 2,
        stimulusDuration: 1000,
      );
    } else {
      return const NBackConfig(
        totalTicks: 50,
        timeLimit: 150,
        nLevel: 3,
        stimulusDuration: 800,
      );
    }
  }

  // Arithmetic Sprint difficulty configuration
  static ArithmeticConfig getArithmeticConfig(double rating) {
    if (rating < 1000) {
      return const ArithmeticConfig(
        totalQuestions: 10,
        timeLimit: 90,
        maxNumber: 10,
        operations: ['+', '-'],
      );
    } else if (rating < 1200) {
      return const ArithmeticConfig(
        totalQuestions: 15,
        timeLimit: 120,
        maxNumber: 20,
        operations: ['+', '-', '×'],
      );
    } else if (rating < 1500) {
      return const ArithmeticConfig(
        totalQuestions: 20,
        timeLimit: 150,
        maxNumber: 50,
        operations: ['+', '-', '×'],
      );
    } else {
      return const ArithmeticConfig(
        totalQuestions: 25,
        timeLimit: 180,
        maxNumber: 100,
        operations: ['+', '-', '×', '÷'],
      );
    }
  }
}

// Configuration classes for each game type
class MemoryGridConfig {
  final int totalRounds;
  final int timeLimit;
  final int gridSize;
  final int startingTargets;
  final int maxTargets;

  const MemoryGridConfig({
    required this.totalRounds,
    required this.timeLimit,
    required this.gridSize,
    required this.startingTargets,
    required this.maxTargets,
  });
}

class SpeedTapConfig {
  final int totalTrials;
  final int timeLimit;
  final int minWaitTime;
  final int maxWaitTime;

  const SpeedTapConfig({
    required this.totalTrials,
    required this.timeLimit,
    required this.minWaitTime,
    required this.maxWaitTime,
  });
}

class NBackConfig {
  final int totalTicks;
  final int timeLimit;
  final int nLevel;
  final int stimulusDuration;

  const NBackConfig({
    required this.totalTicks,
    required this.timeLimit,
    required this.nLevel,
    required this.stimulusDuration,
  });
}

class ArithmeticConfig {
  final int totalQuestions;
  final int timeLimit;
  final int maxNumber;
  final List<String> operations;

  const ArithmeticConfig({
    required this.totalQuestions,
    required this.timeLimit,
    required this.maxNumber,
    required this.operations,
  });
}
