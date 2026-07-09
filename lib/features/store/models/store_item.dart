import 'package:flutter/material.dart';

enum StoreCategory { coins, boards, tokens, cowrieSkins }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.category,
    required this.name,
    required this.priceLabel,
    this.subtitle,
    this.coinAmount,
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
    required this.priceLabel,
    required this.limitedBadge,
    required this.valueBadge,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final int coins;
  final String priceLabel;
  final String limitedBadge;
  final String valueBadge;
  final String imageAsset;
}

class DailyDeal {
  const DailyDeal({
    required this.id,
    required this.name,
    required this.amount,
    required this.discountBadge,
    required this.priceLabel,
    required this.endsIn,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final int amount;
  final String discountBadge;
  final String priceLabel;
  final String endsIn;
  final String imageAsset;
}
