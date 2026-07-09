import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/store_catalog.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/store/widgets/store_daily_deals.dart';
import 'package:isto_king/features/store/widgets/store_featured_banner.dart';
import 'package:isto_king/features/store/widgets/store_item_card.dart';
import 'package:isto_king/features/store/widgets/store_title_badge.dart';
import 'package:isto_king/features/store/widgets/store_top_bar.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({
    this.profile = UserProfile.defaultProfile,
    this.embedded = false,
    super.key,
  });

  final UserProfile profile;
  final bool embedded;

  static const cornerAsset = 'assets/images/corner_mandala.png';

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ScreenOrnamentPainter(
                  topInset: topInset,
                  topCornerScale: 0.5,
                  bottomCornerScale: 1.38,
                  bottomConnectorHeight: 28,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: topInset,
              child: const ColoredBox(color: RoyalColors.outerRed),
            ),
            const _BottomCorner(isLeft: true),
            const _BottomCorner(isLeft: false),
            SafeArea(
              bottom: !embedded,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = _StoreLayout.from(
                    constraints,
                    embedded: embedded,
                  );

                  return SingleChildScrollView(
                    padding: layout.scrollPadding,
                    child: Column(
                      children: [
                        SizedBox(height: layout.topGap),
                        StoreTopBar(profile: profile),
                        SizedBox(height: layout.sectionGap),
                        const StoreTitleBadge(),
                        SizedBox(height: layout.sectionGap),
                        StoreFeaturedBanner(bundles: featuredBundles),
                        SizedBox(height: layout.sectionGap),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: layout.gridGap,
                            crossAxisSpacing: layout.gridGap,
                            childAspectRatio: layout.cardAspectRatio,
                          ),
                          itemCount: storeItems.length,
                          itemBuilder: (context, index) {
                            return StoreItemCard(item: storeItems[index]);
                          },
                        ),
                        SizedBox(height: layout.sectionGap),
                        const StoreDailyDeals(deals: dailyDeals),
                        SizedBox(height: layout.bottomGap),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreLayout {
  const _StoreLayout({
    required this.scrollPadding,
    required this.topGap,
    required this.sectionGap,
    required this.gridGap,
    required this.bottomGap,
    required this.cardAspectRatio,
  });

  final EdgeInsets scrollPadding;
  final double topGap;
  final double sectionGap;
  final double gridGap;
  final double bottomGap;
  final double cardAspectRatio;

  factory _StoreLayout.from(
    BoxConstraints constraints, {
    bool embedded = false,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortHeight = height < 720;
    final compactWidth = width < 360;
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();

    return _StoreLayout(
      scrollPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      topGap: shortHeight ? 4 : 8,
      sectionGap: shortHeight ? 10 : 14,
      gridGap: compactWidth ? 6 : 8,
      bottomGap: embedded
          ? (shortHeight ? 100.0 : 112.0)
          : (shortHeight ? 8 : 12),
      cardAspectRatio: compactWidth ? 0.62 : 0.68,
    );
  }
}

class _BottomCorner extends StatelessWidget {
  const _BottomCorner({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageSize = (screenWidth * 0.42).clamp(126.0, 170.0).toDouble();
    final offset = -imageSize / 2;

    return Positioned(
      left: isLeft ? offset : null,
      right: isLeft ? null : offset,
      bottom: offset,
      width: imageSize,
      height: imageSize,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.94,
          child: Image.asset(
            StoreScreen.cornerAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
