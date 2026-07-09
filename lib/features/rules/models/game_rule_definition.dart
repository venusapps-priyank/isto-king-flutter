enum GameRuleIconType {
  cowrie,
  redToken,
  greenToken,
  yellowToken,
  blueToken,
  pot,
  shield,
  overlappingTokens,
  dice,
  trophy,
  turnOrder,
}

class GameRuleInfo {
  const GameRuleInfo({
    required this.title,
    required this.description,
    required this.iconType,
  });

  final String title;
  final String description;
  final GameRuleIconType iconType;
}

class GameRuleSection {
  const GameRuleSection({
    required this.title,
    required this.rules,
  });

  final String title;
  final List<GameRuleInfo> rules;
}
