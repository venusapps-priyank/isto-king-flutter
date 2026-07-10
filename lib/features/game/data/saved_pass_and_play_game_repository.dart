import 'dart:convert';

import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/models/game_setup_config.dart';
import 'package:isto_king/features/rules/models/game_rules_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPassAndPlayGame {
  const SavedPassAndPlayGame({
    required this.setup,
    required this.turnController,
  });

  static const _version = 1;

  final GameSetupConfig setup;
  final GameTurnController turnController;

  factory SavedPassAndPlayGame.fromJson(Map<String, dynamic> json) {
    final setup = GameSetupConfig.fromJson(
      (json['setup'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return SavedPassAndPlayGame(
      setup: setup,
      turnController: GameTurnController.fromJson(
        (json['turnController'] as Map?)?.cast<String, dynamic>() ?? const {},
        activePlayers: setup.activePlayerIndexSet,
        mustKillForInner: setup.rulesSettings.mustKillForInner,
        killPermissionReset: setup.rulesSettings.isSettingActive(
          GameRuleSettingKey.killPermissionReset,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': _version,
      'setup': setup.toJson(),
      'turnController': turnController.toJson(),
    };
  }

  bool get canResume => setup.isPassAndPlay && !turnController.isGameOver;
}

class SavedPassAndPlayGameRepository {
  static const _storageKey = 'saved_pass_and_play_game';

  Future<SavedPassAndPlayGame?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      if (json['version'] != SavedPassAndPlayGame._version) {
        await clear();
        return null;
      }
      final savedGame = SavedPassAndPlayGame.fromJson(json);
      if (!savedGame.canResume) {
        await clear();
        return null;
      }
      return savedGame;
    } on Object {
      await clear();
      return null;
    }
  }

  Future<void> save(SavedPassAndPlayGame game) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(game.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
