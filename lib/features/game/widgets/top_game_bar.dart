import 'package:flutter/material.dart';
import 'package:isto_king/features/game/widgets/coin_balance_pill.dart';
import 'package:isto_king/features/game/widgets/round_icon_button.dart';

class TopGameBar extends StatelessWidget {
  const TopGameBar({this.onSettingsTap, super.key});

  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const RoundIconButton(icon: Icons.arrow_back),
        const Spacer(),
        const CoinBalancePill(),
        const SizedBox(width: 8),
        RoundIconButton(icon: Icons.settings, onTap: onSettingsTap),
      ],
    );
  }
}
