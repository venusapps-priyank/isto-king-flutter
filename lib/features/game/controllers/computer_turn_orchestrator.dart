import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/logic/isto_computer_player.dart';

class ComputerTurnOrchestrator {
  ComputerTurnOrchestrator({IstoComputerPlayer? computerPlayer})
      : _computerPlayer = computerPlayer ?? IstoComputerPlayer();

  final IstoComputerPlayer _computerPlayer;
  int _turnSerial = 0;

  void cancelPendingTurns() => _turnSerial++;

  void scheduleTurn({
    required bool Function() isMounted,
    required bool Function(int playerIndex) isComputerPlayer,
    required bool Function() isMoveAnimating,
    required bool Function() isCowrieRolling,
    required bool Function() hasVisiblePairPrompt,
    required GameTurnController Function() controller,
    required void Function(int playerIndex) onTriggerRoll,
    required void Function(TokenPairCandidate candidate) onPairAfterRoll,
    required void Function() onMoveChoice,
  }) {
    if (!isMounted() ||
        isMoveAnimating() ||
        isCowrieRolling() ||
        hasVisiblePairPrompt()) {
      return;
    }

    final turnController = controller();
    if (turnController.isGameOver) return;

    final playerIndex = turnController.currentPlayerIndex;
    if (!isComputerPlayer(playerIndex)) return;
    if (!turnController.canRoll(playerIndex) &&
        !turnController.hasPendingMove) {
      return;
    }

    final serial = ++_turnSerial;
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!isMounted() || serial != _turnSerial) return;
      if (isMoveAnimating() || isCowrieRolling() || hasVisiblePairPrompt()) {
        return;
      }

      final activeController = controller();
      if (activeController.currentPlayerIndex != playerIndex) return;
      if (activeController.isGameOver) return;

      if (activeController.canRoll(playerIndex)) {
        onTriggerRoll(playerIndex);
        return;
      }

      if (activeController.hasPendingMove) {
        onMoveChoice();
      }
    });
  }

  void handlePairAfterRoll({
    required GameTurnController controller,
    required TokenPairCandidate candidate,
    required void Function(TokenPairCandidate candidate) onJoinPair,
    required void Function() onMoveChoice,
  }) {
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (_computerPlayer.shouldJoinPair(controller, candidate)) {
        onJoinPair(candidate);
      } else {
        onMoveChoice();
      }
    });
  }

  void handlePairPrompt({
    required GameTurnController controller,
    required TokenPairCandidate candidate,
    required int tokenId,
    required void Function(TokenPairCandidate candidate, int tokenId) onJoinPair,
    required void Function(int tokenId) onPlaySingle,
  }) {
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (_computerPlayer.shouldJoinPair(controller, candidate)) {
        onJoinPair(candidate, tokenId);
      } else {
        onPlaySingle(tokenId);
      }
    });
  }

  int? chooseTokenId(GameTurnController controller) {
    return _computerPlayer.chooseTokenId(controller);
  }
}
