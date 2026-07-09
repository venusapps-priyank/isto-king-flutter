import 'package:isto_king/features/rules/models/game_rule_definition.dart';

const gameRuleSections = [
  GameRuleSection(
    title: 'Cowrie Rolling',
    rules: [
      GameRuleInfo(
        title: 'Roll on Your Turn',
        description:
            'Tap the cowrie shells on your turn to roll. Each game uses 4 shells.',
        iconType: GameRuleIconType.cowrie,
      ),
      GameRuleInfo(
        title: 'Cowrie Values',
        description:
            'Count open shells for your move (1, 2, or 3). All shells closed counts as 8.',
        iconType: GameRuleIconType.cowrie,
      ),
      GameRuleInfo(
        title: 'Extra Turn for 4 or 8',
        description:
            'Rolling 4 or 8 grants an extra turn, even when no token can move.',
        iconType: GameRuleIconType.cowrie,
      ),
    ],
  ),
  GameRuleSection(
    title: 'Movement',
    rules: [
      GameRuleInfo(
        title: 'Four Tokens per Player',
        description:
            'Each player has 4 tokens. All tokens start at home and enter play on any roll.',
        iconType: GameRuleIconType.redToken,
      ),
      GameRuleInfo(
        title: 'Move by Roll Value',
        description:
            'Tokens move along the outer path by the rolled value (1, 2, 3, 4, or 8).',
        iconType: GameRuleIconType.greenToken,
      ),
      GameRuleInfo(
        title: 'Must Kill to Enter Inner Path',
        description:
            'You must capture at least one opponent before entering the inner path to center.',
        iconType: GameRuleIconType.pot,
      ),
      GameRuleInfo(
        title: 'Outer Loop Wrap',
        description:
            'Without a kill, overshooting the outer path wraps you around the outer track.',
        iconType: GameRuleIconType.yellowToken,
      ),
      GameRuleInfo(
        title: 'Extra Turn for Home',
        description:
            'Reaching the center with a token grants an extra turn.',
        iconType: GameRuleIconType.greenToken,
      ),
    ],
  ),
  GameRuleSection(
    title: 'Capturing',
    rules: [
      GameRuleInfo(
        title: 'Capture by Landing',
        description:
            'Land on an opponent\'s cell to capture their tokens. Safe zones are exempt.',
        iconType: GameRuleIconType.redToken,
      ),
      GameRuleInfo(
        title: 'Extra Turn for Kill',
        description:
            'Capturing an opponent grants an extra turn.',
        iconType: GameRuleIconType.redToken,
      ),
      GameRuleInfo(
        title: 'Stack Strength',
        description:
            'More tokens on a cell are harder to capture. Your stack must be stronger to take a cell.',
        iconType: GameRuleIconType.overlappingTokens,
      ),
      GameRuleInfo(
        title: 'Kill Permission Reset',
        description:
            'If all your tokens return home, you must capture again to re-enter the inner path.',
        iconType: GameRuleIconType.pot,
      ),
    ],
  ),
  GameRuleSection(
    title: 'Safe Zones & Stacking',
    rules: [
      GameRuleInfo(
        title: 'Safe Zone (Home Cells)',
        description:
            'Each player\'s home cell is safe — tokens cannot be captured there.',
        iconType: GameRuleIconType.shield,
      ),
      GameRuleInfo(
        title: 'Center Is Safe',
        description:
            'The center cell is also safe. Paired tokens automatically split on safe cells.',
        iconType: GameRuleIconType.shield,
      ),
      GameRuleInfo(
        title: 'Two Tokens in Same Cell',
        description:
            'Multiple tokens from the same player may occupy the same cell.',
        iconType: GameRuleIconType.overlappingTokens,
      ),
    ],
  ),
  GameRuleSection(
    title: 'Paired Tokens',
    rules: [
      GameRuleInfo(
        title: 'Paired Tokens (Play Together)',
        description:
            'Two tokens on the same cell can pair when you roll 2, 4, or 8 and accept the pair prompt.',
        iconType: GameRuleIconType.cowrie,
      ),
      GameRuleInfo(
        title: 'Paired Movement Rule',
        description:
            'Paired tokens move fewer steps: roll 2 → 1 step, roll 4 → 2 steps, roll 8 → 4 steps.',
        iconType: GameRuleIconType.dice,
      ),
      GameRuleInfo(
        title: 'Pair Restrictions',
        description:
            'Tokens cannot pair at home, on safe cells, or at the center.',
        iconType: GameRuleIconType.dice,
      ),
    ],
  ),
  GameRuleSection(
    title: 'Turns & Winning',
    rules: [
      GameRuleInfo(
        title: 'Turn Order',
        description:
            'Play order is Blue → Green → Red → Yellow.',
        iconType: GameRuleIconType.turnOrder,
      ),
      GameRuleInfo(
        title: 'Auto Move',
        description:
            'When only one legal move exists, it is played automatically.',
        iconType: GameRuleIconType.blueToken,
      ),
      GameRuleInfo(
        title: 'How to Win',
        description:
            'Bring all 4 tokens to the center. First to finish wins; others are ranked by finish order.',
        iconType: GameRuleIconType.trophy,
      ),
    ],
  ),
];
