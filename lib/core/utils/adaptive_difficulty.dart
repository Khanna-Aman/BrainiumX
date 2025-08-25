import 'dart:math';
import '../../data/models/models.dart';

class AdaptiveDifficulty {
  static const double _targetAccuracy = 0.75; // Target 75% accuracy
  static const double _learningRate = 0.1;
  static const double _minRating = 800.0;
  static const double _maxRating = 2000.0;
  
  /// Calculate new difficulty rating based on performance
  static double updateDifficulty({
    required double currentRating,
    required double accuracy,
    required double? reactionTime,
    required GameId gameId,
  }) {
    // Base adjustment based on accuracy
    double adjustment = (accuracy - _targetAccuracy) * 200;
    
    // Game-specific adjustments
    adjustment *= _getGameDifficultyMultiplier(gameId);
    
    // Reaction time bonus for speed-based games
    if (reactionTime != null && _isSpeedGame(gameId)) {
      final reactionBonus = _calculateReactionTimeBonus(reactionTime, gameId);
      adjustment += reactionBonus;
    }
    
    // Apply learning rate
    adjustment *= _learningRate;
    
    // Calculate new rating
    final newRating = currentRating + adjustment;
    
    // Clamp to valid range
    return newRating.clamp(_minRating, _maxRating);
  }
  
  /// Get game-specific parameters based on difficulty rating
  static Map<String, dynamic> getGameParameters(GameId gameId, double rating) {
    final normalizedRating = (rating - 1200) / 400; // -1 to 1 range
    
    switch (gameId) {
      case GameId.speedTap:
        return {
          'trials': (10 + (normalizedRating * 5)).round().clamp(8, 15),
          'minDelay': (1000 - (normalizedRating * 500)).clamp(500, 1500),
          'maxDelay': (4000 - (normalizedRating * 1000)).clamp(2000, 5000),
        };
        
      case GameId.stroopMatch:
        return {
          'trials': (15 + (normalizedRating * 5)).round().clamp(10, 20),
          'timeLimit': (90 - (normalizedRating * 30)).clamp(60, 120),
        };
        
      case GameId.nBack:
        return {
          'nLevel': (2 + (normalizedRating * 1.5)).round().clamp(1, 4),
          'trials': (30 + (normalizedRating * 10)).round().clamp(20, 40),
          'stimulusDuration': (500 - (normalizedRating * 200)).clamp(300, 700),
        };
        
      case GameId.memoryGrid:
        return {
          'gridSize': (4 + (normalizedRating * 1)).round().clamp(3, 6),
          'rounds': (8 + (normalizedRating * 4)).round().clamp(6, 12),
          'displayTime': (2000 - (normalizedRating * 500)).clamp(1000, 2500),
          'itemsPerRound': (3 + (normalizedRating * 2)).round().clamp(2, 6),
        };
        
      case GameId.spatialRotation:
        return {
          'trials': (15 + (normalizedRating * 5)).round().clamp(10, 20),
          'complexity': (normalizedRating + 1) / 2, // 0 to 1
          'timeLimit': (120 - (normalizedRating * 30)).clamp(90, 150),
        };
        
      case GameId.trailConnect:
        return {
          'boards': (5 + (normalizedRating * 2)).round().clamp(3, 8),
          'nodesPerBoard': (8 + (normalizedRating * 4)).round().clamp(6, 15),
          'timeLimit': (150 - (normalizedRating * 30)).clamp(120, 180),
        };
        
      case GameId.goNoGo:
        return {
          'trials': (50 + (normalizedRating * 20)).round().clamp(30, 70),
          'targetRatio': (0.7 - (normalizedRating * 0.1)).clamp(0.5, 0.8),
          'stimulusDuration': (1000 - (normalizedRating * 300)).clamp(500, 1200),
        };
        
      case GameId.symbolSearch:
        return {
          'trials': (20 + (normalizedRating * 5)).round().clamp(15, 25),
          'gridSize': (16 + (normalizedRating * 8)).round().clamp(12, 24),
          'targetCount': (2 + (normalizedRating * 1)).round().clamp(1, 4),
        };
        
      case GameId.arithmeticSprint:
        return {
          'questions': (20 + (normalizedRating * 10)).round().clamp(15, 30),
          'complexity': (normalizedRating + 1) / 2, // 0 to 1
          'timeLimit': (120 - (normalizedRating * 30)).clamp(90, 150),
        };
        
      case GameId.patternMatrix:
        return {
          'puzzles': (12 + (normalizedRating * 6)).round().clamp(8, 18),
          'complexity': (normalizedRating + 1) / 2, // 0 to 1
          'timeLimit': (180 - (normalizedRating * 60)).clamp(120, 240),
        };
        
      case GameId.wordChain:
        return {
          'rounds': (15 + (normalizedRating * 5)).round().clamp(10, 20),
          'chainLength': (3 + (normalizedRating * 1)).round().clamp(2, 5),
          'timeLimit': (150 - (normalizedRating * 30)).clamp(120, 180),
        };
        
      case GameId.visualSearch:
        return {
          'boards': (8 + (normalizedRating * 4)).round().clamp(5, 12),
          'itemsPerBoard': (20 + (normalizedRating * 15)).round().clamp(15, 35),
          'targetsPerBoard': (3 + (normalizedRating * 2)).round().clamp(2, 6),
          'timeLimit': (120 - (normalizedRating * 30)).clamp(90, 150),
        };
    }
  }
  
  static double _getGameDifficultyMultiplier(GameId gameId) {
    switch (gameId) {
      case GameId.speedTap:
        return 1.2; // More sensitive to performance
      case GameId.stroopMatch:
        return 1.0;
      case GameId.nBack:
        return 0.8; // Less sensitive, harder to master
      case GameId.memoryGrid:
        return 1.0;
      case GameId.spatialRotation:
        return 0.9;
      case GameId.trailConnect:
        return 1.1;
      case GameId.goNoGo:
        return 1.0;
      case GameId.symbolSearch:
        return 1.0;
      case GameId.arithmeticSprint:
        return 1.1;
      case GameId.patternMatrix:
        return 0.8; // Complex reasoning, slower adaptation
      case GameId.wordChain:
        return 1.0;
      case GameId.visualSearch:
        return 1.0;
    }
  }
  
  static bool _isSpeedGame(GameId gameId) {
    return [
      GameId.speedTap,
      GameId.trailConnect,
      GameId.arithmeticSprint,
      GameId.visualSearch,
    ].contains(gameId);
  }
  
  static double _calculateReactionTimeBonus(double reactionTime, GameId gameId) {
    // Expected reaction times by game (in milliseconds)
    final expectedTimes = {
      GameId.speedTap: 400.0,
      GameId.trailConnect: 2000.0,
      GameId.arithmeticSprint: 5000.0,
      GameId.visualSearch: 3000.0,
    };
    
    final expected = expectedTimes[gameId] ?? 1000.0;
    final ratio = reactionTime / expected;
    
    // Bonus for being faster than expected, penalty for being slower
    return (1.0 - ratio) * 50; // Max ±50 points
  }
  
  /// Predict optimal difficulty for a new user based on age
  static double predictInitialDifficulty(int? age) {
    if (age == null) return 1200.0; // Default rating
    
    // Age-based difficulty prediction
    if (age < 18) {
      return 1100.0; // Younger users start slightly easier
    } else if (age < 30) {
      return 1200.0; // Standard starting point
    } else if (age < 50) {
      return 1150.0; // Slightly easier for middle-aged
    } else {
      return 1100.0; // Easier for older users
    }
  }
  
  /// Calculate confidence interval for difficulty rating
  static Map<String, double> getDifficultyConfidence(
    List<SessionResult> recentResults,
    double currentRating,
  ) {
    if (recentResults.length < 3) {
      return {'lower': currentRating - 100, 'upper': currentRating + 100};
    }
    
    final accuracies = recentResults.map((r) => r.accuracy).toList();
    final mean = accuracies.reduce((a, b) => a + b) / accuracies.length;
    final variance = accuracies
        .map((a) => pow(a - mean, 2))
        .reduce((a, b) => a + b) / accuracies.length;
    final stdDev = sqrt(variance);
    
    final confidence = 1.96 * stdDev * 100; // 95% confidence interval
    
    return {
      'lower': (currentRating - confidence).clamp(_minRating, _maxRating),
      'upper': (currentRating + confidence).clamp(_minRating, _maxRating),
    };
  }
}
