import 'dart:math' as math;

class CowrieLogic {
  static const _distributionDenominator = 48;
  static const _commonValueWeight = 14;
  static const _rareValueWeight = 3;

  static int calculateIstoValue(List<bool> cowries) {
    final openCount = cowries.where((isOpen) => isOpen).length;
    return openCount == 0 ? 8 : openCount;
  }

  static int generateRollValue(math.Random random) {
    final roll = random.nextInt(_distributionDenominator);
    if (roll < _commonValueWeight) return 1;
    if (roll < _commonValueWeight * 2) return 2;
    if (roll < _commonValueWeight * 3) return 3;
    if (roll < _commonValueWeight * 3 + _rareValueWeight) return 4;
    return 8;
  }

  static List<bool> cowriesForValue(int value, int count, math.Random random) {
    final openCount = value == 8 ? 0 : value;
    final indices = List<int>.generate(count, (index) => index)..shuffle(random);
    final openIndices = indices.take(openCount).toSet();
    return List<bool>.generate(count, (index) => openIndices.contains(index));
  }

  static List<bool> generateFinalCowries(int count, math.Random random) {
    final value = generateRollValue(random);
    return cowriesForValue(value, count, random);
  }
}
