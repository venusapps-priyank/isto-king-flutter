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
    this.settingKey,
  });

  final String title;
  final String description;
  final GameRuleIconType iconType;
  final String? settingKey;

  bool get isToggleable => settingKey != null;
}

class GameRuleSection {
  const GameRuleSection({
    required this.title,
    required this.rules,
  });

  final String title;
  final List<GameRuleInfo> rules;
}
