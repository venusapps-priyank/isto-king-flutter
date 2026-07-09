import 'package:flutter/material.dart';

enum StoreCategory { coins, gems, boards, tokens, cowrieSkins }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.category,
    required this.name,
    required this.priceLabel,
    this.subtitle,
    this.coinAmount,
    this.gemAmount,
    this.discountBadge,
    this.valueBadge,
    this.buttonColor = const Color(0xFF3B8E32),
    this.icon,
    this.imageAsset,
  });

  final String id;
  final StoreCategory category;
  final String name;
  final String? subtitle;
  final String priceLabel;
  final int? coinAmount;
  final int? gemAmount;
  final String? discountBadge;
  final String? valueBadge;
  final Color buttonColor;
  final IconData? icon;
  final String? imageAsset;
}

class FeaturedBundle {
  const FeaturedBundle({
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.gems,
    required this.priceLabel,
    required this.limitedBadge,
    required this.valueBadge,
  });

  final String title;
  final String subtitle;
  final int coins;
  final int gems;
  final String priceLabel;
  final String limitedBadge;
  final String valueBadge;
}

class DailyDeal {
  const DailyDeal({
    required this.id,
    required this.name,
    required this.amount,
    required this.isGems,
    required this.discountBadge,
    required this.priceLabel,
    required this.endsIn,
  });

  final String id;
  final String name;
  final int amount;
  final bool isGems;
  final String discountBadge;
  final String priceLabel;
  final String endsIn;
}
