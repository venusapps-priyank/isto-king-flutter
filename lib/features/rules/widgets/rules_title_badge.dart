import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class RulesTitleBadge extends StatelessWidget {
  const RulesTitleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 330).clamp(0.75, 1.0).toDouble();

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Ornament(scale: scale),
              SizedBox(height: 6 * scale),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28 * scale),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF5DF), Color(0xFFF6E3C0)],
                  ),
                  border: Border.all(color: const Color(0xFF8D4317), width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: RoyalColors.darkRed.withValues(alpha: 0.22),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 36 * scale,
                    vertical: 10 * scale,
                  ),
                  child: Text(
                    'RULES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.w900,
                      color: RoyalColors.darkRed,
                      height: 0.9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54 * scale,
      height: 22 * scale,
      child: CustomPaint(
        painter: _OrnamentPainter(scale: scale),
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  const _OrnamentPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = RoyalColors.red;

    final offsets = [
      Offset(0, -6 * scale),
      Offset(-10 * scale, -2 * scale),
      Offset(10 * scale, -2 * scale),
      Offset(-6 * scale, 5 * scale),
      Offset(6 * scale, 5 * scale),
    ];

    for (final offset in offsets) {
      canvas.drawCircle(center + offset, 4.5 * scale, petalPaint);
    }

    canvas.drawCircle(
      center,
      5 * scale,
      Paint()..color = RoyalColors.gold,
    );
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter oldDelegate) => false;
}
