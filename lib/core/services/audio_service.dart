import 'package:flutter/services.dart';

class AudioService {
  static bool _soundEnabled = true;
  static bool _hapticsEnabled = true;

  static bool get soundEnabled => _soundEnabled;
  static bool get hapticsEnabled => _hapticsEnabled;

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  static Future<void> playCorrect() async {
    if (_soundEnabled) {
      // Use a more pleasant sound for correct answers
      await SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      await _lightHaptic();
    }
  }

  static Future<void> playIncorrect() async {
    if (_soundEnabled) {
      // Use alert sound for incorrect answers
      await SystemSound.play(SystemSoundType.alert);
    }
    if (_hapticsEnabled) {
      await _mediumHaptic();
    }
  }

  static Future<void> playGameStart() async {
    if (_soundEnabled) {
      // Play a sequence of clicks for game start
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      await _lightHaptic();
    }
  }

  static Future<void> playGameComplete() async {
    if (_soundEnabled) {
      // Play a success sequence
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 150));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 150));
      await SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      await _heavyHaptic();
    }
  }

  static Future<void> playButtonTap() async {
    if (_soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      await _lightHaptic();
    }
  }

  static Future<void> playAchievementUnlocked() async {
    if (_soundEnabled) {
      // Special sound for achievements
      for (int i = 0; i < 3; i++) {
        await SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    if (_hapticsEnabled) {
      await _heavyHaptic();
      await Future.delayed(const Duration(milliseconds: 200));
      await _heavyHaptic();
    }
  }

  static Future<void> playStreakMilestone() async {
    if (_soundEnabled) {
      // Special sound for streak milestones
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 200));
      await SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      await _mediumHaptic();
    }
  }

  static Future<void> _lightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  static Future<void> _mediumHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  static Future<void> _heavyHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }
}
