import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class CurrentTurnBanner extends StatelessWidget {
  const CurrentTurnBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: RoyalColors.boardCell,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: RoyalColors.gold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✣',
                style: TextStyle(color: RoyalColors.gold, fontSize: 17),
              ),
              SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Current Turn:',
                    style: TextStyle(
                      color: RoyalColors.darkBrown,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(radius: 8, backgroundColor: RoyalColors.red),
              SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Rammohan',
                    style: TextStyle(
                      color: RoyalColors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                '✣',
                style: TextStyle(color: RoyalColors.gold, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
