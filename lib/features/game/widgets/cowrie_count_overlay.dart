import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class CowrieCountOverlay extends StatelessWidget {
  const CowrieCountOverlay({
    required this.value,
    required this.size,
    super.key,
  });

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: RoyalColors.parchmentLight,
            shape: BoxShape.circle,
            border: Border.all(color: RoyalColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.5,
              height: 1,
            ),
          ),
        )
        .animate(key: ValueKey(value))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 220.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 120.ms);
  }
}
