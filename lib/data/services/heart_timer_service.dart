/// Calculates offline and online heart/life regeneration
class HeartRegenResult {
  final int hearts;
  final int maxHearts;
  final Duration timeUntilNextHeart;
  final DateTime lastHeartTimestamp;

  const HeartRegenResult({
    required this.hearts,
    required this.maxHearts,
    required this.timeUntilNextHeart,
    required this.lastHeartTimestamp,
  });

  bool get isFull => hearts >= maxHearts;
}

class HeartTimerService {
  static const int maxHearts = 3;
  static const Duration refillInterval = Duration(minutes: 20);

  HeartTimerService._();

  static HeartRegenResult calculateCurrentHearts({
    required int storedHearts,
    required DateTime lastTimestamp,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    if (storedHearts >= maxHearts) {
      return HeartRegenResult(
        hearts: maxHearts,
        maxHearts: maxHearts,
        timeUntilNextHeart: Duration.zero,
        lastHeartTimestamp: currentTime,
      );
    }

    final elapsed = currentTime.difference(lastTimestamp);
    if (elapsed.isNegative) {
      return HeartRegenResult(
        hearts: storedHearts,
        maxHearts: maxHearts,
        timeUntilNextHeart: refillInterval,
        lastHeartTimestamp: currentTime,
      );
    }

    final heartsToRegen = elapsed.inSeconds ~/ refillInterval.inSeconds;
    final newHearts = (storedHearts + heartsToRegen).clamp(0, maxHearts);

    if (newHearts >= maxHearts) {
      return HeartRegenResult(
        hearts: maxHearts,
        maxHearts: maxHearts,
        timeUntilNextHeart: Duration.zero,
        lastHeartTimestamp: currentTime,
      );
    }

    // Remaining seconds towards next heart
    final remainderSeconds = elapsed.inSeconds % refillInterval.inSeconds;
    final timeUntilNext = Duration(seconds: refillInterval.inSeconds - remainderSeconds);
    final updatedTimestamp = currentTime.subtract(Duration(seconds: remainderSeconds));

    return HeartRegenResult(
      hearts: newHearts,
      maxHearts: maxHearts,
      timeUntilNextHeart: timeUntilNext,
      lastHeartTimestamp: updatedTimestamp,
    );
  }
}
