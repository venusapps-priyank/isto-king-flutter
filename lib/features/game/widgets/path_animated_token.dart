import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/features/game/models/board_cell.dart';

class PathAnimatedToken extends StatefulWidget {
  const PathAnimatedToken({
    required this.waypoints,
    required this.board,
    required this.cellSize,
    required this.tokenSize,
    required this.duration,
    required this.curve,
    required this.child,
    this.childSize,
    this.startDelay = Duration.zero,
    super.key,
  });

  final List<BoardCell> waypoints;
  final Rect board;
  final double cellSize;
  final double tokenSize;
  final Duration duration;
  final Duration startDelay;
  final Curve curve;
  final Widget child;
  final Size? childSize;

  @override
  State<PathAnimatedToken> createState() => _PathAnimatedTokenState();
}

class _PathAnimatedTokenState extends State<PathAnimatedToken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.startDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.startDelay, () {
        if (!mounted) return;
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _centerForCell(BoardCell cell) {
    final rect = Rect.fromLTWH(
      widget.board.left + cell.col * widget.cellSize,
      widget.board.top + cell.row * widget.cellSize,
      widget.cellSize,
      widget.cellSize,
    );
    return rect.center;
  }

  Offset _positionFor(double progress) {
    final segmentCount = widget.waypoints.length - 1;
    if (segmentCount <= 0) {
      return _centerForCell(widget.waypoints.first);
    }

    final scaled = progress * segmentCount;
    final segmentIndex = math.min(scaled.floor(), segmentCount - 1);
    final localProgress = widget.curve.transform(scaled - segmentIndex);

    return Offset.lerp(
      _centerForCell(widget.waypoints[segmentIndex]),
      _centerForCell(widget.waypoints[segmentIndex + 1]),
      localProgress,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final center = _positionFor(_controller.value);
        final childSize = widget.childSize ?? Size.square(widget.tokenSize);
        return Positioned(
          left: center.dx - childSize.width / 2,
          top: center.dy - childSize.height / 2,
          width: childSize.width,
          height: childSize.height,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
