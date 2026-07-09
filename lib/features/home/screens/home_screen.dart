import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/avatar_assets.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/widgets/edit_player_dialog.dart';
import 'package:isto_king/features/home/widgets/game_setup_dialog.dart';
import 'package:isto_king/features/home/widgets/home_cta_button.dart';
import 'package:isto_king/features/settings/widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.profile = UserProfile.defaultProfile,
    this.onProfileChanged,
    this.embedded = false,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile>? onProfileChanged;
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
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: layout.scrollPadding,
                          child: Column(
                            children: [
                              SizedBox(height: layout.topGap),
                              _TopProfileBar(
                                profile: _profile,
                                onEditProfileTap: _onEditProfileTap,
                                onSettingsTap: () =>
                                    SettingsDialog.show(context),
                              ),
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
                                onPlayNow: () => GameSetupDialog.show(
                                  context,
                                  profile: _profile,
                                ),
                              ),
                              if (widget.embedded)
                                SizedBox(height: layout.bottomGap),
                            ],
                          ),
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
    required this.scrollPadding,
    required this.bottomNavPadding,
    required this.topGap,
    required this.profileTitleGap,
    required this.titleBoardGap,
    required this.boardActionGap,
    required this.actionButtonGap,
    required this.boardMaxWidth,
    required this.boardMaxHeight,
    required this.bottomGap,
  });

  final EdgeInsets scrollPadding;
  final EdgeInsets bottomNavPadding;
  final double topGap;
  final double profileTitleGap;
  final double titleBoardGap;
  final double boardActionGap;
  final double actionButtonGap;
  final double boardMaxWidth;
  final double boardMaxHeight;
  final double bottomGap;

  factory _HomeLayout.from(
    BoxConstraints constraints, {
    bool embedded = false,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortHeight = height < 720;
    final compactWidth = width < 360;
    final narrowWidth = width < 430;
    final gapScale = (height / 760).clamp(0.78, 1.08).toDouble();
    final horizontalPadding = (width * 0.036).clamp(10.0, 16.0).toDouble();
    final bottomNavSidePadding = compactWidth
        ? (width * 0.16).clamp(42.0, 60.0).toDouble()
        : narrowWidth
            ? (width * 0.13).clamp(42.0, 56.0).toDouble()
            : (width * 0.095).clamp(32.0, 42.0).toDouble();
    final bottomNavBottomPadding = shortHeight
        ? (height * 0.012).clamp(7.0, 10.0).toDouble()
        : (height * 0.01).clamp(8.0, 12.0).toDouble();

    return _HomeLayout(
      scrollPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        shortHeight ? 8 : 24,
        horizontalPadding,
        shortHeight ? 4 : 0,
      ),
      bottomNavPadding: EdgeInsets.fromLTRB(
        bottomNavSidePadding,
        shortHeight ? 6 : 10,
        bottomNavSidePadding,
        bottomNavBottomPadding,
      ),
      topGap: (shortHeight ? 4 : 8) * gapScale,
      profileTitleGap: (shortHeight ? 12 : 18) * gapScale,
      titleBoardGap: (shortHeight ? 10 : 16) * gapScale,
      boardActionGap: (shortHeight ? 12 : 16) * gapScale,
      actionButtonGap: (shortHeight ? 12 : 14) * gapScale,
      boardMaxWidth: width - horizontalPadding * 2,
      boardMaxHeight: (height * (shortHeight ? 0.28 : 0.35))
          .clamp(compactWidth ? 190.0 : 220.0, 330.0)
          .toDouble(),
      bottomGap: embedded ? (shortHeight ? 100.0 : 112.0) : 0,
    );
  }
}

class _HomeActionButtons extends StatelessWidget {
  const _HomeActionButtons({
    required this.buttonGap,
    required this.onPlayNow,
  });

  final double buttonGap;
  final VoidCallback onPlayNow;

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
                  const HomeCtaButton(
                    expanded: true,
                    label: 'PASS & PLAY',
                    subtitle: 'Play with friends',
                    icon: Icons.people_outlined,
                    backgroundColor: RoyalColors.yellow,
                  ),
                  SizedBox(width: secondaryGap),
                  const HomeCtaButton(
                    expanded: true,
                    label: 'ONLINE',
                    subtitle: 'Challenge players',
                    icon: Icons.public,
                    backgroundColor: RoyalColors.green,
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

class _TopProfileBar extends StatelessWidget {
  const _TopProfileBar({
    required this.profile,
    required this.onEditProfileTap,
    required this.onSettingsTap,
  });

  final UserProfile profile;
  final VoidCallback onEditProfileTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final gap = compact ? 6.0 : 8.0;

        return Row(
          children: [
            _ProfileIdentity(
              compact: compact,
              profile: profile,
              onEditTap: onEditProfileTap,
            ),
            SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
            const CoinBalancePill(),
            SizedBox(width: gap),
            _SettingsButton(
              onTap: onSettingsTap,
              size: compact ? 34 : 36,
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

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.compact,
    required this.profile,
    required this.onEditTap,
  });

  final bool compact;
  final UserProfile profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = compact ? 23.0 : 28.0;
    final editSize = compact ? 19.0 : 22.0;
    final editIconSize = compact ? 11.0 : 13.0;
    final textGap = compact ? 7.0 : 10.0;
    final nameSize = compact ? 15.0 : 18.0;
    final levelSize = compact ? 9.0 : 10.0;
    final progressWidth = compact ? 88.0 : 116.0;
    final progressHeight = compact ? 6.0 : 8.0;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEditTap,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFFE6C8A1),
                  backgroundImage: AssetImage(profile.avatarAsset),
                ),
                Positioned(
                  right: -2,
                  bottom: -1,
                  child: Container(
                    height: editSize,
                    width: editSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8ECD2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD8B98F),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: editIconSize,
                      color: RoyalColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: textGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                fontSize: nameSize,
                fontWeight: FontWeight.w900,
                height: 0.9,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Level 12',
              style: TextStyle(
                fontSize: levelSize,
                fontWeight: FontWeight.w700,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: compact ? 4 : 6),
            SizedBox(
              width: progressWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: 0.48,
                  minHeight: progressHeight,
                  backgroundColor: const Color(0xFFE8D6B3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(profile.themeColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.58;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DC),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD8B98F),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.brown.withValues(alpha: 0.16),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            height: size,
            width: size,
            child: Center(
              child: Icon(
                Icons.settings,
                size: iconSize,
                color: RoyalColors.darkBrown,
              ),
            ),
          ),
        ),
      ),
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
