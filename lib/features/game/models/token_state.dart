class TokenState {
  TokenState({
    required this.playerIndex,
    required this.tokenIndex,
    this.pathIndex = -1,
    this.isAtStart = true,
    this.isFinished = false,
    this.pairedTokenId,
  });

  final int playerIndex;
  final int tokenIndex;
  int pathIndex;
  bool isAtStart;
  bool isFinished;
  int? pairedTokenId;

  int get id => playerIndex * 10 + tokenIndex;

  bool get isPaired => pairedTokenId != null;

  void pairWith(TokenState other) {
    pairedTokenId = other.id;
    other.pairedTokenId = id;
  }

  void unpair() {
    pairedTokenId = null;
  }

  void sendToStart() {
    pathIndex = -1;
    isAtStart = true;
    isFinished = false;
    pairedTokenId = null;
  }
}
