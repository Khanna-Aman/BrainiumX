import 'dart:async';
import 'package:flutter/material.dart';

class ObjectPool<T> {
  final List<T> _pool = [];
  final T Function() _factory;
  final void Function(T)? _reset;
  final int _maxSize;

  ObjectPool({
    required T Function() factory,
    void Function(T)? reset,
    int maxSize = 100,
  })  : _factory = factory,
        _reset = reset,
        _maxSize = maxSize;

  T get() {
    if (_pool.isNotEmpty) {
      final obj = _pool.removeLast();
      _reset?.call(obj);
      return obj;
    }
    return _factory();
  }

  void release(T obj) {
    if (_pool.length < _maxSize) {
      _pool.add(obj);
    }
  }

  void clear() {
    _pool.clear();
  }
}

// Specific pools for different data types used in games
class ColorPool {
  static final ObjectPool<List<Color>> _sequencePool = ObjectPool<List<Color>>(
    factory: () => <Color>[],
    reset: (list) => list.clear(),
    maxSize: 50,
  );

  static List<Color> getSequence() => _sequencePool.get();
  static void releaseSequence(List<Color> sequence) =>
      _sequencePool.release(sequence);
}

class BoolPool {
  static final ObjectPool<List<bool>> _responsePool = ObjectPool<List<bool>>(
    factory: () => <bool>[],
    reset: (list) => list.clear(),
    maxSize: 50,
  );

  static List<bool> getResponseList() => _responsePool.get();
  static void releaseResponseList(List<bool> responses) =>
      _responsePool.release(responses);
}

class IntPool {
  static final ObjectPool<List<int>> _intPool = ObjectPool<List<int>>(
    factory: () => <int>[],
    reset: (list) => list.clear(),
    maxSize: 50,
  );

  static List<int> getIntList() => _intPool.get();
  static void releaseIntList(List<int> list) => _intPool.release(list);
}

class TimerPool {
  static final List<Timer> _activeTimers = [];

  static Timer createTimer(Duration duration, VoidCallback callback) {
    final timer = Timer(duration, callback);
    _activeTimers.add(timer);
    return timer;
  }

  static Timer createPeriodicTimer(
      Duration duration, void Function(Timer) callback) {
    final timer = Timer.periodic(duration, callback);
    _activeTimers.add(timer);
    return timer;
  }

  static void cancelTimer(Timer timer) {
    timer.cancel();
    _activeTimers.remove(timer);
  }

  static void cancelAllTimers() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
  }
}
