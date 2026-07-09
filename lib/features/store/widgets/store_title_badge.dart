import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class StoreTitleBadge extends StatelessWidget {
  const StoreTitleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 330).clamp(0.75, 1.0).toDouble();

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28 * scale),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF5DF), Color(0xFFF6E3C0)],
              ),
              border: Border.all(color: const Color(0xFF8D4317), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: RoyalColors.darkRed.withValues(alpha: 0.22),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 28 * scale,
                vertical: 10 * scale,
              ),
              child: Text(
                'STORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40 * scale,
                  fontWeight: FontWeight.w900,
                  color: RoyalColors.darkRed,
                  height: 0.9,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
