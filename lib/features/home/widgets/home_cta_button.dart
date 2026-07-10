import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istochaka/core/theme/royal_colors.dart';

class HomeCtaButton extends StatelessWidget {
  const HomeCtaButton({
    required this.label,
    this.subtitle,
    this.icon,
    this.onPressed,
    this.backgroundColor = RoyalColors.red,
    this.textColor = Colors.white,
    this.expanded = false,
    this.compactScale = 1.0,
    super.key,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool expanded;
  final double compactScale;

  @override
  Widget build(BuildContext context) {
    final isPrimaryCta = subtitle == null && icon == null;
    final isSecondaryCta = subtitle != null;

    final content = isPrimaryCta
        ? _PrimaryHomeButton(
            label: label,
            onPressed: onPressed,
            textColor: textColor,
            compactScale: compactScale,
          )
        : isSecondaryCta
        ? _SecondaryHomeButton(
            label: label,
            subtitle: subtitle!,
            icon: icon,
            onPressed: onPressed,
            backgroundColor: backgroundColor,
            textColor: textColor,
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 14 : 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: backgroundColor,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          );

    if (!expanded) return content;

    return Expanded(child: content);
  }
}

class _SecondaryHomeButton extends StatelessWidget {
  const _SecondaryHomeButton({
    required this.label,
    required this.subtitle,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  final String label;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final iconSize = (maxWidth * 0.18).clamp(28.0, 34.0);
        final labelSize = (maxWidth * 0.085).clamp(14.0, 16.0);
        final subtitleSize = (maxWidth * 0.06).clamp(10.0, 11.0);
        final horizontalPadding = (maxWidth * 0.06).clamp(8.0, 10.0);
        final verticalPadding = (maxWidth * 0.08).clamp(14.0, 16.0);
        final gap = (maxWidth * 0.04).clamp(6.0, 7.0);
        final darker = Color.lerp(backgroundColor, Colors.black, 0.24)!;
        final lighter = Color.lerp(backgroundColor, Colors.white, 0.16)!;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFCE8AA), Color(0xFFD69A2D)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFF4CD).withValues(alpha: 0.72),
                  width: 1.8,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lighter, darker],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: iconSize),
                          SizedBox(width: gap),
                        ],
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.95),
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w300,
                                  height: 1.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryHomeButton extends StatelessWidget {
  const _PrimaryHomeButton({
    required this.label,
    required this.onPressed,
    required this.textColor,
    this.compactScale = 1.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color textColor;
  final double compactScale;

  static TextStyle get _labelStyle => GoogleFonts.robotoSlab(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFDF5E6),
        letterSpacing: 0.6,
        height: 1,
      );

  static const _pillRadius = 999.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final scale = compactScale.clamp(0.75, 1.0);
        final labelStyle = _labelStyle.copyWith(
          fontSize: ((maxWidth * 0.13).clamp(30.0, 40.0) * scale)
              .clamp(24.0, 40.0),
        );
        final iconSize = ((maxWidth * 0.06).clamp(14.0, 18.0) * scale)
            .clamp(12.0, 18.0);
        final horizontalPadding =
            ((maxWidth * 0.06).clamp(14.0, 20.0) * scale).clamp(12.0, 20.0);
        final verticalPadding =
            ((maxWidth * 0.055).clamp(14.0, 18.0) * scale).clamp(10.0, 18.0);
        final iconInset = (maxWidth * 0.02).clamp(2.0, 6.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_pillRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBE79B), Color(0xFFD59A2C)],
            ),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkRed.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_pillRadius),
                border: Border.all(
                  color: const Color(0xFFFFD879),
                  width: 2.2,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE32622), Color(0xFF7A0808)],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(_pillRadius),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: iconInset,
                            child: Icon(
                              Icons.auto_awesome,
                              size: iconSize,
                              color: const Color(0xFFFFD879),
                            ),
                          ),
                          Positioned(
                            right: iconInset,
                            child: Icon(
                              Icons.auto_awesome,
                              size: iconSize,
                              color: const Color(0xFFFFD879),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: iconSize + iconInset + 8,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: labelStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
