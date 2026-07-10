import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/app_screen_scaffold.dart';
import 'package:isto_king/data/store_assets.dart';
import 'package:isto_king/data/store_coming_soon_catalog.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/widgets/edit_player_dialog.dart';
import 'package:isto_king/features/home/widgets/home_top_bar.dart';
import 'package:isto_king/features/settings/widgets/settings_dialog.dart';
import 'package:isto_king/features/store/widgets/store_coming_soon_banner.dart';
import 'package:isto_king/features/store/widgets/store_coming_soon_item_card.dart';
import 'package:isto_king/features/store/widgets/store_coming_soon_teaser.dart';
import 'package:isto_king/features/store/widgets/store_title_badge.dart';

class StoreComingSoonScreen extends StatefulWidget {
  const StoreComingSoonScreen({
    this.profile = UserProfile.defaultProfile,
    this.onProfileChanged,
    this.embedded = false,
    super.key,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileChanged;
  final bool embedded;

  static const cornerAsset = 'assets/images/corner_mandala.png';

  @override
  State<StoreComingSoonScreen> createState() => _StoreComingSoonScreenState();
}

class _StoreComingSoonScreenState extends State<StoreComingSoonScreen> {
  bool _didWarmAssets = false;

  Future<void> _onEditProfileTap(BuildContext context) async {
    final updatedProfile = await EditPlayerDialog.show(
      context,
      initialProfile: widget.profile,
    );
    if (updatedProfile != null) {
      widget.onProfileChanged?.call(updatedProfile);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didWarmAssets) return;
    _didWarmAssets = true;

    for (final asset in storeComingSoonImageAssets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    final content = Stack(
      children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: RoyalColors.parchment),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = _StoreComingSoonLayout.from(
                    constraints,
                    embedded: widget.embedded,
                  );

                  return SingleChildScrollView(
                    padding: layout.scrollPadding.copyWith(
                      bottom: layout.bottomGap,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: layout.topGap),
                        HomeTopBar(
                          profile: widget.profile,
                          onEditProfileTap: () => _onEditProfileTap(context),
                          onSettingsTap: () => SettingsDialog.show(context),
                        ),
                        SizedBox(height: layout.sectionGap),
                        const StoreTitleBadge(),
                        SizedBox(height: layout.sectionGap),
                        const StoreComingSoonBanner(),
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
                          itemCount: comingSoonItems.length,
                          itemBuilder: (context, index) {
                            return StoreComingSoonItemCard(
                              item: comingSoonItems[index],
                            );
                          },
                        ),
                        SizedBox(height: layout.sectionGap),
                        const StoreComingSoonTeaser(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScreenOrnamentPainter(
                  topInset: topInset,
                  topCornerScale: 0.5,
                  bottomCornerScale: 1.38,
                  bottomConnectorHeight: 28,
                ),
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
      ],
    );

    if (widget.embedded) return content;

    return AppScreenScaffold(body: content);
  }
}

class _StoreComingSoonLayout {
  const _StoreComingSoonLayout({
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

  factory _StoreComingSoonLayout.from(
    BoxConstraints constraints, {
    bool embedded = false,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortHeight = height < 720;
    final compactWidth = width < 360;
    final gapScale = (height / 760).clamp(0.78, 1.08).toDouble();
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();

    return _StoreComingSoonLayout(
      scrollPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        shortHeight ? 8 : 24,
        horizontalPadding,
        0,
      ),
      topGap: (shortHeight ? 4 : 8) * gapScale,
      sectionGap: (shortHeight ? 12 : 18) * gapScale,
      gridGap: compactWidth ? 6 : 8,
      bottomGap: embedded
          ? (shortHeight ? 120.0 : 132.0)
          : (shortHeight ? 24.0 : 32.0),
      cardAspectRatio: compactWidth ? 0.78 : 0.86,
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
            StoreComingSoonScreen.cornerAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
