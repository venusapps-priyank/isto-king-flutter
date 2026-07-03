class TokenState {
  TokenState({
    required this.playerIndex,
    required this.tokenIndex,
    this.pathIndex = -1,
    this.isAtStart = true,
    this.isFinished = false,
  });

  final int playerIndex;
  final int tokenIndex;
  int pathIndex;
  bool isAtStart;
  bool isFinished;

  int get id => playerIndex * 10 + tokenIndex;

  void sendToStart() {
    pathIndex = -1;
    isAtStart = true;
    isFinished = false;
  }
}
