import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isto_king/features/game/logic/cowrie_animation_constants.dart';

class CowrieShell extends StatefulWidget {
  const CowrieShell({
    required this.startOpen,
    required this.resultOpen,
    required this.isRolling,
    required this.rollCycle,
    required this.delayIndex,
    required this.size,
    required this.width,
    super.key,
  });

  final bool startOpen;
  final bool resultOpen;
  final bool isRolling;
  final int rollCycle;
  final int delayIndex;
  final double size;
  final double width;

  @override
  State<CowrieShell> createState() => _CowrieShellState();
}

class _CowrieShellState extends State<CowrieShell> {
  bool? _spinStartOpen;
  bool? _spinResultOpen;

  int get _tumbleHalfFlips => 4 + (widget.delayIndex % 2);

  @override
  void didUpdateWidget(CowrieShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rollCycle > oldWidget.rollCycle ||
        (widget.isRolling && !oldWidget.isRolling)) {
      _spinStartOpen = widget.startOpen;
      _spinResultOpen = widget.resultOpen;
    }
  }

  Widget _shellImage(bool isOpen) => Image.asset(
    isOpen
        ? 'assets/images/cowrie_open.png'
        : 'assets/images/cowrie_closed.png',
    width: widget.width,
    height: widget.size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );

  Widget _buildSettledShell() {
    return SizedBox(
      width: widget.width,
      height: widget.size,
      child: _shellImage(_spinResultOpen ?? widget.resultOpen),
    );
  }

  bool _faceBeforeLanding(bool startOpen) {
    return _tumbleHalfFlips.isEven ? startOpen : !startOpen;
  }

  Widget _buildFlipFrame(double value) {
    final startOpen = _spinStartOpen ?? widget.startOpen;
    final resultOpen = _spinResultOpen ?? widget.resultOpen;
    final pop = math.sin(value * math.pi);
    final wobble =
        math.sin(value * math.pi * 4 + widget.delayIndex) * 1.8 * pop;
    final scale = 1.0 + pop * 0.24;
    final lift = -pop * 8;

    late final double verticalSpin;
    late final bool showOpen;

    if (value >= cowrieLandingStart) {
      final landValue = (value - cowrieLandingStart) / (1 - cowrieLandingStart);
      final showingResult = landValue >= 0.5;
      final halfProgress = showingResult ? (landValue - 0.5) * 2 : landValue * 2;
      final landingSpin = showingResult
          ? -math.pi / 2 + halfProgress * math.pi / 2
          : halfProgress * math.pi / 2;
      verticalSpin = _tumbleHalfFlips * math.pi / 2 + landingSpin;
      showOpen = showingResult ? resultOpen : _faceBeforeLanding(startOpen);
    } else {
      final tumbleValue = Curves.easeOut.transform(value / cowrieLandingStart);
      verticalSpin = tumbleValue * _tumbleHalfFlips * math.pi / 2;
      final halfFlipIndex = (verticalSpin / (math.pi / 2)).floor();
      showOpen = halfFlipIndex.isEven ? startOpen : !startOpen;
    }

    return Transform.translate(
      offset: Offset(wobble, lift),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0016)
          ..rotateY(verticalSpin),
        child: Transform.scale(
          scale: scale,
          child: _shellImage(showOpen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRolling) {
      return _buildSettledShell();
    }

    final startOpen = _spinStartOpen ?? widget.startOpen;
    final totalMs = cowrieSpinMs + cowrieSettleMs;
    final flipEnd = cowrieSpinMs / totalMs;

    return SizedBox(
      width: widget.width,
      height: widget.size,
      child: _shellImage(startOpen)
          .animate(
            key: ValueKey('cowrie-${widget.rollCycle}-${widget.delayIndex}'),
            delay: (widget.delayIndex * cowrieDelayMs).ms,
          )
          .custom(
            duration: totalMs.ms,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              if (value >= flipEnd) {
                final settleT = (value - flipEnd) / (1 - flipEnd);
                final bounce = 1.0 + math.sin(settleT * math.pi) * 0.05;
                final resultOpen = _spinResultOpen ?? widget.resultOpen;
                return Transform.scale(
                  scale: bounce,
                  child: _shellImage(resultOpen),
                );
              }
              return _buildFlipFrame(value / flipEnd);
            },
          ),
    );
  }
}
