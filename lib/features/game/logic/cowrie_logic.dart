import 'dart:math' as math;

class CowrieLogic {
  static int calculateIstoValue(List<bool> cowries) {
    final openCount = cowries.where((isOpen) => isOpen).length;
    return openCount == 0 ? 8 : openCount;
  }

  static List<bool> generateFinalCowries(int count, math.Random random) {
    return List<bool>.generate(count, (_) => random.nextBool());
  }
}
