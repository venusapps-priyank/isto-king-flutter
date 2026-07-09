import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/rules_assets.dart';
import 'package:isto_king/features/rules/models/game_rule_definition.dart';

class RulesRuleIcon extends StatelessWidget {
  const RulesRuleIcon({
    required this.iconType,
    required this.size,
    super.key,
  });

  final GameRuleIconType iconType;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (iconType) {
        GameRuleIconType.cowrie => Image.asset(
          rulesCowrieAsset,
          fit: BoxFit.contain,
        ),
        GameRuleIconType.pot => Image.asset(
          rulesPotAsset,
          fit: BoxFit.contain,
        ),
        GameRuleIconType.redToken => _TokenIcon(color: RoyalColors.red),
        GameRuleIconType.greenToken => _TokenIcon(color: RoyalColors.green),
        GameRuleIconType.yellowToken => _TokenIcon(color: RoyalColors.yellow),
        GameRuleIconType.blueToken => _TokenIcon(color: RoyalColors.blue),
        GameRuleIconType.shield => const _ShieldIcon(),
        GameRuleIconType.overlappingTokens => const _OverlappingTokensIcon(),
        GameRuleIconType.dice => const _DiceIcon(),
        GameRuleIconType.trophy => const _TrophyIcon(),
        GameRuleIconType.turnOrder => const _TurnOrderIcon(),
      },
    );
  }
}

class _TokenIcon extends StatelessWidget {
  const _TokenIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TokenPainter(color: color),
    );
  }
}

class _TokenPainter extends CustomPainter {
  const _TokenPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    canvas.drawCircle(
      center + const Offset(1.5, 2),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.35)!,
            color,
            Color.lerp(color, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final starPath = _starPath(center, radius * 0.42, 5);
    canvas.drawPath(starPath, Paint()..color = RoyalColors.gold);
  }

  Path _starPath(Offset center, double radius, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _TokenPainter oldDelegate) => false;
}

class _ShieldIcon extends StatelessWidget {
  const _ShieldIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShieldPainter());
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shield = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.82, h * 0.22)
      ..lineTo(w * 0.78, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.92, w * 0.22, h * 0.62)
      ..lineTo(w * 0.18, h * 0.22)
      ..close();

    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE08A), Color(0xFFD4A017)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawPath(
      shield,
      Paint()
        ..color = RoyalColors.darkRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final starCenter = Offset(w * 0.5, h * 0.42);
    canvas.drawCircle(starCenter, w * 0.12, Paint()..color = RoyalColors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OverlappingTokensIcon extends StatelessWidget {
  const _OverlappingTokensIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 2, top: 6, child: _miniToken(RoyalColors.green)),
        Positioned(right: 2, bottom: 6, child: _miniToken(RoyalColors.red)),
      ],
    );
  }

  Widget _miniToken(Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color.lerp(color, Colors.white, 0.3)!, color],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _DiceIcon extends StatelessWidget {
  const _DiceIcon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8EA), Color(0xFFE8D4A8)],
        ),
        border: Border.all(color: RoyalColors.brown.withValues(alpha: 0.5)),
      ),
      child: const Center(
        child: Icon(Icons.casino, color: RoyalColors.darkRed, size: 28),
      ),
    );
  }
}

class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.emoji_events_rounded, color: RoyalColors.gold, size: 34),
    );
  }
}

class _TurnOrderIcon extends StatelessWidget {
  const _TurnOrderIcon();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _MiniDot(color: RoyalColors.blue),
        SizedBox(width: 2),
        Icon(Icons.arrow_forward_rounded, size: 10, color: RoyalColors.brown),
        SizedBox(width: 2),
        _MiniDot(color: RoyalColors.green),
        SizedBox(width: 2),
        Icon(Icons.arrow_forward_rounded, size: 10, color: RoyalColors.brown),
        SizedBox(width: 2),
        _MiniDot(color: RoyalColors.red),
        SizedBox(width: 2),
        Icon(Icons.arrow_forward_rounded, size: 10, color: RoyalColors.brown),
        SizedBox(width: 2),
        _MiniDot(color: RoyalColors.yellow),
      ],
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}
