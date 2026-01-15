import '../constants/game_constants.dart';

class ScoringEngine {
  static double calculateComboScore(double baseScore, int streak) {
    final streakBonus = SafeMath.safeDivision(streak, 5, fallback: 0.0);
    return baseScore * (1 + streakBonus.floor() * 0.25);
  }

  static double calculateTimeBonus(
      int timeBudgetMs, int elapsedMs, double weight) {
    final bonus = (timeBudgetMs - elapsedMs).clamp(0, timeBudgetMs) * weight;
    return bonus.toDouble();
  }

  static double calculateSpeedTapScore(int reactionTime, bool falseStart) {
    if (falseStart) return -150.0;
    return (1000 - reactionTime).clamp(0, 1000).toDouble();
  }

  static double calculateStroopScore(bool correct) {
    return correct ? 100.0 : -50.0;
  }

  static double calculateNBackScore(bool hit, bool miss, bool falseAlarm) {
    if (hit) return 120.0;
    if (miss) return -60.0;
    if (falseAlarm) return -80.0;
    return 0.0;
  }

  static double calculateSpatialRotationScore(bool correct) {
    return correct ? 120.0 : -60.0;
  }

  static double calculateMemoryGridScore(bool correct) {
    return correct ? 80.0 : -40.0;
  }

  static double calculateTrailConnectScore(
      int parTimeMs, int elapsedMs, int errors) {
    final baseScore = (parTimeMs - elapsedMs).toDouble();
    final errorPenalty = errors * 200.0;
    return baseScore - errorPenalty;
  }

  static double calculateGoNoGoScore(bool hit, bool falseAlarm) {
    if (hit) return 80.0;
    if (falseAlarm) return -120.0;
    return 0.0;
  }

  static double calculateSymbolSearchScore(bool correct) {
    return correct ? 100.0 : -70.0;
  }

  static double calculateArithmeticScore(bool correct) {
    return correct ? 90.0 : -60.0;
  }

  static double calculatePatternMatrixScore(bool correct) {
    return correct ? 150.0 : -70.0;
  }

  static double calculateWordChainScore(bool correct) {
    return correct ? 100.0 : -50.0;
  }
}
