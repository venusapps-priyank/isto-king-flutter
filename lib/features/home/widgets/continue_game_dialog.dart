import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';

enum ContinueGameChoice { continueGame, newGame }

class ContinueGameDialog extends StatelessWidget {
  const ContinueGameDialog({super.key});

  static Future<ContinueGameChoice?> show(BuildContext context) {
    return showRoyalDialog<ContinueGameChoice>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ContinueGameDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'Saved Game',
      maxWidth: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, color: RoyalColors.gold, size: 54),
          const SizedBox(height: 8),
          const Text(
            'Continue your left off game or start a new game?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          RoyalDialogActionButton(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            backgroundColor: RoyalColors.green,
            onTap: () =>
                Navigator.of(context).pop(ContinueGameChoice.continueGame),
          ),
          const SizedBox(height: 10),
          RoyalDialogActionButton(
            label: 'New Game',
            icon: Icons.add_circle_outline_rounded,
            backgroundColor: Color(0xFFF5A400),
            textColor: RoyalColors.darkBrown,
            onTap: () => Navigator.of(context).pop(ContinueGameChoice.newGame),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
