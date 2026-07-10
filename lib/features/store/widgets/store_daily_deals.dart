import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/store/models/store_item.dart';

class StoreDailyDeals extends StatelessWidget {
  const StoreDailyDeals({
    required this.deals,
    super.key,
  });

  final List<DailyDeal> deals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DailyDealsHeader(),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < deals.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _DailyDealCard(deal: deals[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _DailyDealsHeader extends StatelessWidget {
  const _DailyDealsHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1A1A), Color(0xFF5A0505)],
        ),
        border: Border.all(color: RoyalColors.gold, width: 1.5),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'DAILY DEALS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFFE39D),
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _DailyDealCard extends StatelessWidget {
  const _DailyDealCard({required this.deal});

  final DailyDeal deal;

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
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    deal.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: RoyalColors.darkBrown,
                        ),
                      ),
                      Text(
                        '${deal.amount} Coins',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: RoyalColors.brown.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 12,
                  color: RoyalColors.brown.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 3),
                Text(
                  'Ends in ${deal.endsIn}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: RoyalColors.brown.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: RoyalColors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deal.discountBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RoyalColors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deal.priceLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
