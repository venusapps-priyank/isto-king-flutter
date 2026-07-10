import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/app_screen_scaffold.dart';
import 'package:isto_king/core/widgets/royal_screen_frame.dart';
import 'package:isto_king/data/avatar_assets.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/widgets/edit_player_dialog.dart';
import 'package:isto_king/data/home_assets.dart';
import 'package:isto_king/features/home/widgets/home_cta_button.dart';
import 'package:isto_king/features/home/widgets/home_top_bar.dart';
import 'package:isto_king/features/home/widgets/online_coming_soon_dialog.dart';
import 'package:isto_king/features/rules/models/game_rules_settings.dart';
import 'package:isto_king/features/settings/widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.profile = UserProfile.defaultProfile,
    this.onProfileChanged,
    this.rulesSettings = GameRulesSettings.defaults,
    this.onShowGameSetup,
    this.embedded = false,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileChanged;
  final GameRulesSettings rulesSettings;
  final ValueChanged<bool>? onShowGameSetup;
  final bool embedded;

  static const _boardAsset = 'assets/images/full-board.png';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didWarmGameAssets = false;

  UserProfile get _profile => widget.profile;

  static const _gameEntryAssets = [
    ...avatarAssets,
    playTogetherAsset,
    gameNameAsset,
    'assets/images/corner_mandala.png',
    'assets/images/cowrie_open.png',
    'assets/images/cowrie_closed.png',
    'assets/images/rank_crown_1.png',
  ];

  Future<void> _onEditProfileTap() async {
    final updatedProfile = await EditPlayerDialog.show(
      context,
      initialProfile: _profile,
    );
    if (updatedProfile != null && mounted) {
      widget.onProfileChanged?.call(updatedProfile);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didWarmGameAssets) return;
    _didWarmGameAssets = true;

    for (final asset in _gameEntryAssets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = RoyalScreenFrame(
      child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = _HomeLayout.from(
              constraints,
              embedded: widget.embedded,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: layout.headerPadding,
                  child: HomeTopBar(
                    profile: _profile,
                    onEditProfileTap: _onEditProfileTap,
                    onSettingsTap: () => SettingsDialog.show(context),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, contentConstraints) {
                      return SingleChildScrollView(
                        padding: layout.contentPadding,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: contentConstraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: layout.profileTitleGap),
                              _TitleBadge(
                                widthFactor: layout.titleWidthFactor,
                                maxWidth: layout.titleMaxWidth,
                              ),
                              SizedBox(height: layout.titleBoardGap),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: layout.boardMaxWidth,
                                  maxHeight: layout.boardMaxHeight,
                                ),
                                child: Image.asset(
                                  HomeScreen._boardAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: layout.boardActionGap),
                              _HomeActionButtons(
                                buttonGap: layout.actionButtonGap,
                                primaryButtonScale: layout.primaryButtonScale,
                                onPlayNow: () =>
                                    widget.onShowGameSetup?.call(true),
                                onPassAndPlay: () =>
                                    widget.onShowGameSetup?.call(false),
                                onOnlinePlay: () =>
                                    OnlineComingSoonDialog.show(context),
                              ),
                              if (widget.embedded)
                                SizedBox(height: layout.bottomGap),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
    );

    if (widget.embedded) return content;

    return AppScreenScaffold(body: content);
  }
}

class _HomeLayout {
  const _HomeLayout({
    required this.headerPadding,
    required this.contentPadding,
    required this.profileTitleGap,
    required this.titleBoardGap,
    required this.boardActionGap,
    required this.actionButtonGap,
    required this.boardMaxWidth,
    required this.boardMaxHeight,
    required this.titleWidthFactor,
    required this.titleMaxWidth,
    required this.primaryButtonScale,
    required this.bottomGap,
  });

  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;
  final double profileTitleGap;
  final double titleBoardGap;
  final double boardActionGap;
  final double actionButtonGap;
  final double boardMaxWidth;
  final double boardMaxHeight;
  final double titleWidthFactor;
  final double titleMaxWidth;
  final double primaryButtonScale;
  final double bottomGap;

  static double _sectionGap(
    double height, {
    required double ratio,
    required double min,
    required double max,
  }) {
    return (height * ratio).clamp(min, max).toDouble();
  }

  factory _HomeLayout.from(
    BoxConstraints constraints, {
    bool embedded = false,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortHeight = height <= 720;
    final veryShortHeight = height < 620;
    final compactWidth = width < 360;
    final mediumCompact =
        width >= 480 && width <= 600 && height <= 760 && embedded;
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();

    final boardHeightRatio = veryShortHeight
        ? 0.24
        : mediumCompact
        ? 0.23
        : shortHeight
        ? 0.26
        : 0.34;
    final boardMinHeight = compactWidth
        ? 170.0
        : mediumCompact
        ? 155.0
        : 200.0;
    final boardMaxHeightCap = mediumCompact
        ? 210.0
        : shortHeight
        ? 250.0
        : 330.0;

    return _HomeLayout(
      headerPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        shortHeight ? 8 : 24,
        horizontalPadding,
        0,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        embedded ? (shortHeight ? 8 : 12) : 0,
      ),
      profileTitleGap: _sectionGap(
        height,
        ratio: veryShortHeight
            ? 0.018
            : mediumCompact
            ? 0.014
            : shortHeight
            ? 0.02
            : 0.032,
        min: veryShortHeight ? 8 : mediumCompact ? 6 : shortHeight ? 10 : 18,
        max: veryShortHeight ? 14 : mediumCompact ? 10 : shortHeight ? 18 : 36,
      ),
      titleBoardGap: _sectionGap(
        height,
        ratio: veryShortHeight
            ? 0.008
            : mediumCompact
            ? 0.006
            : shortHeight
            ? 0.01
            : 0.016,
        min: veryShortHeight ? 4 : mediumCompact ? 3 : shortHeight ? 5 : 8,
        max: veryShortHeight ? 8 : mediumCompact ? 6 : shortHeight ? 10 : 16,
      ),
      boardActionGap: _sectionGap(
        height,
        ratio: veryShortHeight
            ? 0.022
            : mediumCompact
            ? 0.018
            : shortHeight
            ? 0.024
            : 0.042,
        min: veryShortHeight ? 10 : mediumCompact ? 8 : shortHeight ? 12 : 20,
        max: veryShortHeight ? 18 : mediumCompact ? 14 : shortHeight ? 22 : 44,
      ),
      actionButtonGap: _sectionGap(
        height,
        ratio: veryShortHeight
            ? 0.018
            : mediumCompact
            ? 0.014
            : shortHeight
            ? 0.018
            : 0.028,
        min: veryShortHeight ? 8 : mediumCompact ? 6 : shortHeight ? 8 : 14,
        max: veryShortHeight ? 14 : mediumCompact ? 12 : shortHeight ? 16 : 28,
      ),
      boardMaxWidth: width - horizontalPadding * 2,
      boardMaxHeight: (height * boardHeightRatio)
          .clamp(boardMinHeight, boardMaxHeightCap)
          .toDouble(),
      titleWidthFactor: mediumCompact
          ? 0.68
          : shortHeight
          ? 0.74
          : 0.82,
      titleMaxWidth: mediumCompact
          ? 290.0
          : shortHeight
          ? 320.0
          : 360.0,
      primaryButtonScale: mediumCompact
          ? 0.84
          : shortHeight
          ? 0.9
          : 1.0,
      bottomGap: embedded ? (shortHeight ? 96.0 : 108.0) : 0,
    );
  }
}

class _HomeActionButtons extends StatelessWidget {
  const _HomeActionButtons({
    required this.buttonGap,
    required this.primaryButtonScale,
    required this.onPlayNow,
    required this.onPassAndPlay,
    required this.onOnlinePlay,
  });

  final double buttonGap;
  final double primaryButtonScale;
  final VoidCallback onPlayNow;
  final VoidCallback onPassAndPlay;
  final VoidCallback onOnlinePlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mediumWidth = width >= 390 && width < 620;
        final primaryInset = mediumWidth
            ? (width * 0.08).clamp(16.0, 38.0)
            : (width * 0.13).clamp(12.0, 52.0);
        final secondaryInset = mediumWidth
            ? (width * 0.025).clamp(4.0, 14.0)
            : (width * 0.04).clamp(4.0, 24.0);
        final secondaryGap = width < 340 ? 6.0 : 8.0;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: primaryInset),
              child: HomeCtaButton(
                label: 'PLAY NOW',
                compactScale: primaryButtonScale,
                onPressed: onPlayNow,
              ),
            ),
            SizedBox(height: buttonGap),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: secondaryInset),
              child: Row(
                children: [
                  HomeCtaButton(
                    expanded: true,
                    label: 'PASS & PLAY',
                    subtitle: 'Play with AI',
                    icon: Icons.people_outlined,
                    backgroundColor: RoyalColors.yellow,
                    onPressed: onPassAndPlay,
                  ),
                  SizedBox(width: secondaryGap),
                  HomeCtaButton(
                    expanded: true,
                    label: 'ONLINE',
                    subtitle: 'Challenge players',
                    icon: Icons.public,
                    backgroundColor: RoyalColors.green,
                    onPressed: onOnlinePlay,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TitleBadge extends StatelessWidget {
  const _TitleBadge({
    required this.widthFactor,
    required this.maxWidth,
  });

  final double widthFactor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nameWidth = (constraints.maxWidth * widthFactor)
            .clamp(200.0, maxWidth)
            .toDouble();

        return Image.asset(
          gameNameAsset,
          width: nameWidth,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
