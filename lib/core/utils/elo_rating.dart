import 'dart:math';

class EloRating {
  static const double kFactor = 24.0;
  static const double floor = 800.0;
  static const double ceiling = 2200.0;
  
  static double updateRating(
    double currentRating,
    double opponentRating,
    double actualScore, {
    double k = kFactor,
  }) {
    final expectedScore = 1 / (1 + pow(10, (opponentRating - currentRating) / 400));
    final newRating = currentRating + k * (actualScore - expectedScore);
    return newRating.clamp(floor, ceiling);
  }
  
  static double calculateExpectedScore(double rating, double opponentRating) {
    return 1 / (1 + pow(10, (opponentRating - rating) / 400));
  }
  
  static double gamePerformanceToScore(double accuracy, double? reactionTime) {
    // Convert game performance to ELO score (0.0 to 1.0)
    double score = accuracy;
    
    // Bonus for fast reaction times
    if (reactionTime != null && reactionTime > 0) {
      final rtBonus = (1000 - reactionTime.clamp(200, 1000)) / 800;
      score = (score + rtBonus * 0.3).clamp(0.0, 1.0);
    }
    
    return score;
  }
}
