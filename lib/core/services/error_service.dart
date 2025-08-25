import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorService {
  static final List<AppError> _errorLog = [];
  static const int _maxLogSize = 100;

  static List<AppError> get errorLog => List.unmodifiable(_errorLog);

  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final appError = AppError(
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      timestamp: DateTime.now(),
      additionalData: additionalData,
    );

    _errorLog.add(appError);

    // Keep log size manageable
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      developer.log(
        'Error: ${error.toString()}',
        name: 'BrainiumX',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void handleGameError(
    dynamic error,
    StackTrace? stackTrace,
    String gameId,
  ) {
    logError(
      error,
      stackTrace,
      context: 'Game: $gameId',
      additionalData: {'gameId': gameId},
    );
  }

  static void handleDataError(
    dynamic error,
    StackTrace? stackTrace,
    String operation,
  ) {
    logError(
      error,
      stackTrace,
      context: 'Data: $operation',
      additionalData: {'operation': operation},
    );
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallback,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace, context: context);

      if (showError && kDebugMode) {
        developer.log(
          'Safe execute failed: $error',
          name: 'BrainiumX',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return fallback;
    }
  }

  static T? safeSyncExecute<T>(
    T Function() operation, {
    String? context,
    T? fallback,
    bool showError = true,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace, context: context);

      if (showError && kDebugMode) {
        developer.log(
          'Safe sync execute failed: $error',
          name: 'BrainiumX',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return fallback;
    }
  }

  static void clearErrorLog() {
    _errorLog.clear();
  }

  static Map<String, dynamic> getErrorSummary() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final recentErrors =
        _errorLog.where((e) => e.timestamp.isAfter(last24Hours));

    final errorsByContext = <String, int>{};
    for (final error in recentErrors) {
      final context = error.context ?? 'Unknown';
      errorsByContext[context] = (errorsByContext[context] ?? 0) + 1;
    }

    return {
      'totalErrors': _errorLog.length,
      'recentErrors': recentErrors.length,
      'errorsByContext': errorsByContext,
      'lastError': _errorLog.isNotEmpty
          ? _errorLog.last.timestamp.toIso8601String()
          : null,
    };
  }
}

class AppError {
  final String error;
  final String? stackTrace;
  final String? context;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  AppError({
    required this.error,
    this.stackTrace,
    this.context,
    required this.timestamp,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'stackTrace': stackTrace,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }
}

// Global error handler
void setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorService.logError(
      details.exception,
      details.stack,
      context: 'Flutter Framework',
      additionalData: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    // Only log to console in debug mode, don't show red screen
    if (kDebugMode) {
      developer.log(
        'Flutter Error: ${details.exception}',
        name: 'BrainiumX',
        error: details.exception,
        stackTrace: details.stack,
      );
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorService.logError(
      error,
      stack,
      context: 'Platform',
    );
    return true;
  };
}
