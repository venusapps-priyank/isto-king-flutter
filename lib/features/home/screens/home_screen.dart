import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/home/widgets/game_setup_dialog.dart';
import 'package:isto_king/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:isto_king/features/home/widgets/home_cta_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const _avatarAsset = 'assets/avatar/avatar-1.png';
  static const _boardAsset = 'assets/images/full-board.png';
  static const _cornerAsset = 'assets/images/corner_mandala.png';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didWarmGameAssets = false;

  static const _gameEntryAssets = [
    HomeScreen._avatarAsset,
    'assets/avatar/avatar-f-1.png',
    'assets/avatar/avatar-2.png',
    'assets/avatar/avatar-f-2.png',
    'assets/images/corner_mandala.png',
    'assets/images/cowrie_open.png',
    'assets/images/cowrie_closed.png',
    'assets/images/rank_crown_1.png',
  ];

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = _HomeLayout.from(constraints);

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: layout.scrollPadding,
                          child: Column(
                            children: [
                              SizedBox(height: layout.topGap),
                              _TopProfileBar(onNotificationTap: () {}),
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
                                    GameSetupDialog.show(context),
                              ),
                              SizedBox(height: layout.actionUtilityGap),
                              const _UtilityStrip(),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: layout.bottomNavPadding,
                        child: const HomeBottomNavBar(),
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
    required this.actionUtilityGap,
    required this.boardMaxWidth,
    required this.boardMaxHeight,
  });

  final EdgeInsets scrollPadding;
  final EdgeInsets bottomNavPadding;
  final double topGap;
  final double profileTitleGap;
  final double titleBoardGap;
  final double boardActionGap;
  final double actionButtonGap;
  final double actionUtilityGap;
  final double boardMaxWidth;
  final double boardMaxHeight;

  factory _HomeLayout.from(BoxConstraints constraints) {
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
      actionUtilityGap: (shortHeight ? 12 : 16) * gapScale,
      boardMaxWidth: width - horizontalPadding * 2,
      boardMaxHeight: (height * (shortHeight ? 0.28 : 0.35))
          .clamp(compactWidth ? 190.0 : 220.0, 330.0)
          .toDouble(),
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
                    label: 'ONLINE MATCH',
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
  const _TopProfileBar({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final gap = compact ? 6.0 : 8.0;

        return Row(
          children: [
            _ProfileIdentity(compact: compact),
            SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
            const CoinBalancePill(),
            SizedBox(width: gap),
            _NotificationButton(
              onTap: onNotificationTap,
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
  const _ProfileIdentity({required this.compact});

  final bool compact;

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
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: const Color(0xFFE6C8A1),
              backgroundImage: const AssetImage(HomeScreen._avatarAsset),
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
        SizedBox(width: textGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player',
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
                      const AlwaysStoppedAnimation<Color>(RoyalColors.yellow),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.58;
    final badgeSize = size * 0.22;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                  child: Transform.translate(
                    offset: const Offset(0, 0.5),
                    child: Icon(
                      Icons.notifications,
                      size: iconSize,
                      color: RoyalColors.darkBrown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 3,
          top: 2,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: const BoxDecoration(
              color: Color(0xFFE22D1B),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _UtilityStrip extends StatelessWidget {
  const _UtilityStrip();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final scale = (width / 400).clamp(0.82, 1.0).toDouble();
            final height = 72 * scale;
            final dividerInset = 14 * scale;

            return Container(
              height: height,
              padding: EdgeInsets.symmetric(
                horizontal: 6 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7E8CC),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(
                  color: const Color(0xFFE8C06A),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: RoyalColors.brown.withValues(alpha: 0.36),
                    blurRadius: 10 * scale,
                    spreadRadius: -1,
                    offset: Offset(0, 7 * scale),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _UtilityItem(
                    icon: Icons.emoji_events,
                    label: 'LEADERBOARD',
                    scale: scale,
                  ),
                  VerticalDivider(
                    indent: dividerInset,
                    endIndent: dividerInset,
                    width: 1,
                  ),
                  _UtilityItem(
                    icon: Icons.menu_book,
                    label: 'RULES',
                    scale: scale,
                  ),
                  VerticalDivider(
                    indent: dividerInset,
                    endIndent: dividerInset,
                    width: 1,
                  ),
                  _UtilityItem(
                    icon: Icons.inventory_2,
                    label: 'INVENTORY',
                    scale: scale,
                  ),
                  VerticalDivider(
                    indent: dividerInset,
                    endIndent: dividerInset,
                    width: 1,
                  ),
                  _UtilityItem(
                    icon: Icons.settings,
                    label: 'SETTINGS',
                    scale: scale,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36 * scale, color: RoyalColors.darkRed),
          SizedBox(height: 2 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10 * scale,
                fontWeight: FontWeight.w900,
                color: RoyalColors.darkBrown,
              ),
            ),
          ),
        ],
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
