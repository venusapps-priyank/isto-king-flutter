import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/rules/models/game_rule_definition.dart';
import 'package:isto_king/features/rules/widgets/rules_checkbox.dart';
import 'package:isto_king/features/rules/widgets/rules_rule_icon.dart';

class RulesRow extends StatelessWidget {
  const RulesRow({
    required this.rule,
    required this.iconSize,
    this.isEnabled = true,
    this.onEnabledChanged,
    super.key,
  });

  final GameRuleInfo rule;
  final double iconSize;
  final bool isEnabled;
  final ValueChanged<bool>? onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final descriptionColor = isEnabled
        ? RoyalColors.brown.withValues(alpha: 0.82)
        : RoyalColors.brown.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RulesRuleIcon(iconType: rule.iconType, size: iconSize),
          SizedBox(width: iconSize * 0.22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isEnabled
                        ? RoyalColors.darkBrown
                        : RoyalColors.darkBrown.withValues(alpha: 0.55),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rule.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: descriptionColor,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (rule.isToggleable) ...[
            const SizedBox(width: 8),
            RulesCheckbox(
              value: isEnabled,
              onChanged: onEnabledChanged ?? (_) {},
            ),
          ],
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

class RulesSectionHeading extends StatelessWidget {
  const RulesSectionHeading({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: RoyalColors.darkRed.withValues(alpha: 0.9),
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
