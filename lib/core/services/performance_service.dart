import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];
  static const int _maxMetrics = 1000;

  static List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  static void stopTimer(String name, {Map<String, dynamic>? metadata}) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();

      final metric = PerformanceMetric(
        name: name,
        duration: timer.elapsedMilliseconds,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      _addMetric(metric);
      _timers.remove(name);

      if (kDebugMode) {
        developer.log(
          'Performance: $name took ${timer.elapsedMilliseconds}ms',
          name: 'BrainiumX Performance',
        );
      }
    }
  }

  static void recordMetric(
    String name,
    int value, {
    String unit = 'ms',
    Map<String, dynamic>? metadata,
  }) {
    final metric = PerformanceMetric(
      name: name,
      duration: value,
      timestamp: DateTime.now(),
      unit: unit,
      metadata: metadata,
    );

    _addMetric(metric);
  }

  static void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // Keep metrics list manageable
    if (_metrics.length > _maxMetrics) {
      _metrics.removeAt(0);
    }
  }

  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startTimer(name);
    try {
      final result = await operation();
      stopTimer(name, metadata: metadata);
      return result;
    } catch (e) {
      stopTimer(name, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }

  static T measureSync<T>(
    String name,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    startTimer(name);
    try {
      final result = operation();
      stopTimer(name, metadata: metadata);
      return result;
    } catch (e) {
      stopTimer(name, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }

  static Map<String, dynamic> getPerformanceSummary() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final recentMetrics =
        _metrics.where((m) => m.timestamp.isAfter(last24Hours));

    final metricsByName = <String, List<int>>{};
    for (final metric in recentMetrics) {
      metricsByName.putIfAbsent(metric.name, () => []).add(metric.duration);
    }

    final summary = <String, Map<String, dynamic>>{};
    for (final entry in metricsByName.entries) {
      final values = entry.value;
      values.sort();

      summary[entry.key] = {
        'count': values.length,
        'avg': values.reduce((a, b) => a + b) / values.length,
        'min': values.first,
        'max': values.last,
        'p50': values[values.length ~/ 2],
        'p95': values[(values.length * 0.95).round() - 1],
      };
    }

    return {
      'totalMetrics': _metrics.length,
      'recentMetrics': recentMetrics.length,
      'summary': summary,
    };
  }

  static List<PerformanceMetric> getSlowOperations({int threshold = 1000}) {
    return _metrics.where((m) => m.duration > threshold).toList();
  }

  static void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }

  // Game-specific performance tracking
  static void trackGameLoad(String gameId) {
    startTimer('game_load_$gameId');
  }

  static void trackGameLoadComplete(String gameId) {
    stopTimer('game_load_$gameId', metadata: {'gameId': gameId});
  }

  static void trackGamePerformance(
    String gameId,
    int score,
    double accuracy,
    int duration,
  ) {
    recordMetric(
      'game_session',
      duration,
      metadata: {
        'gameId': gameId,
        'score': score,
        'accuracy': accuracy,
      },
    );
  }

  static void trackDataOperation(String operation, int recordCount) {
    recordMetric(
      'data_operation',
      0, // Duration will be measured separately
      unit: 'records',
      metadata: {
        'operation': operation,
        'recordCount': recordCount,
      },
    );
  }

  // Memory usage tracking
  static void trackMemoryUsage() {
    if (kDebugMode) {
      // This would require platform-specific implementation
      // For now, just log that we're tracking
      developer.log(
        'Memory tracking requested',
        name: 'BrainiumX Performance',
      );
    }
  }

  // Frame rate tracking
  static void startFrameRateTracking() {
    if (kDebugMode) {
      developer.log(
        'Frame rate tracking started',
        name: 'BrainiumX Performance',
      );
    }
  }

  static void stopFrameRateTracking() {
    if (kDebugMode) {
      developer.log(
        'Frame rate tracking stopped',
        name: 'BrainiumX Performance',
      );
    }
  }
}

class PerformanceMetric {
  final String name;
  final int duration;
  final DateTime timestamp;
  final String unit;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    this.unit = 'ms',
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'metadata': metadata,
    };
  }
}
