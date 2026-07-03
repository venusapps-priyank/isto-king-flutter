import 'package:flutter/material.dart';

class PlayerInfo {
  const PlayerInfo({
    required this.index,
    required this.name,
    required this.color,
    required this.avatarAsset,
    this.avatarOnRight = false,
  });

  final int index;
  final String name;
  final Color color;
  final String avatarAsset;
  final bool avatarOnRight;
}
