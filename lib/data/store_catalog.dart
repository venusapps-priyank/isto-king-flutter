import 'package:flutter/material.dart';
import 'package:isto_king/data/store_assets.dart';
import 'package:isto_king/features/store/models/store_item.dart';

const featuredBundles = [
  FeaturedBundle(
    title: 'FESTIVAL BUNDLE',
    subtitle: 'Mega value pack!',
    coins: 5000,
    priceLabel: '₹399.00',
    limitedBadge: 'LIMITED DEAL',
    valueBadge: '70% VALUE',
    imageAsset: storeSackAsset,
  ),
  FeaturedBundle(
    title: 'ROYAL STARTER',
    subtitle: 'Perfect for new players',
    coins: 2000,
    priceLabel: '₹199.00',
    limitedBadge: 'NEW PLAYER',
    valueBadge: '50% VALUE',
    imageAsset: storePotAsset,
  ),
];

const storeItems = [
  StoreItem(
    id: 'coins_2500',
    category: StoreCategory.coins,
    name: 'Pile of Coins',
    coinAmount: 2500,
    priceLabel: '₹149.00',
    imageAsset: storeMoneyAsset,
  ),
  StoreItem(
    id: 'coins_6500',
    category: StoreCategory.coins,
    name: 'Bag of Coins',
    coinAmount: 6500,
    priceLabel: '₹249.00',
    discountBadge: '20% OFF',
    imageAsset: storePotAsset,
  ),
  StoreItem(
    id: 'coins_15000',
    category: StoreCategory.coins,
    name: 'Sack of Coins',
    coinAmount: 15000,
    priceLabel: '₹499.00',
    discountBadge: '30% OFF',
    imageAsset: storeSackAsset,
  ),
  StoreItem(
    id: 'board_premium',
    category: StoreCategory.boards,
    name: 'Board Skin Pack',
    subtitle: 'Premium Board Skins',
    priceLabel: '₹199.00',
    imageAsset: 'assets/images/full-board.png',
  ),
  StoreItem(
    id: 'tokens_premium',
    category: StoreCategory.tokens,
    name: 'Token Skin Set',
    subtitle: '4 Premium Token Skins',
    priceLabel: '₹129.00',
    icon: Icons.circle,
  ),
  StoreItem(
    id: 'cowrie_pack',
    category: StoreCategory.cowrieSkins,
    name: 'Cowrie & Dice Pack',
    subtitle: 'Cowrie + Dice Skins',
    priceLabel: '₹149.00',
    discountBadge: '15% OFF',
    icon: Icons.casino,
  ),
];

const dailyDeals = [
  DailyDeal(
    id: 'daily_coins',
    name: 'Daily Coin Boost',
    amount: 1000,
    discountBadge: '40% OFF',
    priceLabel: '₹89.00',
    endsIn: '10h 32m',
    imageAsset: storeMoneyAsset,
  ),
  DailyDeal(
    id: 'daily_coins_small',
    name: 'Flash Coin Pack',
    amount: 500,
    discountBadge: '30% OFF',
    priceLabel: '₹59.00',
    endsIn: '10h 32m',
    imageAsset: storePotAsset,
  ),
];
