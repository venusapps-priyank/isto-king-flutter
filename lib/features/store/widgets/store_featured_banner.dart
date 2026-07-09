import 'package:flutter/material.dart';
import 'package:isto_king/data/store_assets.dart';

class StoreFeaturedBanner extends StatelessWidget {
  const StoreFeaturedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1024 / 430,
        child: Image.asset(
          storeBannerAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
