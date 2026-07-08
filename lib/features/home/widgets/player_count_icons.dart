import 'package:flutter/material.dart';

class PlayerCountIcons extends StatelessWidget {
  const PlayerCountIcons({
    required this.count,
    required this.size,
    required this.color,
    super.key,
  });

  final int count;
  final double size;
  final Color color;

  static IconData iconForCount(int count) => switch (count) {
        2 => Icons.people_rounded,
        3 => Icons.groups_rounded,
        _ => Icons.group_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconForCount(count),
      size: size,
      color: color,
    );
  }
}
