class PlayerGameState {
  PlayerGameState({this.hasKilledOpponent = false});

  bool hasKilledOpponent;

  factory PlayerGameState.fromJson(Map<String, dynamic> json) {
    return PlayerGameState(
      hasKilledOpponent: json['hasKilledOpponent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'hasKilledOpponent': hasKilledOpponent};
  }

  void restoreFrom(PlayerGameState other) {
    hasKilledOpponent = other.hasKilledOpponent;
  }
}
