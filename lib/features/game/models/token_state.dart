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

  factory TokenState.fromJson(Map<String, dynamic> json) {
    return TokenState(
      playerIndex: json['playerIndex'] as int? ?? 0,
      tokenIndex: json['tokenIndex'] as int? ?? 0,
      pathIndex: json['pathIndex'] as int? ?? -1,
      isAtStart: json['isAtStart'] as bool? ?? true,
      isFinished: json['isFinished'] as bool? ?? false,
      pairedTokenId: json['pairedTokenId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerIndex': playerIndex,
      'tokenIndex': tokenIndex,
      'pathIndex': pathIndex,
      'isAtStart': isAtStart,
      'isFinished': isFinished,
      'pairedTokenId': pairedTokenId,
    };
  }

  void restoreFrom(TokenState other) {
    pathIndex = other.pathIndex;
    isAtStart = other.isAtStart;
    isFinished = other.isFinished;
    pairedTokenId = other.pairedTokenId;
  }

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
