import 'dart:convert';

import 'package:istochaka/features/game/controllers/game_turn_controller.dart';
import 'package:istochaka/features/game/models/game_setup_config.dart';
import 'package:istochaka/features/rules/models/game_rules_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedGame {
  const SavedGame({required this.setup, required this.turnController});

  static const _version = 1;

  final GameSetupConfig setup;
  final GameTurnController turnController;

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    final setup = GameSetupConfig.fromJson(
      (json['setup'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return SavedGame(
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

  bool get canResume => !turnController.isGameOver;
}

class SavedGameRepository {
  static const _passAndPlayStorageKey = 'saved_pass_and_play_game';
  static const _vsComputerStorageKey = 'saved_vs_computer_game';

  Future<SavedGame?> load({required bool isPassAndPlay}) async {
    final preferences = await SharedPreferences.getInstance();
    final storageKey = _storageKeyFor(isPassAndPlay: isPassAndPlay);
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      if (json['version'] != SavedGame._version) {
        await clear(isPassAndPlay: isPassAndPlay);
        return null;
      }
      final savedGame = SavedGame.fromJson(json);
      if (!savedGame.canResume ||
          savedGame.setup.isPassAndPlay != isPassAndPlay) {
        await clear(isPassAndPlay: isPassAndPlay);
        return null;
      }
      return savedGame;
    } on Object {
      await clear(isPassAndPlay: isPassAndPlay);
      return null;
    }
  }

  Future<void> save(SavedGame game) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKeyFor(isPassAndPlay: game.setup.isPassAndPlay),
      jsonEncode(game.toJson()),
    );
  }

  Future<void> clear({required bool isPassAndPlay}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKeyFor(isPassAndPlay: isPassAndPlay));
  }

  String _storageKeyFor({required bool isPassAndPlay}) {
    return isPassAndPlay ? _passAndPlayStorageKey : _vsComputerStorageKey;
  }
}
