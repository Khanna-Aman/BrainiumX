import 'dart:math';
import '../../data/models/models.dart';

class AnalyticsService {
  static Map<String, double> calculateDomainScores(List<SessionResult> results) {
    final domainScores = <String, List<double>>{};
    
    for (final result in results) {
      for (final domain in result.gameId.domains) {
        domainScores.putIfAbsent(domain, () => []).add(result.score);
      }
    }
    
    final averages = <String, double>{};
    for (final entry in domainScores.entries) {
      averages[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }
    
    return averages;
  }
  
  static List<double> getScoreTrend(List<SessionResult> results, GameId gameId) {
    return results
        .where((r) => r.gameId == gameId)
        .map((r) => r.score)
        .toList();
  }
  
  static double calculateImprovementRate(List<SessionResult> results, GameId gameId) {
    final gameResults = results.where((r) => r.gameId == gameId).toList();
    if (gameResults.length < 2) return 0.0;
    
    gameResults.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final firstScore = gameResults.first.score;
    final lastScore = gameResults.last.score;
    
    return ((lastScore - firstScore) / firstScore) * 100;
  }
  
  static Map<String, int> getPlayFrequency(List<SessionResult> results) {
    final frequency = <String, int>{};
    
    for (final result in results) {
      final game = result.gameId.displayName;
      frequency[game] = (frequency[game] ?? 0) + 1;
    }
    
    return frequency;
  }
  
  static double calculateOverallProgress(List<SessionResult> results) {
    if (results.isEmpty) return 0.0;
    
    final recentResults = results
        .where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    
    if (recentResults.isEmpty) return 0.0;
    
    final avgRecentScore = recentResults
        .map((r) => r.score)
        .reduce((a, b) => a + b) / recentResults.length;
    
    final olderResults = results
        .where((r) => r.timestamp.isBefore(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    
    if (olderResults.isEmpty) return 0.0;
    
    final avgOlderScore = olderResults
        .map((r) => r.score)
        .reduce((a, b) => a + b) / olderResults.length;
    
    return ((avgRecentScore - avgOlderScore) / avgOlderScore) * 100;
  }
  
  static List<ChartData> getWeeklyProgress(List<SessionResult> results) {
    final weeklyData = <DateTime, List<double>>{};
    
    for (final result in results) {
      final weekStart = _getWeekStart(result.timestamp);
      weeklyData.putIfAbsent(weekStart, () => []).add(result.score);
    }
    
    final chartData = <ChartData>[];
    final sortedWeeks = weeklyData.keys.toList()..sort();
    
    for (final week in sortedWeeks) {
      final scores = weeklyData[week]!;
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      chartData.add(ChartData(week, avgScore));
    }
    
    return chartData;
  }
  
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
  
  static Map<String, double> getReactionTimeStats(List<SessionResult> results) {
    final reactionTimes = results
        .where((r) => r.reactionTime != null)
        .map((r) => r.reactionTime!)
        .toList();
    
    if (reactionTimes.isEmpty) {
      return {'avg': 0.0, 'best': 0.0, 'recent': 0.0};
    }
    
    final avg = reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
    final best = reactionTimes.reduce(min);
    final recent = reactionTimes.length >= 5 
        ? reactionTimes.sublist(reactionTimes.length - 5).reduce((a, b) => a + b) / 5
        : avg;
    
    return {'avg': avg, 'best': best, 'recent': recent};
  }
  
  static List<GamePerformance> getGamePerformanceRanking(
    List<SessionResult> results, 
    List<GameConfig> configs
  ) {
    final performances = <GamePerformance>[];
    
    for (final config in configs) {
      final gameResults = results.where((r) => r.gameId == config.gameId).toList();
      
      if (gameResults.isNotEmpty) {
        final avgScore = gameResults.map((r) => r.score).reduce((a, b) => a + b) / gameResults.length;
        final avgAccuracy = gameResults.map((r) => r.accuracy).reduce((a, b) => a + b) / gameResults.length;
        final improvement = calculateImprovementRate(results, config.gameId);
        
        performances.add(GamePerformance(
          gameId: config.gameId,
          avgScore: avgScore,
          avgAccuracy: avgAccuracy,
          improvement: improvement,
          timesPlayed: gameResults.length,
          currentRating: config.difficultyRating,
        ));
      }
    }
    
    // Sort by overall performance (combination of score, accuracy, and improvement)
    performances.sort((a, b) {
      final scoreA = (a.avgScore * 0.4) + (a.avgAccuracy * 100 * 0.4) + (a.improvement * 0.2);
      final scoreB = (b.avgScore * 0.4) + (b.avgAccuracy * 100 * 0.4) + (b.improvement * 0.2);
      return scoreB.compareTo(scoreA);
    });
    
    return performances;
  }
}

class ChartData {
  final DateTime date;
  final double value;
  
  ChartData(this.date, this.value);
}

class GamePerformance {
  final GameId gameId;
  final double avgScore;
  final double avgAccuracy;
  final double improvement;
  final int timesPlayed;
  final double currentRating;
  
  GamePerformance({
    required this.gameId,
    required this.avgScore,
    required this.avgAccuracy,
    required this.improvement,
    required this.timesPlayed,
    required this.currentRating,
  });
}
