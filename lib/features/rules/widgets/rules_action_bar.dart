import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class RulesActionBar extends StatelessWidget {
  const RulesActionBar({
    required this.onReset,
    required this.onSave,
    super.key,
  });

  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = (constraints.maxWidth / 320).clamp(0.78, 1.0).toDouble();
          final gap = 10 * scale;
          final buttonHeight = 44 * scale;
          final iconSize = 16 * scale;
          final fontSize = 11.5 * scale;
          final horizontalPadding = 8 * scale;

          return Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Reset to Default',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  horizontalPadding: horizontalPadding,
                  textColor: RoyalColors.brown.withValues(alpha: 0.95),
                  iconColor: RoyalColors.brown.withValues(alpha: 0.9),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF8EA), Color(0xFFEAD8B4)],
                  ),
                  borderColor: RoyalColors.brown.withValues(alpha: 0.35),
                  borderWidth: 1.4,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _ActionButton(
                  label: 'Save Rules',
                  icon: Icons.save_rounded,
                  onTap: onSave,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  horizontalPadding: horizontalPadding,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  fontWeight: FontWeight.w800,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE32622), Color(0xFF7A0808)],
                  ),
                  borderColor: const Color(0xFFFFD879),
                  borderWidth: 1.8,
                  shadowColor: RoyalColors.darkRed.withValues(alpha: 0.28),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.textColor,
    required this.iconColor,
    required this.gradient,
    required this.borderColor,
    required this.borderWidth,
    this.fontWeight = FontWeight.w700,
    this.shadowColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final Color textColor;
  final Color iconColor;
  final LinearGradient gradient;
  final Color borderColor;
  final double borderWidth;
  final FontWeight fontWeight;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: gradient,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: shadowColor != null
                  ? [
                      BoxShadow(
                        color: shadowColor!,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: iconColor),
                  SizedBox(width: horizontalPadding * 0.6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: textColor,
                          letterSpacing: 0.2,
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
