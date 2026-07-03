import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/game/widgets/round_icon_button.dart';

class TopGameBar extends StatelessWidget {
  const TopGameBar({
    required this.message,
    required this.activeColor,
    super.key,
  });

  final String message;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final messageWidth = (constraints.maxWidth - 168)
            .clamp(150.0, 280.0)
            .toDouble();

        return Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 0,
              child: RoundIconButton(icon: Icons.arrow_back),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: messageWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: RoyalColors.parchmentLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: activeColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: RoyalColors.brown.withValues(alpha: 0.16),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 5, backgroundColor: activeColor),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RoyalColors.darkBrown,
                              fontSize: 13,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 0,
              child: RoundIconButton(icon: Icons.settings),
            ),
            Positioned(right: 48, child: const CoinBalancePill()),
          ],
        );
      },
    );
  }
}
