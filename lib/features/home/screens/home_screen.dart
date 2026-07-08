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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: ScreenOrnamentPainter(
                  topCornerScale: 0.5,
                  bottomCornerScale: 1.38,
                  bottomConnectorHeight: 18,
                ),
              ),
            ),
            const _BottomCorner(isLeft: true),
            const _BottomCorner(isLeft: false),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 28, 14, 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _TopProfileBar(onNotificationTap: () {}),
                          const SizedBox(height: 14),
                          const _TitleBadge(),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 330),
                            child: Image.asset(
                              HomeScreen._boardAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _HomeActionButtons(
                            onPlayNow: () => GameSetupDialog.show(context),
                          ),
                          const SizedBox(height: 12),
                          const _UtilityStrip(),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: HomeBottomNavBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionButtons extends StatelessWidget {
  const _HomeActionButtons({required this.onPlayNow});

  final VoidCallback onPlayNow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final primaryInset = (width * 0.13).clamp(12.0, 52.0);
        final secondaryInset = (width * 0.09).clamp(8.0, 40.0);
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
            const SizedBox(height: 10),
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
    return Row(
      children: [
        const _ProfileIdentity(),
        const SizedBox(width: 8),
        const Expanded(child: SizedBox.shrink()),
        const CoinBalancePill(),
        const SizedBox(width: 8),
        _NotificationButton(onTap: onNotificationTap),
      ],
    );
  }
}

class _TitleBadge extends StatelessWidget {
  const _TitleBadge();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5DF), Color(0xFFF6E3C0)],
          ),
          border: Border.all(color: const Color(0xFF8D4317), width: 2.2),
          boxShadow: [
            BoxShadow(
              color: RoyalColors.darkRed.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FAMILY',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: RoyalColors.darkRed,
                  height: 0.85,
                ),
              ),
              Text(
                'GAME TIME',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: RoyalColors.darkRed,
                  height: 0.85,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Fun · Together · Forever',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: RoyalColors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFE6C8A1),
              backgroundImage: AssetImage(HomeScreen._avatarAsset),
            ),
            Positioned(
              right: -2,
              bottom: -1,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8ECD2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD8B98F),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 13,
                  color: RoyalColors.brown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 0.9,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Level 12',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: 6),
            SizedBox(
              width: 116,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: 0.48,
                  minHeight: 8,
                  backgroundColor: Color(0xFFE8D6B3),
                  valueColor: AlwaysStoppedAnimation<Color>(RoyalColors.yellow),
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
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 36,
          width: 36,
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
                height: 36,
                width: 36,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 0.5),
                    child: const Icon(
                      Icons.notifications,
                      size: 21,
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
            width: 8,
            height: 8,
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
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7E8CC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8C06A),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.36),
                blurRadius: 10,
                spreadRadius: -1,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UtilityItem(icon: Icons.emoji_events, label: 'LEADERBOARD'),
              VerticalDivider(indent: 14, endIndent: 14, width: 1),
              _UtilityItem(icon: Icons.menu_book, label: 'RULES'),
              VerticalDivider(indent: 14, endIndent: 14, width: 1),
              _UtilityItem(icon: Icons.inventory_2, label: 'INVENTORY'),
              VerticalDivider(indent: 14, endIndent: 14, width: 1),
              _UtilityItem(icon: Icons.settings, label: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: RoyalColors.darkRed),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: RoyalColors.darkBrown,
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
    const offset = -_imageSize / 2;

    return Positioned(
      left: isLeft ? offset : null,
      right: isLeft ? null : offset,
      bottom: offset,
      width: _imageSize,
      height: _imageSize,
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
