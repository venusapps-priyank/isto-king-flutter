import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  static const _maxWidth = 340.0;
  static const _barHeight = 72.0;
  static const _borderWidth = 2.5;
  static const _circleSize = 72.0;
  static const _circleBorderWidth = 1.8;
  static const _barColor = Color(0xFF720B07);
  static const _circleGradientTop = Color(0xFFE32622);
  static const _circleGradientBottom = Color(0xFF4A0505);
  static const _borderColor = Color(0xFFE8C06A);
  static const _barTopInset = 18.0;
  static const _circleTop = 0.0;
  static const _inactiveNavColor = Color(0xFFF9E9C7);
  static const _activeNavColor = Color(0xFFFFE39D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final widthScale = (availableWidth / _maxWidth)
                .clamp(0.68, 1.0)
                .toDouble();
            final controlScale = (availableWidth / _maxWidth)
                .clamp(0.78, 1.0)
                .toDouble();
            final minWidth = math.min(220.0, availableWidth);
            final width = (availableWidth * widthScale)
                .clamp(minWidth, availableWidth)
                .toDouble();
            final barHeight = _barHeight * controlScale;
            final circleSize = _circleSize * controlScale;
            final barTopInset = _barTopInset * controlScale;
            final canvasHeight = barTopInset + barHeight;

            return SizedBox(
              height: canvasHeight,
              child: Center(
                child: SizedBox(
                  width: width,
                  height: canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: barTopInset,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _barColor,
                            borderRadius: BorderRadius.circular(barHeight / 2),
                            border: Border.all(
                              color: _borderColor,
                              width: _borderWidth * controlScale,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: barTopInset,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: _NavItem(
                                icon: Icons.people_alt,
                                label: 'SOCIAL',
                                scale: controlScale,
                              ),
                            ),
                            SizedBox(width: circleSize),
                            Expanded(
                              child: _NavItem(
                                icon: Icons.shopping_bag,
                                label: 'STORE',
                                scale: controlScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: _circleTop,
                        left: (width - circleSize) / 2,
                        width: circleSize,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActiveNavCircle(
                              size: circleSize,
                              borderColor: _borderColor,
                              borderWidth: _circleBorderWidth * controlScale,
                            ),
                            Transform.translate(
                              offset: Offset(0, -10 * controlScale),
                              child: Text(
                                'HOME',
                                style: TextStyle(
                                  fontSize: 10 * controlScale,
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
                ),
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
    required this.borderColor,
    required this.borderWidth,
  });

  final double size;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActiveCircleBorderPainter(
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
        child: Center(
          child: Icon(
            Icons.home,
            size: size * 0.53,
            color: HomeBottomNavBar._inactiveNavColor,
          ),
        ),
      ),
    );
  }
}

class _ActiveCircleBorderPainter extends CustomPainter {
  const _ActiveCircleBorderPainter({
    required this.borderColor,
    required this.borderWidth,
  });

  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HomeBottomNavBar._circleGradientTop,
        Color.lerp(
          HomeBottomNavBar._circleGradientTop,
          HomeBottomNavBar._circleGradientBottom,
          0.42,
        )!,
        HomeBottomNavBar._circleGradientBottom,
      ],
      stops: const [0.0, 0.38, 1.0],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = gradient.createShader(bounds),
    );

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
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 30 * scale, color: HomeBottomNavBar._activeNavColor),
        SizedBox(height: 3 * scale),
        Text(
          label,
          style: TextStyle(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            color: HomeBottomNavBar._activeNavColor,
          ),
        ),
      ],
    );
  }
}
