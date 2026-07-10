import 'package:flutter/material.dart';
import 'package:isto_king/data/store_assets.dart';

class StoreComingSoonBanner extends StatelessWidget {
  const StoreComingSoonBanner({super.key});

  static const _aspectRatio = 1491 / 1055;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: Image.asset(
              storeComingSoonBannerAsset,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
