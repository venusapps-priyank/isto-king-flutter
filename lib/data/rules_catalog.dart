import 'package:isto_king/features/rules/models/game_rule_definition.dart';

const gameRuleDefinitions = [
  GameRuleDefinition(
    id: 'extra_turn_48',
    title: 'Extra Turn for 4 or 8',
    description: 'Rolling 4 or 8 grants an extra turn',
    controlType: GameRuleControlType.toggle,
    iconType: GameRuleIconType.cowrie,
  ),
  GameRuleDefinition(
    id: 'extra_turn_kill',
    title: 'Extra Turn for Kill',
    description: 'Capturing an opponent grants an extra turn',
    controlType: GameRuleControlType.toggle,
    iconType: GameRuleIconType.redToken,
  ),
  GameRuleDefinition(
    id: 'extra_turn_home',
    title: 'Extra Turn for Home',
    description: 'Reaching home grants an extra turn',
    controlType: GameRuleControlType.toggle,
    iconType: GameRuleIconType.greenToken,
  ),
  GameRuleDefinition(
    id: 'must_kill_inner',
    title: 'Must Kill to Enter Inner Circle',
    description: 'A kill is required before entering the inner path',
    controlType: GameRuleControlType.toggle,
    iconType: GameRuleIconType.pot,
  ),
  GameRuleDefinition(
    id: 'safe_zone',
    title: 'Safe Zone (Home Cells)',
    description: 'Home cells protect tokens from capture',
    controlType: GameRuleControlType.checkbox,
    iconType: GameRuleIconType.shield,
  ),
  GameRuleDefinition(
    id: 'two_tokens_same_cell',
    title: 'Two Tokens in Same Cell',
    description: 'Multiple tokens may occupy the same cell',
    controlType: GameRuleControlType.checkbox,
    iconType: GameRuleIconType.overlappingTokens,
  ),
  GameRuleDefinition(
    id: 'paired_tokens',
    title: 'Paired Tokens (Play Together)',
    description: 'Two tokens can pair and move as one unit',
    controlType: GameRuleControlType.checkbox,
    iconType: GameRuleIconType.cowrie,
  ),
  GameRuleDefinition(
    id: 'paired_movement',
    title: 'Paired Movement Rule',
    description: 'Paired tokens use special movement steps',
    controlType: GameRuleControlType.checkbox,
    iconType: GameRuleIconType.dice,
  ),
];
