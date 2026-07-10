import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/avatar_assets.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
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
  static const _cornerAsset = 'assets/images/corner_mandala.png';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didWarmGameAssets = false;

  UserProfile get _profile => widget.profile;

  static const _gameEntryAssets = [
    ...avatarAssets,
    playTogetherAsset,
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
              bottom: !widget.embedded,
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
                          onSettingsTap: () =>
                              SettingsDialog.show(context),
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
                                    const _TitleBadge(),
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
            ),
          ],
        ),
      ),
    );
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
    final shortHeight = height < 720;
    final veryShortHeight = height < 620;
    final compactWidth = width < 360;
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();

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
        ratio: veryShortHeight ? 0.018 : shortHeight ? 0.024 : 0.032,
        min: veryShortHeight ? 8 : shortHeight ? 12 : 18,
        max: veryShortHeight ? 14 : shortHeight ? 22 : 36,
      ),
      titleBoardGap: _sectionGap(
        height,
        ratio: veryShortHeight ? 0.022 : shortHeight ? 0.03 : 0.042,
        min: veryShortHeight ? 10 : shortHeight ? 14 : 20,
        max: veryShortHeight ? 18 : shortHeight ? 28 : 44,
      ),
      boardActionGap: _sectionGap(
        height,
        ratio: veryShortHeight ? 0.022 : shortHeight ? 0.03 : 0.042,
        min: veryShortHeight ? 10 : shortHeight ? 14 : 20,
        max: veryShortHeight ? 18 : shortHeight ? 28 : 44,
      ),
      actionButtonGap: _sectionGap(
        height,
        ratio: veryShortHeight ? 0.018 : shortHeight ? 0.022 : 0.028,
        min: veryShortHeight ? 8 : shortHeight ? 10 : 14,
        max: veryShortHeight ? 14 : shortHeight ? 18 : 28,
      ),
      boardMaxWidth: width - horizontalPadding * 2,
      boardMaxHeight: (height * (veryShortHeight ? 0.24 : shortHeight ? 0.28 : 0.34))
          .clamp(compactWidth ? 170.0 : 200.0, 330.0)
          .toDouble(),
      bottomGap: embedded ? (shortHeight ? 96.0 : 108.0) : 0,
    );
  }
}

class _HomeActionButtons extends StatelessWidget {
  const _HomeActionButtons({
    required this.buttonGap,
    required this.onPlayNow,
    required this.onPassAndPlay,
    required this.onOnlinePlay,
  });

  final double buttonGap;
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
  const _TitleBadge();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(260.0, 330.0).toDouble();
        final scale = (width / 330).clamp(0.78, 1.0).toDouble();

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30 * scale),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF5DF), Color(0xFFF6E3C0)],
              ),
              border: Border.all(
                color: const Color(0xFF8D4317),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: RoyalColors.darkRed.withValues(alpha: 0.24),
                  blurRadius: 10 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                14 * scale,
                20 * scale,
                12 * scale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME TIME',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 44 * scale,
                      fontWeight: FontWeight.w900,
                      color: RoyalColors.darkRed,
                      height: 0.85,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'Fun · Together · Forever',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: RoyalColors.brown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomCorner extends StatelessWidget {
  const _BottomCorner({required this.isLeft});

  static const _imageSize = 170.0;

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageSize = (screenWidth * 0.42).clamp(126.0, _imageSize).toDouble();
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
            HomeScreen._cornerAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
