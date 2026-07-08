import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';

class PauseGameDialog extends StatelessWidget {
  const PauseGameDialog({
    required this.onResume,
    required this.onRestart,
    required this.onQuitMatch,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuitMatch;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResume,
    required VoidCallback onRestart,
    required VoidCallback onQuitMatch,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PauseGameDialog(
        onResume: onResume,
        onRestart: onRestart,
        onQuitMatch: onQuitMatch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'Pause Game',
      onClose: onResume,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/pause.png', width: 200, fit: BoxFit.contain),
          const SizedBox(height: 8),
          const Text(
            'Your match is paused.\nWhat would you like to do?',
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
            onTap: onResume,
          ),
          const SizedBox(height: 10),
          RoyalDialogActionButton(
            label: 'Restart',
            icon: Icons.restart_alt_rounded,
            backgroundColor: Color(0xFFF5A400),
            textColor: RoyalColors.darkBrown,
            onTap: onRestart,
          ),
          const SizedBox(height: 10),
          RoyalDialogActionButton(
            label: 'Quit Match',
            icon: Icons.logout_rounded,
            backgroundColor: RoyalColors.red,
            onTap: onQuitMatch,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
