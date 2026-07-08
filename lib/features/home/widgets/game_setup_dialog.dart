import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:isto_king/features/game/models/game_setup_config.dart';
import 'package:isto_king/features/game/screens/isto_game_screen.dart';
import 'package:isto_king/features/home/widgets/player_count_icons.dart';

class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showRoyalDialog<void>(
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
    final setup = GameSetupConfig(
      playerCount: _playerCount,
      chipColor: _chipColor,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => IstoGameScreen(setup: setup),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'Game Setup',
      maxWidth: 360,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth;
          final playerGap = contentWidth < 280 ? 6.0 : 8.0;
          final playerCardSize = ((contentWidth - playerGap * 2) / 3)
              .clamp(64.0, 94.0)
              .toDouble();
          final chipSize = (contentWidth * 0.2).clamp(48.0, 68.0).toDouble();
          final sectionGap = contentWidth < 280 ? 16.0 : 20.0;
          final actionGap = contentWidth < 280 ? 6.0 : 8.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeading(number: 1, label: 'Player Count'),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(width: playerGap),
                    Expanded(
                      child: SizedBox(
                        height: playerCardSize,
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
              SizedBox(height: sectionGap),
              const _SectionHeading(number: 2, label: 'Choose Your Chip Color'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final color in _chipColors)
                    _ChipColorButton(
                      color: color,
                      size: chipSize,
                      isSelected: _chipColor == color,
                      onTap: () => setState(() => _chipColor = color),
                    ),
                ],
              ),
              SizedBox(height: sectionGap),
              const _SectionHeading(number: 3, label: 'Rules'),
              const SizedBox(height: 10),
              _RulesButton(onTap: () {}),
              SizedBox(height: contentWidth < 280 ? 18 : 22),
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
                  SizedBox(width: actionGap),
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
          );
        },
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardSize = constraints.biggest.shortestSide;
              final iconSize = (cardSize * 0.48)
                  .clamp(30.0, 44.0)
                  .toDouble();
              final labelSize = (cardSize * 0.13)
                  .clamp(9.5, 11.0)
                  .toDouble();
              final bottomPadding = (cardSize * 0.1).clamp(6.0, 10.0)
                  .toDouble();

              return Column(
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
                    padding: EdgeInsets.fromLTRB(4, 0, 4, bottomPadding),
                    child: Text(
                      '$count Players',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChipColorButton extends StatelessWidget {
  const _ChipColorButton({
    required this.color,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outerSize = size;
    final ringSize = size * 0.94;
    final innerSize = size * 0.82;
    final checkSize = (size * 0.32).clamp(16.0, 22.0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: ringSize,
              height: ringSize,
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
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.white, width: 2.2),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: size * 0.47,
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: checkSize,
                  height: checkSize,
                  decoration: const BoxDecoration(
                    color: RoyalColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: checkSize * 0.64,
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
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'View & Manage Rules',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: RoyalColors.darkBrown,
                          height: 1.1,
                          letterSpacing: 0.1,
                        ),
                      ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
