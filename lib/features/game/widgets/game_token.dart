import 'dart:math' as math;

import 'package:flutter/material.dart';

class GameToken extends StatefulWidget {
  const GameToken({
    required this.color,
    required this.size,
    required this.isMovable,
    required this.semanticLabel,
    this.showMovableHighlight = true,
    this.onTap,
    super.key,
  });

  final Color color;
  final double size;
  final bool isMovable;
  final String semanticLabel;
  final bool showMovableHighlight;
  final VoidCallback? onTap;

  @override
  State<GameToken> createState() => _GameTokenState();
}

class _GameTokenState extends State<GameToken>
    with SingleTickerProviderStateMixin {
  static const _pulseDuration = Duration(milliseconds: 900);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _syncPulseAnimation();
  }

  @override
  void didUpdateWidget(GameToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMovable != oldWidget.isMovable ||
        widget.showMovableHighlight != oldWidget.showMovableHighlight) {
      _syncPulseAnimation();
    }
  }

  void _syncPulseAnimation() {
    if (widget.isMovable && widget.showMovableHighlight) {
      _pulseController.repeat(reverse: true);
      return;
    }

    _pulseController.stop();
    _pulseController.animateTo(
      0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.isMovable,
      enabled: widget.isMovable,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.isMovable ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final isHighlighted =
                widget.isMovable && widget.showMovableHighlight;
            final pulse = isHighlighted ? _pulseAnimation.value : 0.0;
            final scale = 1.0 + pulse * 0.14;
            return Transform.scale(
              scale: scale,
              child: SizedBox.square(
                dimension: widget.size,
                child: CustomPaint(
                  painter: _GameTokenPainter(
                    color: widget.color,
                    isHighlighted: isHighlighted,
                    pulse: pulse,
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

class _GameTokenPainter extends CustomPainter {
  const _GameTokenPainter({
    required this.color,
    required this.isHighlighted,
    required this.pulse,
  });

  final Color color;
  final bool isHighlighted;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    if (isHighlighted) {
      final ringOpacity = 0.55 + pulse * 0.45;
      final outerRingColor = Color.lerp(color, Colors.white, 0.18)!;
      final innerRingColor = Color.lerp(color, Colors.white, 0.62)!;
      canvas.drawCircle(
        center,
        radius * (0.98 + pulse * 0.06),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * (0.14 + pulse * 0.06)
          ..color = outerRingColor.withValues(alpha: ringOpacity),
      );
      canvas.drawCircle(
        center,
        radius * 0.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.08
          ..color = innerRingColor.withValues(alpha: ringOpacity),
      );
    }

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.82)),
      Colors.black,
      2,
      true,
    );
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()..color = Color.lerp(color, Colors.black, 0.16)!,
    );
    canvas.drawCircle(
      center.translate(-radius * 0.12, -radius * 0.12),
      radius * 0.64,
      Paint()..color = color,
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.14
        ..color = Colors.white,
    );
    _drawStar(canvas, center, radius * 0.4);
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final pointRadius = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * pointRadius,
        center.dy + math.sin(angle) * pointRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GameTokenPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isHighlighted != isHighlighted ||
        oldDelegate.pulse != pulse;
  }
}
