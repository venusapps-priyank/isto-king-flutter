import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/widgets/coin_icon.dart';
import 'package:isto_king/features/store/models/store_item.dart';

class StoreItemCard extends StatelessWidget {
  const StoreItemCard({
    required this.item,
    super.key,
  });

  final StoreItem item;

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
          if (item.discountBadge != null)
            Positioned(
              top: 6,
              right: 6,
              child: _Badge(label: item.discountBadge!),
            ),
          if (item.valueBadge != null)
            Positioned(
              top: 6,
              right: 6,
              child: _Badge(label: item.valueBadge!, isValue: true),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              children: [
                Expanded(child: _ItemPreview(item: item)),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: RoyalColors.darkBrown,
                    height: 1.1,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: RoyalColors.brown.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (item.coinAmount != null) ...[
                  const SizedBox(height: 4),
                  _AmountRow(amount: item.coinAmount!),
                ],
                const SizedBox(height: 6),
                _BuyButton(
                  label: item.priceLabel,
                  color: item.buttonColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    if (item.imageAsset != null) {
      return Image.asset(item.imageAsset!, fit: BoxFit.contain);
    }

    if (item.coinAmount != null) {
      return _ScaledCoinStack(amount: item.coinAmount!);
    }

    return Icon(
      item.icon ?? Icons.shopping_bag,
      size: 42,
      color: RoyalColors.brown.withValues(alpha: 0.7),
    );
  }
}

class _ScaledCoinStack extends StatelessWidget {
  const _ScaledCoinStack({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final size = amount >= 10000 ? 48.0 : amount >= 5000 ? 42.0 : 36.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (amount >= 5000)
          const Positioned(left: 4, top: 8, child: CoinIcon(size: 24)),
        if (amount >= 2500)
          const Positioned(right: 4, top: 6, child: CoinIcon(size: 22)),
        CoinIcon(size: size),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CoinIcon(size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$amount Coins',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: RoyalColors.brown,
            ),
          ),
        ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.isValue = false});

  final String label;
  final bool isValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isValue ? RoyalColors.yellow : RoyalColors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isValue ? RoyalColors.darkBrown : Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
