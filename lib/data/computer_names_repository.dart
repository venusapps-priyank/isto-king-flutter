import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class ComputerNamesRepository {
  ComputerNamesRepository._();

  static const _assetPath = 'assets/data/computer_names.json';

  static List<String>? _cachedNames;

  static Future<List<String>> loadNames() async {
    if (_cachedNames != null) return _cachedNames!;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cachedNames = decoded.cast<String>();
    return _cachedNames!;
  }

  static List<String> pickRandomNames(List<String> allNames, int count) {
    if (count <= 0) return const [];
    if (count >= allNames.length) {
      final shuffled = List<String>.from(allNames)..shuffle(Random());
      return shuffled;
    }

    final shuffled = List<String>.from(allNames)..shuffle(Random());
    return shuffled.take(count).toList();
  }
}
