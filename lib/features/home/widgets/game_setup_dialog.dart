import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:isto_king/features/game/screens/isto_game_screen.dart';
import 'package:isto_king/features/home/widgets/player_count_icons.dart';

class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const GameSetupDialog(),
    );
  }

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  int _playerCount = 4;
  Color _chipColor = RoyalColors.yellow;

  static const _chipColors = [
    RoyalColors.red,
    RoyalColors.green,
    RoyalColors.yellow,
    RoyalColors.blue,
  ];

  void _onContinue() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const IstoGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'Game Setup',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(number: 1, label: 'Player Count'),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _PlayerCountCard(
                      count: i + 2,
                      isSelected: _playerCount == i + 2,
                      onTap: () => setState(() => _playerCount = i + 2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const _SectionHeading(number: 2, label: 'Choose Your Chip Color'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final color in _chipColors)
                _ChipColorButton(
                  color: color,
                  isSelected: _chipColor == color,
                  onTap: () => setState(() => _chipColor = color),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionHeading(number: 3, label: 'Rules'),
          const SizedBox(height: 10),
          _RulesButton(onTap: () {}),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SetupActionButton(
                  label: 'Continue',
                  backgroundColor: RoyalColors.green,
                  textColor: Colors.white,
                  borderColor: RoyalColors.gold,
                  onTap: _onContinue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SetupActionButton(
                  label: 'Cancel',
                  backgroundColor: RoyalColors.parchmentLight,
                  textColor: RoyalColors.darkRed,
                  borderColor: RoyalColors.gold,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number. $label',
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w900,
        color: RoyalColors.darkBrown,
        height: 1.15,
        letterSpacing: 0.15,
      ),
    );
  }
}

class _PlayerCountCard extends StatelessWidget {
  const _PlayerCountCard({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? RoyalColors.gold : RoyalColors.darkRed;
    final textColor = isSelected ? RoyalColors.gold : RoyalColors.darkBrown;
    const iconSize = 44.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? RoyalColors.gold : const Color(0xFFC9A06A),
              width: 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(
                  alpha: isSelected ? 0.22 : 0.12,
                ),
                blurRadius: isSelected ? 8 : 5,
                offset: const Offset(0, 3),
              ),
              if (isSelected)
                BoxShadow(
                  color: RoyalColors.gold.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: FittedBox(
                      child: PlayerCountIcons(
                        count: count,
                        size: iconSize,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                child: Text(
                  '$count Players',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipColorButton extends StatelessWidget {
  const _ChipColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? RoyalColors.gold : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: RoyalColors.gold.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.white, width: 2.2),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: RoyalColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RulesButton extends StatelessWidget {
  const _RulesButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8EB), Color(0xFFFFF2DC)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4B07A), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: RoyalColors.darkRed,
                          size: 28,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -1,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EB),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: RoyalColors.gold,
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: RoyalColors.gold,
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'View & Manage Rules',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: RoyalColors.darkBrown,
                      height: 1.1,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupActionButton extends StatelessWidget {
  const _SetupActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimary = backgroundColor == RoyalColors.green;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 42,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(backgroundColor, Colors.white, 0.12)!,
                      Color.lerp(backgroundColor, Colors.black, 0.2)!,
                    ],
                  )
                : null,
            color: isPrimary ? null : backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 2.6),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
