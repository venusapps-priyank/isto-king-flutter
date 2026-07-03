import 'package:flutter/material.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/game/widgets/round_icon_button.dart';

class TopGameBar extends StatelessWidget {
  const TopGameBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          left: 0,
          child: RoundIconButton(icon: Icons.arrow_back),
        ),
        const Positioned(
          right: 0,
          child: RoundIconButton(icon: Icons.settings),
        ),
        Positioned(right: 48, child: const CoinBalancePill()),
      ],
    );
  }
}
