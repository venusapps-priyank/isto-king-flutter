import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

enum HomeNavTab { rules, home, store }

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    this.selectedTab = HomeNavTab.home,
    this.onTabSelected,
    super.key,
  });

  final HomeNavTab selectedTab;
  final ValueChanged<HomeNavTab>? onTabSelected;

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
  static const _animationDuration = Duration(milliseconds: 260);

  static double _hiddenCircleTop(double barTopInset, double barHeight) {
    return barTopInset + barHeight * 0.35;
  }

  static (double left, double width) slotBoundsForTab(
    HomeNavTab tab,
    double width,
    double circleSize,
  ) {
    final sideWidth = (width - circleSize) / 2;
    return switch (tab) {
      HomeNavTab.rules => (0.0, sideWidth),
      HomeNavTab.home => (sideWidth, circleSize),
      HomeNavTab.store => (sideWidth + circleSize, sideWidth),
    };
  }

  static IconData iconForTab(HomeNavTab tab) {
    return switch (tab) {
      HomeNavTab.rules => Icons.menu_book,
      HomeNavTab.home => Icons.home,
      HomeNavTab.store => Icons.shopping_bag,
    };
  }

  static String labelForTab(HomeNavTab tab) {
    return switch (tab) {
      HomeNavTab.rules => 'RULES',
      HomeNavTab.home => 'HOME',
      HomeNavTab.store => 'STORE',
    };
  }

  static double inactiveLabelHeight(double scale) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'HOME',
        style: TextStyle(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.height;
  }

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
            final hiddenCircleTop = _hiddenCircleTop(barTopInset, barHeight);

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
                      ...HomeNavTab.values.map((tab) {
                        final slotBounds =
                            slotBoundsForTab(tab, width, circleSize);
                        return _AnimatedTabSlot(
                          tab: tab,
                          isSelected: tab == selectedTab,
                          slotLeft: slotBounds.$1,
                          slotWidth: slotBounds.$2,
                          canvasHeight: canvasHeight,
                          barTopInset: barTopInset,
                          barHeight: barHeight,
                          circleSize: circleSize,
                          hiddenCircleTop: hiddenCircleTop,
                          controlScale: controlScale,
                          borderColor: _borderColor,
                          borderWidth: _circleBorderWidth * controlScale,
                          onTap: () => onTabSelected?.call(tab),
                        );
                      }),
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

class _AnimatedTabSlot extends StatefulWidget {
  const _AnimatedTabSlot({
    required this.tab,
    required this.isSelected,
    required this.slotLeft,
    required this.slotWidth,
    required this.canvasHeight,
    required this.barTopInset,
    required this.barHeight,
    required this.circleSize,
    required this.hiddenCircleTop,
    required this.controlScale,
    required this.borderColor,
    required this.borderWidth,
    this.onTap,
  });

  final HomeNavTab tab;
  final bool isSelected;
  final double slotLeft;
  final double slotWidth;
  final double canvasHeight;
  final double barTopInset;
  final double barHeight;
  final double circleSize;
  final double hiddenCircleTop;
  final double controlScale;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  State<_AnimatedTabSlot> createState() => _AnimatedTabSlotState();
}

class _AnimatedTabSlotState extends State<_AnimatedTabSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: HomeBottomNavBar._animationDuration,
      vsync: this,
      value: widget.isSelected ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedTabSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.controlScale;
    final inactiveIconSize = 30 * scale;
    final activeIconSize = widget.circleSize * 0.53;
    final inactiveGap = 3 * scale;
    final inactiveLabelHeight = HomeBottomNavBar.inactiveLabelHeight(scale);
    final inactiveContentHeight =
        inactiveIconSize + inactiveGap + inactiveLabelHeight;
    final inactiveBlockTop =
        widget.barTopInset + (widget.barHeight - inactiveContentHeight) / 2;
    final inactiveIconTop = inactiveBlockTop;
    final inactiveLabelTop = inactiveBlockTop + inactiveIconSize + inactiveGap;
    final activeIconTop = widget.circleSize * 0.235;
    final activeLabelTop = widget.circleSize - 10 * scale;
    final circleInsetLeft = (widget.slotWidth - widget.circleSize) / 2;

    return Positioned(
      left: widget.slotLeft,
      top: 0,
      width: widget.slotWidth,
      height: widget.canvasHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final circleProgress = Curves.easeOutCubic.transform(t);
            final contentProgress = Curves.easeInOutCubic.transform(t);
            final circleTop = lerpDouble(
              widget.hiddenCircleTop,
              HomeBottomNavBar._circleTop,
              circleProgress,
            )!;
            final circleOpacity = Curves.easeIn.transform(t);
            final circleScale = lerpDouble(0.78, 1, circleProgress)!;
            final iconTop =
                lerpDouble(inactiveIconTop, activeIconTop, contentProgress)!;
            final labelTop =
                lerpDouble(inactiveLabelTop, activeLabelTop, contentProgress)!;
            final iconSize =
                lerpDouble(inactiveIconSize, activeIconSize, contentProgress)!;
            final contentColor = Color.lerp(
              HomeBottomNavBar._inactiveNavColor,
              HomeBottomNavBar._activeNavColor,
              contentProgress,
            )!;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: circleTop,
                  left: circleInsetLeft,
                  width: widget.circleSize,
                  height: widget.circleSize,
                  child: Opacity(
                    opacity: circleOpacity,
                    child: Transform.scale(
                      scale: circleScale,
                      child: CustomPaint(
                        size: Size(widget.circleSize, widget.circleSize),
                        painter: _ActiveCircleBorderPainter(
                          borderColor: widget.borderColor,
                          borderWidth: widget.borderWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: iconTop,
                  left: 0,
                  right: 0,
                  height: iconSize,
                  child: Icon(
                    HomeBottomNavBar.iconForTab(widget.tab),
                    size: iconSize,
                    color: contentColor,
                  ),
                ),
                Positioned(
                  top: labelTop,
                  left: 0,
                  right: 0,
                  child: Text(
                    HomeBottomNavBar.labelForTab(widget.tab),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      color: contentColor,
                    ),
                  ),
                ),
              ],
            );
          },
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
