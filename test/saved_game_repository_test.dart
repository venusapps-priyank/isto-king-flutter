import 'package:flutter_test/flutter_test.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/game/controllers/game_turn_controller.dart';
import 'package:istochaka/features/game/data/saved_game_repository.dart';
import 'package:istochaka/features/game/models/game_setup_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keeps AI and pass-and-play saved games separate', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SavedGameRepository();

    final aiSetup = GameSetupConfig(
      playerCount: 2,
      chipColor: RoyalColors.red,
      isPassAndPlay: false,
    );
    final friendsSetup = GameSetupConfig(
      playerCount: 3,
      chipColor: RoyalColors.yellow,
      isPassAndPlay: true,
    );

    await repository.save(
      SavedGame(
        setup: aiSetup,
        turnController: GameTurnController(
          activePlayers: aiSetup.activePlayerIndexSet,
        )..currentPlayerIndex = 0,
      ),
    );
    await repository.save(
      SavedGame(
        setup: friendsSetup,
        turnController: GameTurnController(
          activePlayers: friendsSetup.activePlayerIndexSet,
        )..currentPlayerIndex = 2,
      ),
    );

    final aiSavedGame = await repository.load(isPassAndPlay: false);
    final friendsSavedGame = await repository.load(isPassAndPlay: true);

    expect(aiSavedGame?.setup.isPassAndPlay, isFalse);
    expect(aiSavedGame?.setup.playerCount, 2);
    expect(aiSavedGame?.turnController.currentPlayerIndex, 0);
    expect(friendsSavedGame?.setup.isPassAndPlay, isTrue);
    expect(friendsSavedGame?.setup.playerCount, 3);
    expect(friendsSavedGame?.turnController.currentPlayerIndex, 2);
  });
}
