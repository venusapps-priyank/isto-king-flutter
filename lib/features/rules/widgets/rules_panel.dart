import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/data/rules_catalog.dart';
import 'package:istochaka/features/rules/models/game_rules_settings.dart';
import 'package:istochaka/features/rules/widgets/rules_row.dart';

class RulesPanel extends StatelessWidget {
  const RulesPanel({
    required this.settings,
    required this.onSettingChanged,
    super.key,
  });

  final GameRulesSettings settings;
  final void Function(String settingKey, bool value) onSettingChanged;

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var s = 0; s < gameRuleSections.length; s++) ...[
                  if (s > 0) const SizedBox(height: 4),
                  RulesSectionHeading(title: gameRuleSections[s].title),
                  for (var r = 0; r < gameRuleSections[s].rules.length; r++) ...[
                    Builder(
                      builder: (context) {
                        final rule = gameRuleSections[s].rules[r];
                        final settingKey = rule.settingKey;
                        final isCheckboxEnabled = settingKey == null
                            ? false
                            : settings.isSettingToggleEnabled(settingKey);
                        final isEnabled = settingKey == null
                            ? true
                            : settings.isSettingActive(settingKey);

                        return RulesRow(
                          rule: rule,
                          iconSize: iconSize,
                          isEnabled: isEnabled,
                          isCheckboxEnabled: isCheckboxEnabled,
                          onEnabledChanged: isCheckboxEnabled
                              ? (value) =>
                                  onSettingChanged(settingKey, value)
                              : null,
                        );
                      },
                    ),
                    if (r < gameRuleSections[s].rules.length - 1)
                      const RulesDivider(),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
