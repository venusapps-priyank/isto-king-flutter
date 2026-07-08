import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WinActionButtons extends StatelessWidget {
  const WinActionButtons({
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = _WinPillButton.widthForLabel('PLAY AGAIN');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _WinPillButton(
          label: 'PLAY AGAIN',
          icon: Icons.replay_rounded,
          isPrimary: true,
          width: buttonWidth,
          onTap: onPlayAgain,
        ),
        const SizedBox(width: 10),
        _WinPillButton(
          label: 'HOME',
          icon: Icons.home_rounded,
          isPrimary: false,
          width: buttonWidth,
          onTap: onHome,
        ),
      ],
    );
  }
}

class _WinPillButton extends StatelessWidget {
  const _WinPillButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.width,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final double width;
  final VoidCallback onTap;

  static const _labelColor = Color(0xFF4A2A12);
  static const _depthOffset = 4.0;
  static const _horizontalPadding = 20.0;
  static const _iconSize = 26.0;
  static const _iconSpacing = 8.0;

  static TextStyle get _labelStyle => GoogleFonts.nunito(
        color: _labelColor,
        fontWeight: FontWeight.w900,
        fontSize: 22,
        height: 1,
        letterSpacing: 0.15,
      );

  static double widthForLabel(String label) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: _labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    return (_horizontalPadding * 2) +
        _iconSize +
        _iconSpacing +
        textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final palette = isPrimary ? _primaryPalette : _secondaryPalette;
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 13,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _labelColor,
            size: _iconSize,
            fill: 1,
            weight: 700,
          ),
          const SizedBox(width: _iconSpacing),
          Text(label, style: _labelStyle),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 58,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: _depthOffset,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.depth,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.border, width: 1.8),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: _depthOffset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: palette.face,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.border, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: palette.border.withValues(alpha: 0.35),
                      blurRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 3,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: isPrimary ? 0.72 : 0.85),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                palette.face.last.withValues(alpha: 0),
                                palette.face.last.withValues(alpha: 0.28),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(child: content),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.face,
    required this.depth,
    required this.border,
  });

  final List<Color> face;
  final Color depth;
  final Color border;
}

const _primaryPalette = _ButtonPalette(
  face: [Color(0xFFFFE566), Color(0xFFF5A80A)],
  depth: Color(0xFFC8860A),
  border: Color(0xFF9A6B1A),
);

const _secondaryPalette = _ButtonPalette(
  face: [Color(0xFFFFF9EE), Color(0xFFEDE0C4)],
  depth: Color(0xFFD4C4A8),
  border: Color(0xFFC4A574),
);
