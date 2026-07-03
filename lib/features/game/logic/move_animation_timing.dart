import 'dart:math' as math;

import 'package:isto_king/features/game/models/board_cell.dart';

class MoveAnimationTiming {
  MoveAnimationTiming._();

  static const millisecondsPerStep = 180;

  static Duration durationForPath(List<BoardCell> path) {
    final segmentCount = math.max(1, path.length - 1);
    return Duration(
      milliseconds: (segmentCount * millisecondsPerStep).clamp(360, 1200),
    );
  }

  static Duration totalDurationFor({
    required Map<int, List<BoardCell>> paths,
    Map<int, Duration> delays = const {},
  }) {
    var maxDuration = Duration.zero;
    for (final entry in paths.entries) {
      final end =
          (delays[entry.key] ?? Duration.zero) + durationForPath(entry.value);
      if (end > maxDuration) maxDuration = end;
    }
    return maxDuration;
  }
}
