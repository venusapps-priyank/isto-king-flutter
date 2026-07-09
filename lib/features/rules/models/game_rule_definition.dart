enum GameRuleControlType { toggle, checkbox }

enum GameRuleIconType {
  cowrie,
  redToken,
  greenToken,
  pot,
  shield,
  overlappingTokens,
  dice,
}

class GameRuleDefinition {
  const GameRuleDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.controlType,
    required this.iconType,
  });

  final String id;
  final String title;
  final String description;
  final GameRuleControlType controlType;
  final GameRuleIconType iconType;
}
