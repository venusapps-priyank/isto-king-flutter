class GameRulesSettings {
  const GameRulesSettings({
    this.mustKillForInner = true,
  });

  final bool mustKillForInner;

  static const defaults = GameRulesSettings();

  GameRulesSettings copyWith({bool? mustKillForInner}) {
    return GameRulesSettings(
      mustKillForInner: mustKillForInner ?? this.mustKillForInner,
    );
  }

  bool valueFor(String settingKey) {
    return switch (settingKey) {
      GameRuleSettingKey.mustKillForInner => mustKillForInner,
      _ => true,
    };
  }

  GameRulesSettings withValue(String settingKey, bool value) {
    return switch (settingKey) {
      GameRuleSettingKey.mustKillForInner => copyWith(mustKillForInner: value),
      _ => this,
    };
  }
}

abstract final class GameRuleSettingKey {
  static const mustKillForInner = 'must_kill_inner';
}
