import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/screens/isto_game_screen.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/home/widgets/home_cta_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _avatarAsset = 'assets/avatar/avatar-1.png';
  static const _boardAsset = 'assets/images/full-board.png';
  static const _cornerAsset = 'assets/images/corner_mandala.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: ScreenOrnamentPainter()),
            ),
            const _BottomCorner(isLeft: true),
            const _BottomCorner(isLeft: false),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          _TopProfileBar(onNotificationTap: () {}),
                          const SizedBox(height: 14),
                          const _TitleBadge(),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 330),
                            child: Image.asset(
                              _boardAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 52),
                            child: HomeCtaButton(
                              label: 'PLAY NOW',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const IstoGameScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              children: [
                                HomeCtaButton(
                                  expanded: true,
                                  label: 'PASS & PLAY',
                                  subtitle: 'Play with friends',
                                  icon: Icons.people_outlined,
                                  backgroundColor: RoyalColors.yellow,
                                ),
                                SizedBox(width: 8),
                                HomeCtaButton(
                                  expanded: true,
                                  label: 'ONLINE MATCH',
                                  subtitle: 'Challenge players',
                                  icon: Icons.public,
                                  backgroundColor: RoyalColors.green,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _UtilityStrip(),
                          const SizedBox(height: 10),
                          const _BottomNavBar(),
                        ],
                      ),
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
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 0.9,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Level 12',
              style: TextStyle(
                fontSize: 18,
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
        Material(
          color: const Color(0xFFF7EAD0),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              height: 42,
              width: 42,
              child: Icon(
                Icons.notifications_none,
                color: RoyalColors.darkBrown,
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 5,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE22D1B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E8CC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RoyalColors.brown.withValues(alpha: 0.26),
          width: 1.2,
        ),
      ),
      child: const Row(
        children: [
          _UtilityItem(icon: Icons.emoji_events_outlined, label: 'LEADERBOARD'),
          VerticalDivider(indent: 14, endIndent: 14, width: 1),
          _UtilityItem(
            icon: Icons.track_changes_outlined,
            label: 'MISSIONS',
            badge: '3',
          ),
          VerticalDivider(indent: 14, endIndent: 14, width: 1),
          _UtilityItem(icon: Icons.inventory_2_outlined, label: 'INVENTORY'),
          VerticalDivider(indent: 14, endIndent: 14, width: 1),
          _UtilityItem(icon: Icons.settings, label: 'SETTINGS'),
        ],
      ),
    );
  }
}

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({required this.icon, required this.label, this.badge});

  final IconData icon;
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: RoyalColors.darkBrown),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: RoyalColors.darkBrown,
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 12,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFD92A19),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    Widget item({
      required IconData icon,
      required String text,
      bool active = false,
    }) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFFFE39D) : const Color(0xFFF9E9C7),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                color: active
                    ? const Color(0xFFFFE39D)
                    : const Color(0xFFF9E9C7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xFF8B120A),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFE0B16B), width: 1.7),
      ),
      child: Row(
        children: [
          item(icon: Icons.people_alt_outlined, text: 'SOCIAL'),
          item(icon: Icons.home_filled, text: 'HOME', active: true),
          item(icon: Icons.local_mall_outlined, text: 'STORE'),
        ],
      ),
    );
  }
}

class _BottomCorner extends StatelessWidget {
  const _BottomCorner({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    const size = 130.0;
    return Positioned(
      bottom: -size * 0.35,
      left: isLeft ? -size * 0.35 : null,
      right: isLeft ? null : -size * 0.35,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.94,
          child: Image.asset(
            HomeScreen._cornerAsset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
