class GameRulesSettings {
  const GameRulesSettings({
    this.mustKillForInner = true,
    this.killPermissionReset = true,
    this.stashedKillPermissionReset = true,
  });

  final bool mustKillForInner;
  final bool killPermissionReset;
  final bool stashedKillPermissionReset;

  static const defaults = GameRulesSettings();

  GameRulesSettings copyWith({
    bool? mustKillForInner,
    bool? killPermissionReset,
    bool? stashedKillPermissionReset,
  }) {
    return GameRulesSettings(
      mustKillForInner: mustKillForInner ?? this.mustKillForInner,
      killPermissionReset: killPermissionReset ?? this.killPermissionReset,
      stashedKillPermissionReset:
          stashedKillPermissionReset ?? this.stashedKillPermissionReset,
    );
  }

  bool valueFor(String settingKey) {
    return switch (settingKey) {
      GameRuleSettingKey.mustKillForInner => mustKillForInner,
      GameRuleSettingKey.killPermissionReset => killPermissionReset,
      _ => true,
    };
  }

  bool isSettingActive(String settingKey) {
    return switch (settingKey) {
      GameRuleSettingKey.killPermissionReset =>
        mustKillForInner && killPermissionReset,
      _ => valueFor(settingKey),
    };
  }

  bool isSettingToggleEnabled(String settingKey) {
    return switch (settingKey) {
      GameRuleSettingKey.killPermissionReset => mustKillForInner,
      _ => true,
    };
  }

  GameRulesSettings withValue(String settingKey, bool value) {
    return switch (settingKey) {
      GameRuleSettingKey.mustKillForInner => value
          ? copyWith(
              mustKillForInner: true,
              killPermissionReset: stashedKillPermissionReset,
            )
          : copyWith(
              mustKillForInner: false,
              stashedKillPermissionReset: killPermissionReset,
              killPermissionReset: false,
            ),
      GameRuleSettingKey.killPermissionReset => copyWith(
        killPermissionReset: value,
        stashedKillPermissionReset: value,
      ),
      _ => this,
    };
  }
}

abstract final class GameRuleSettingKey {
  static const mustKillForInner = 'must_kill_inner';
  static const killPermissionReset = 'kill_permission_reset';
}
