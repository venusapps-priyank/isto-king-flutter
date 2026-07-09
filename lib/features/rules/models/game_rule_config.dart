class GameRuleConfig {
  const GameRuleConfig({
    this.extraTurnFor48 = true,
    this.extraTurnForKill = true,
    this.extraTurnForHome = true,
    this.mustKillForInner = true,
    this.safeZone = true,
    this.twoTokensSameCell = true,
    this.pairedTokens = true,
    this.pairedMovementRule = true,
  });

  final bool extraTurnFor48;
  final bool extraTurnForKill;
  final bool extraTurnForHome;
  final bool mustKillForInner;
  final bool safeZone;
  final bool twoTokensSameCell;
  final bool pairedTokens;
  final bool pairedMovementRule;

  static const defaults = GameRuleConfig();

  GameRuleConfig copyWith({
    bool? extraTurnFor48,
    bool? extraTurnForKill,
    bool? extraTurnForHome,
    bool? mustKillForInner,
    bool? safeZone,
    bool? twoTokensSameCell,
    bool? pairedTokens,
    bool? pairedMovementRule,
  }) {
    return GameRuleConfig(
      extraTurnFor48: extraTurnFor48 ?? this.extraTurnFor48,
      extraTurnForKill: extraTurnForKill ?? this.extraTurnForKill,
      extraTurnForHome: extraTurnForHome ?? this.extraTurnForHome,
      mustKillForInner: mustKillForInner ?? this.mustKillForInner,
      safeZone: safeZone ?? this.safeZone,
      twoTokensSameCell: twoTokensSameCell ?? this.twoTokensSameCell,
      pairedTokens: pairedTokens ?? this.pairedTokens,
      pairedMovementRule: pairedMovementRule ?? this.pairedMovementRule,
    );
  }

  bool valueFor(String ruleId) {
    return switch (ruleId) {
      'extra_turn_48' => extraTurnFor48,
      'extra_turn_kill' => extraTurnForKill,
      'extra_turn_home' => extraTurnForHome,
      'must_kill_inner' => mustKillForInner,
      'safe_zone' => safeZone,
      'two_tokens_same_cell' => twoTokensSameCell,
      'paired_tokens' => pairedTokens,
      'paired_movement' => pairedMovementRule,
      _ => false,
    };
  }

  GameRuleConfig withValue(String ruleId, bool value) {
    return switch (ruleId) {
      'extra_turn_48' => copyWith(extraTurnFor48: value),
      'extra_turn_kill' => copyWith(extraTurnForKill: value),
      'extra_turn_home' => copyWith(extraTurnForHome: value),
      'must_kill_inner' => copyWith(mustKillForInner: value),
      'safe_zone' => copyWith(safeZone: value),
      'two_tokens_same_cell' => copyWith(twoTokensSameCell: value),
      'paired_tokens' => copyWith(pairedTokens: value),
      'paired_movement' => copyWith(pairedMovementRule: value),
      _ => this,
    };
  }
}
