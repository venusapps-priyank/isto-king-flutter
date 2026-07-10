import 'package:flutter/material.dart';
import 'package:istochaka/features/game/widgets/player_card.dart';

class PlayerRow extends StatelessWidget {
  const PlayerRow({required this.left, required this.right, super.key});

  final PlayerCard left;
  final PlayerCard right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
