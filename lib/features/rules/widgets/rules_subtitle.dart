import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';

class RulesSubtitle extends StatelessWidget {
  const RulesSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 330).clamp(0.75, 1.0).toDouble();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          child: Row(
            children: [
              Expanded(child: _DecorativeLine(scale: scale)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: Text(
                  'Customize rules as per your game style',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: RoyalColors.brown.withValues(alpha: 0.9),
                    height: 1.2,
                  ),
                ),
              ),
              Expanded(child: _DecorativeLine(scale: scale)),
            ],
          ),
        );
      },
    );
  }
}

class _DecorativeLine extends StatelessWidget {
  const _DecorativeLine({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10 * scale,
      child: CustomPaint(
        painter: _LinePainter(scale: scale),
        size: Size.infinite,
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final linePaint = Paint()
      ..color = RoyalColors.gold.withValues(alpha: 0.75)
      ..strokeWidth = 1.2 * scale;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    final diamond = Path()
      ..moveTo(size.width / 2, y - 3.5 * scale)
      ..lineTo(size.width / 2 + 3.5 * scale, y)
      ..lineTo(size.width / 2, y + 3.5 * scale)
      ..lineTo(size.width / 2 - 3.5 * scale, y)
      ..close();

    canvas.drawPath(
      diamond,
      Paint()
        ..color = RoyalColors.gold
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => false;
}
