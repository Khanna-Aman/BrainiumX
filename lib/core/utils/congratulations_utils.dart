import 'dart:math';

class CongratulationsUtils {
  static final Random _random = Random();

  /// Generate a congratulatory message based on performance
  static String getCompletionMessage(
      double accuracy, int score, int totalRounds) {
    if (accuracy >= 90) {
      return _getExcellentMessages()[
          _random.nextInt(_getExcellentMessages().length)];
    } else if (accuracy >= 70) {
      return _getGoodMessages()[_random.nextInt(_getGoodMessages().length)];
    } else if (accuracy >= 50) {
      return _getEncouragingMessages()[
          _random.nextInt(_getEncouragingMessages().length)];
    } else {
      return _getMotivationalMessages()[
          _random.nextInt(_getMotivationalMessages().length)];
    }
  }

  /// Get title based on performance
  static String getCompletionTitle(double accuracy) {
    if (accuracy >= 90) {
      return "Outstanding Performance";
    } else if (accuracy >= 70) {
      return "Great Job";
    } else if (accuracy >= 50) {
      return "Good Effort";
    } else {
      return "Keep Practicing";
    }
  }

  static List<String> _getExcellentMessages() {
    return [
      "Incredible performance! Your cognitive skills are truly impressive!",
      "Phenomenal work! You've mastered this challenge brilliantly!",
      "Outstanding! Your brain is firing on all cylinders today!",
      "Exceptional! You're showing remarkable mental agility!",
      "Superb performance! Your focus and accuracy are top-notch!",
      "Amazing! You've demonstrated excellent cognitive control!",
      "Brilliant work! Your mental precision is truly admirable!",
      "Fantastic! You're showing elite-level cognitive performance!",
    ];
  }

  static List<String> _getGoodMessages() {
    return [
      "Well done! You're showing solid cognitive skills!",
      "Great work! Your performance is really improving!",
      "Nice job! You're demonstrating good mental agility!",
      "Excellent effort! Your focus is paying off!",
      "Good performance! You're on the right track!",
      "Well played! Your cognitive abilities are developing nicely!",
      "Strong work! You're showing consistent improvement!",
      "Good job! Your mental training is showing results!",
    ];
  }

  static List<String> _getEncouragingMessages() {
    return [
      "Good effort! Every practice session makes you stronger!",
      "Nice try! You're building valuable cognitive skills!",
      "Keep going! Your brain is adapting and learning!",
      "Solid attempt! Practice makes perfect!",
      "Good work! You're on your way to mastery!",
      "Well done! Each challenge helps you grow!",
      "Nice job! Your persistence will pay off!",
      "Good effort! You're developing important mental skills!",
    ];
  }

  static List<String> _getMotivationalMessages() {
    return [
      "Don't give up! Every expert was once a beginner!",
      "Keep practicing! Your brain gets stronger with each attempt!",
      "Stay motivated! Improvement comes with consistent effort!",
      "Keep trying! Each challenge is a learning opportunity!",
      "Don't worry! Building cognitive skills takes time and practice!",
      "Stay positive! Your dedication will lead to improvement!",
      "Keep going! Every session helps build mental strength!",
      "Remember: Progress isn't always linear, but it's always valuable!",
    ];
  }

  /// Get encouraging message for specific scenarios
  static String getSpecificEncouragement(double accuracy, String gameType) {
    if (accuracy == 0) {
      return "No worries! $gameType can be challenging at first. Your brain is learning the patterns!";
    } else if (accuracy < 25) {
      return "You're getting the hang of it! $gameType requires practice to master.";
    } else {
      return "You're making progress! Keep practicing $gameType to improve further.";
    }
  }
}
