import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';

class RulesCheckbox extends StatelessWidget {
  const RulesCheckbox({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final uncheckedColors = enabled
        ? const [Color(0xFFFFF4D6), Color(0xFFE8D4A8)]
        : const [Color(0xFFF3E8D0), Color(0xFFE0D2B8)];
    final borderColor = !enabled
        ? RoyalColors.brown.withValues(alpha: 0.2)
        : value
        ? RoyalColors.darkRed
        : RoyalColors.brown.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.45,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: value && enabled
                  ? const [Color(0xFFE32622), Color(0xFF8A0A0A)]
                  : uncheckedColors,
            ),
            border: Border.all(color: borderColor, width: 1.6),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: value && enabled
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
