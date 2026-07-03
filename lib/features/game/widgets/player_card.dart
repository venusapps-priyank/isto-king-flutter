import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/game_constants.dart';
import 'package:isto_king/features/game/widgets/cowrie_roll_panel.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.name,
    required this.color,
    required this.avatarAsset,
    this.avatarOnRight = false,
    this.shellCount = defaultShellCount,
    this.isActive = false,
    this.onRollComplete,
    super.key,
  });

  final String name;
  final Color color;
  final String avatarAsset;
  final bool avatarOnRight;
  final int shellCount;
  final bool isActive;
  final ValueChanged<int>? onRollComplete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final avatarSize = height * 0.68;
        final cardLeft = avatarSize * 0.36;
        final cardTop = height * 0.12;
        final cardBottom = height * 0.03;
        final contentLeft = avatarSize * 0.76;
        final nameSize = height < 96 ? 15.0 : 17.0;
        final contentWidth = constraints.maxWidth - cardLeft - contentLeft - 9;
        final shellSize = math.min(
          height < 96 ? 38.0 : 42.0,
          contentWidth / 2.95,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              left: avatarOnRight ? 0 : cardLeft,
              right: avatarOnRight ? cardLeft : 0,
              top: cardTop,
              bottom: cardBottom,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isActive ? 0.58 : 0.35),
                      blurRadius: isActive ? 18 : 12,
                      spreadRadius: isActive ? 1 : 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: avatarOnRight ? 9 : contentLeft,
                    right: avatarOnRight ? contentLeft : 9,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: avatarOnRight
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: nameSize + 4,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: avatarOnRight
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            name,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: nameSize,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(
                                  color: RoyalColors.brown,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CowrieRollPanel(
                        playerColor: color,
                        isActive: isActive,
                        shellCount: shellCount,
                        shellSize: shellSize,
                        alignRight: avatarOnRight,
                        onRollComplete: onRollComplete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: avatarOnRight ? null : 0,
              right: avatarOnRight ? 0 : null,
              top: height * 0.14,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Padding(
                  padding: EdgeInsets.all(avatarSize * 0.04),
                  child: ClipOval(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: ColoredBox(
                      color: RoyalColors.parchmentLight,
                      child: SizedBox.square(
                        dimension: avatarSize * 0.92,
                        child: Image.asset(
                          avatarAsset,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
