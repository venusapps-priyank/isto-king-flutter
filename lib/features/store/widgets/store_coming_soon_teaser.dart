import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';

class StoreComingSoonTeaser extends StatelessWidget {
  const StoreComingSoonTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8EA), Color(0xFFF6E8C8)],
        ),
        border: Border.all(color: RoyalColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.brown.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: RoyalColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 22,
                  color: RoyalColors.red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Something amazing is on the way! Check back later for '
                'exclusive offers and limited-time festive deals.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RoyalColors.brown.withValues(alpha: 0.92),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
