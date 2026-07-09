import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class RulesCheckbox extends StatelessWidget {
  const RulesCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: value
                ? const [Color(0xFFE32622), Color(0xFF8A0A0A)]
                : const [Color(0xFFFFF4D6), Color(0xFFE8D4A8)],
          ),
          border: Border.all(
            color: value
                ? RoyalColors.darkRed
                : RoyalColors.brown.withValues(alpha: 0.45),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: value
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
