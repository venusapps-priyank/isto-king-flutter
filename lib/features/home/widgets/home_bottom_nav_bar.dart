import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  static const _maxWidth = 340.0;
  static const _barHeight = 72.0;
  static const _borderWidth = 4.0;
  static const _circleSize = 72.0;
  static const _circleBorderWidth = 2.2;
  static const _barColor = Color(0xFF720B07);
  static const _borderColor = Color(0xFFE8C06A);
  static const _barTopInset = 18.0;
  static const _circleTop = 0.0;
  static const _inactiveNavColor = Color(0xFFF9E9C7);
  static const _activeNavColor = Color(0xFFFFE39D);
  static const _canvasHeight = _barTopInset + _barHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SizedBox(
              height: _canvasHeight,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: _barTopInset,
                    left: 0,
                    right: 0,
                    height: _barHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _barColor,
                        borderRadius: BorderRadius.circular(_barHeight / 2),
                        border: Border.all(
                          color: _borderColor,
                          width: _borderWidth,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: _barTopInset,
                    left: 0,
                    right: 0,
                    height: _barHeight,
                    child: Row(
                      children: const [
                        Expanded(
                          child: _NavItem(
                            icon: Icons.people_alt,
                            label: 'SOCIAL',
                          ),
                        ),
                        SizedBox(width: _circleSize),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.shopping_bag,
                            label: 'STORE',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: _circleTop,
                    left: (width - _circleSize) / 2,
                    width: _circleSize,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActiveNavCircle(
                          size: _circleSize,
                          barColor: _barColor,
                          borderColor: _borderColor,
                          borderWidth: _circleBorderWidth,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: const Text(
                            'HOME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                              color: _inactiveNavColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ActiveNavCircle extends StatelessWidget {
  const _ActiveNavCircle({
    required this.size,
    required this.barColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final double size;
  final Color barColor;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActiveCircleBorderPainter(
          fillColor: barColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
        child: Center(
          child: Icon(
            Icons.home,
            size: 38,
            color: HomeBottomNavBar._inactiveNavColor,
          ),
        ),
      ),
    );
  }
}

class _ActiveCircleBorderPainter extends CustomPainter {
  const _ActiveCircleBorderPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, Paint()..color = fillColor);

    final arcRect = Rect.fromCircle(
      center: center,
      radius: radius - borderWidth / 2,
    );
    canvas.drawArc(
      arcRect,
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
  bool shouldRepaint(covariant _ActiveCircleBorderPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: HomeBottomNavBar._activeNavColor),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            color: HomeBottomNavBar._activeNavColor,
          ),
        ),
      ],
    );
  }
}
