import 'dart:math' as math;

import 'package:flutter/material.dart';

enum StoreNavTab { social, home, store }

class StoreBottomNavBar extends StatelessWidget {
  const StoreBottomNavBar({
    required this.selectedTab,
    this.onTabSelected,
    super.key,
  });

  final StoreNavTab selectedTab;
  final ValueChanged<StoreNavTab>? onTabSelected;

  static const _barColor = Color(0xFF720B07);
  static const _borderColor = Color(0xFFE8C06A);
  static const _inactiveColor = Color(0xFFF9E9C7);
  static const _activeColor = Color(0xFFFFE39D);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 360).clamp(0.8, 1.0).toDouble();

        return _MainNavRow(
          scale: scale,
          selectedTab: selectedTab,
          onTabSelected: onTabSelected,
        );
      },
    );
  }
}

class _MainNavRow extends StatelessWidget {
  const _MainNavRow({
    required this.scale,
    required this.selectedTab,
    this.onTabSelected,
  });

  final double scale;
  final StoreNavTab selectedTab;
  final ValueChanged<StoreNavTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final circleSize = 64 * scale;
    final barHeight = 58 * scale;

    return SizedBox(
      height: circleSize + 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: StoreBottomNavBar._barColor,
                borderRadius: BorderRadius.circular(barHeight / 2),
                border: Border.all(
                  color: StoreBottomNavBar._borderColor,
                  width: 2 * scale,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavTap(
                      icon: Icons.people,
                      label: 'Social',
                      isActive: selectedTab == StoreNavTab.social,
                      scale: scale,
                      onTap: () => onTabSelected?.call(StoreNavTab.social),
                    ),
                  ),
                  SizedBox(width: circleSize),
                  Expanded(
                    child: _NavTap(
                      icon: Icons.shopping_bag,
                      label: 'STORE',
                      isActive: selectedTab == StoreNavTab.store,
                      scale: scale,
                      onTap: () => onTabSelected?.call(StoreNavTab.store),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: barHeight - circleSize / 2 - 6 * scale,
            child: _HomeCircle(
              size: circleSize,
              isActive: selectedTab == StoreNavTab.home,
              scale: scale,
              onTap: () => onTabSelected?.call(StoreNavTab.home),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTap extends StatelessWidget {
  const _NavTap({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.scale,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? StoreBottomNavBar._activeColor
        : StoreBottomNavBar._inactiveColor;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24 * scale, color: color),
          SizedBox(height: 2 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 9 * scale,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCircle extends StatelessWidget {
  const _HomeCircle({
    required this.size,
    required this.isActive,
    required this.scale,
    this.onTap,
  });

  final double size;
  final bool isActive;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CirclePainter(
                borderColor: StoreBottomNavBar._borderColor,
                borderWidth: 1.8 * scale,
                isActive: isActive,
              ),
              child: Center(
                child: Icon(
                  Icons.home,
                  size: size * 0.5,
                  color: StoreBottomNavBar._inactiveColor,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -8 * scale),
            child: Text(
              'HOME',
              style: TextStyle(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w900,
                color: isActive
                    ? StoreBottomNavBar._activeColor
                    : StoreBottomNavBar._inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  const _CirclePainter({
    required this.borderColor,
    required this.borderWidth,
    required this.isActive,
  });

  final Color borderColor;
  final double borderWidth;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isActive
          ? const [Color(0xFFE32622), Color(0xFF4A0505)]
          : const [Color(0xFFB01818), Color(0xFF4A0505)],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - borderWidth / 2),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}
