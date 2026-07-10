import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';

class RoyalScreenFrame extends StatelessWidget {
  const RoyalScreenFrame({
    required this.child,
    super.key,
  });

  static const cornerAsset = 'assets/images/corner_mandala.png';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: const BoxDecoration(color: RoyalColors.parchment),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ScreenOrnamentPainter(
                topInset: topInset,
                topCornerScale: 0.5,
                bottomCornerScale: 1.38,
                bottomConnectorHeight: 28,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: topInset,
            child: const ColoredBox(color: RoyalColors.outerRed),
          ),
          const _CornerMandala(isLeft: true),
          const _CornerMandala(isLeft: false),
          SafeArea(bottom: false, child: child),
        ],
      ),
    );
  }
}

class _CornerMandala extends StatelessWidget {
  const _CornerMandala({required this.isLeft});

  static const _imageSize = 170.0;

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageSize = (screenWidth * 0.42).clamp(126.0, _imageSize).toDouble();
    final offset = -imageSize / 2;

    return Positioned(
      left: isLeft ? offset : null,
      right: isLeft ? null : offset,
      bottom: offset,
      width: imageSize,
      height: imageSize,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.94,
          child: Image.asset(
            RoyalScreenFrame.cornerAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
