import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/rules/models/game_rule_definition.dart';
import 'package:isto_king/features/rules/widgets/rules_controls.dart';
import 'package:isto_king/features/rules/widgets/rules_rule_icon.dart';

class RulesRow extends StatelessWidget {
  const RulesRow({
    required this.definition,
    required this.value,
    required this.onChanged,
    required this.iconSize,
    super.key,
  });

  final GameRuleDefinition definition;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RulesRuleIcon(iconType: definition.iconType, size: iconSize),
          SizedBox(width: iconSize * 0.22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: RoyalColors.darkBrown,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  definition.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: RoyalColors.brown.withValues(alpha: 0.82),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          switch (definition.controlType) {
            GameRuleControlType.toggle => RulesToggleSwitch(
              value: value,
              onChanged: onChanged,
            ),
            GameRuleControlType.checkbox => RulesCheckbox(
              value: value,
              onChanged: onChanged,
            ),
          },
        ],
      ),
    );
  }
}

class RulesDivider extends StatelessWidget {
  const RulesDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 10,
        child: CustomPaint(
          painter: _DividerPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final linePaint = Paint()
      ..color = RoyalColors.gold.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    final center = Offset(size.width / 2, y);
    final diamond = Path()
      ..moveTo(center.dx, center.dy - 3)
      ..lineTo(center.dx + 3, center.dy)
      ..lineTo(center.dx, center.dy + 3)
      ..lineTo(center.dx - 3, center.dy)
      ..close();

    canvas.drawPath(
      diamond,
      Paint()
        ..color = RoyalColors.gold.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
