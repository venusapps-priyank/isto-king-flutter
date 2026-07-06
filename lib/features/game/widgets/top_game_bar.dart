import 'package:flutter/material.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/game/widgets/round_icon_button.dart';

class TopGameBar extends StatelessWidget {
  const TopGameBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        RoundIconButton(icon: Icons.arrow_back),
        Spacer(),
        CoinBalancePill(),
        SizedBox(width: 8),
        RoundIconButton(icon: Icons.settings),
      ],
    );
  }
}
