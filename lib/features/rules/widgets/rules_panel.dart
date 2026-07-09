import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/rules_catalog.dart';
import 'package:isto_king/features/rules/models/game_rule_config.dart';
import 'package:isto_king/features/rules/widgets/rules_action_bar.dart';
import 'package:isto_king/features/rules/widgets/rules_row.dart';

class RulesPanel extends StatelessWidget {
  const RulesPanel({
    required this.config,
    required this.onRuleChanged,
    required this.onReset,
    required this.onSave,
    super.key,
  });

  final GameRuleConfig config;
  final void Function(String ruleId, bool value) onRuleChanged;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 360).clamp(0.82, 1.0).toDouble();
        final iconSize = 46 * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8EA), Color(0xFFF6E8C8)],
            ),
            border: Border.all(color: RoyalColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Column(
              children: [
                for (var i = 0; i < gameRuleDefinitions.length; i++) ...[
                  RulesRow(
                    definition: gameRuleDefinitions[i],
                    value: config.valueFor(gameRuleDefinitions[i].id),
                    onChanged: (value) =>
                        onRuleChanged(gameRuleDefinitions[i].id, value),
                    iconSize: iconSize,
                  ),
                  if (i < gameRuleDefinitions.length - 1) const RulesDivider(),
                ],
                const SizedBox(height: 8),
                RulesActionBar(
                  onReset: onReset,
                  onSave: onSave,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
