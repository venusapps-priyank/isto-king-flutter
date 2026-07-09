import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/rules_assets.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/widgets/edit_player_dialog.dart';
import 'package:isto_king/features/home/widgets/home_top_bar.dart';
import 'package:isto_king/features/rules/widgets/rules_panel.dart';
import 'package:isto_king/features/rules/widgets/rules_subtitle.dart';
import 'package:isto_king/features/rules/widgets/rules_title_badge.dart';
import 'package:isto_king/features/settings/widgets/settings_dialog.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({
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
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
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

    for (final asset in [rulesCowrieAsset, rulesPotAsset]) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
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
                  final layout = _RulesLayout.from(
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
                        const RulesTitleBadge(),
                        SizedBox(height: layout.sectionGap * 0.7),
                        const RulesSubtitle(),
                        SizedBox(height: layout.sectionGap),
                        const RulesPanel(),
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
      ),
    );
  }
}

class _RulesLayout {
  const _RulesLayout({
    required this.scrollPadding,
    required this.topGap,
    required this.sectionGap,
    required this.bottomGap,
  });

  final EdgeInsets scrollPadding;
  final double topGap;
  final double sectionGap;
  final double bottomGap;

  factory _RulesLayout.from(
    BoxConstraints constraints, {
    bool embedded = false,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortHeight = height < 720;
    final gapScale = (height / 760).clamp(0.78, 1.08).toDouble();
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();

    return _RulesLayout(
      scrollPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        shortHeight ? 8 : 24,
        horizontalPadding,
        0,
      ),
      topGap: (shortHeight ? 4 : 8) * gapScale,
      sectionGap: (shortHeight ? 12 : 18) * gapScale,
      bottomGap: embedded
          ? (shortHeight ? 120.0 : 132.0)
          : (shortHeight ? 24.0 : 32.0),
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
            RulesScreen.cornerAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
