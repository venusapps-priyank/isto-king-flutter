import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const _cardMotionDurationMs = 280;
const _cardMotionStaggerMs = 45;

extension _PlayerCardMotion on Widget {
  Widget animatePlayerCardSlot({
    required double target,
    required int order,
    required Offset slideBegin,
  }) {
    final delay = (order * _cardMotionStaggerMs).ms;
    return animate(target: target)
        .fadeIn(duration: 200.ms, delay: delay)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: _cardMotionDurationMs.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        )
        .slide(
          begin: slideBegin,
          end: Offset.zero,
          duration: _cardMotionDurationMs.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        );
  }
}

class AnimatedPlayerRow extends StatelessWidget {
  const AnimatedPlayerRow({
    required this.left,
    required this.right,
    required this.visible,
    required this.isTopRow,
    super.key,
  });

  final Widget left;
  final Widget right;
  final bool visible;
  final bool isTopRow;

  static const _topLeftSlide = Offset(-0.22, -0.42);
  static const _topRightSlide = Offset(0.22, -0.42);
  static const _bottomLeftSlide = Offset(-0.22, 0.42);
  static const _bottomRightSlide = Offset(0.22, 0.42);

  double get _target => visible ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final leftOrder = isTopRow ? 0 : 2;
    final rightOrder = isTopRow ? 1 : 3;
    final leftSlide = isTopRow ? _topLeftSlide : _bottomLeftSlide;
    final rightSlide = isTopRow ? _topRightSlide : _bottomRightSlide;

    return ClipRect(
      child: IgnorePointer(
        ignoring: !visible,
        child: Row(
          children: [
            Expanded(
              child: left.animatePlayerCardSlot(
                target: _target,
                order: leftOrder,
                slideBegin: leftSlide,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: right.animatePlayerCardSlot(
                target: _target,
                order: rightOrder,
                slideBegin: rightSlide,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
