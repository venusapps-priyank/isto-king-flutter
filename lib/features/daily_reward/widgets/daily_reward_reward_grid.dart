import 'package:flutter/material.dart';
import 'package:istochaka/features/daily_reward/models/daily_reward.dart';
import 'package:istochaka/features/daily_reward/widgets/daily_reward_day_tile.dart';

class DailyRewardRewardGrid extends StatelessWidget {
  const DailyRewardRewardGrid({
    required this.days,
    super.key,
  });

  final List<DailyRewardDay> days;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = width < 330 ? 4.0 : 6.0;
        final unitWidth = (width - gap * 3) / 4;
        final rowHeight = unitWidth * 1.36;
        final gridHeight = rowHeight * 2 + gap;
        final scale = (unitWidth / 68).clamp(0.72, 1.18);
        final grandScale = (scale * 1.14).clamp(0.72, 1.28);

        Widget tile(DailyRewardDay reward, {double? tileScale}) {
          return DailyRewardDayTile(
            reward: reward,
            scale: tileScale ?? scale,
          );
        }

        return SizedBox(
          height: gridHeight,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      Expanded(child: tile(days[i])),
                    ],
                  ],
                ),
              ),
              SizedBox(height: gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: tile(days[4])),
                    SizedBox(width: gap),
                    Expanded(child: tile(days[5])),
                    SizedBox(width: gap),
                    Expanded(
                      flex: 2,
                      child: tile(days[6], tileScale: grandScale),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
