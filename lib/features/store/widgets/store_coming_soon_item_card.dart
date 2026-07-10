import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/store/models/coming_soon_item.dart';

class StoreComingSoonItemCard extends StatelessWidget {
  const StoreComingSoonItemCard({
    required this.item,
    super.key,
  });

  final ComingSoonItem item;

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
            color: RoyalColors.brown.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 6,
            right: 6,
            child: _LockBadge(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
            child: Column(
              children: [
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: RoyalColors.darkBrown,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Image.asset(
                    item.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 4),
                const _SoonButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RoyalColors.darkBrown.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.lock_rounded,
          size: 12,
          color: Color(0xFFFFE39D),
        ),
      ),
    );
  }
}

class _SoonButton extends StatelessWidget {
  const _SoonButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: RoyalColors.darkBrown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RoyalColors.gold.withValues(alpha: 0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: Color(0xFFFFE39D),
            ),
            SizedBox(width: 4),
            Text(
              'Soon',
              style: TextStyle(
                color: Color(0xFFFFE39D),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
