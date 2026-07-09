import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/game_constants.dart';
import 'package:isto_king/features/game/widgets/cowrie_count_overlay.dart';
import 'package:isto_king/features/game/widgets/cowrie_roll_panel.dart';

const _firstRankCrownAsset = 'assets/images/rank_crown_1.png';

class PlayerCard extends StatefulWidget {
  const PlayerCard({
    required this.name,
    required this.color,
    required this.avatarAsset,
    this.avatarOnRight = false,
    this.shellCount = defaultShellCount,
    this.isActive = false,
    this.showShells = false,
    this.canRoll = true,
    this.enableTap = true,
    this.autoRollSerial = 0,
    this.rollResetSerial = 0,
    this.finishRank,
    this.onRollStarted,
    this.onRollComplete,
    super.key,
  });

  final String name;
  final Color color;
  final String avatarAsset;
  final bool avatarOnRight;
  final int shellCount;
  final bool isActive;
  final bool showShells;
  final bool canRoll;
  final bool enableTap;
  final int autoRollSerial;
  final int rollResetSerial;
  final int? finishRank;
  final VoidCallback? onRollStarted;
  final ValueChanged<int>? onRollComplete;

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  int? _rollOverlayCount;

  void _handleRollStarted() {
    widget.onRollStarted?.call();
    if (_rollOverlayCount == null) return;
    setState(() => _rollOverlayCount = null);
  }

  void _handleRollComplete(int value) {
    setState(() => _rollOverlayCount = value);
    widget.onRollComplete?.call(value);
  }

  @override
  void didUpdateWidget(covariant PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rollResetSerial != widget.rollResetSerial &&
        _rollOverlayCount != null) {
      setState(() => _rollOverlayCount = null);
    }
    if (oldWidget.showShells && !widget.showShells && _rollOverlayCount != null) {
      setState(() => _rollOverlayCount = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rollCallbacksEnabled = widget.isActive && widget.showShells;
        final height = constraints.maxHeight;
        final avatarSize = height * 0.68;
        final cardLeft = avatarSize * 0.36;
        final cardTop = height * 0.12;
        final cardBottom = height * 0.03;
        final contentLeft = avatarSize * 0.76;
        final nameSize = height < 96 ? 15.0 : 17.0;
        final contentWidth = constraints.maxWidth - cardLeft - contentLeft - 9;
        final shellSize = math.min(
          height < 96 ? 38.0 : 42.0,
          contentWidth / 2.95,
        );
        final avatarTop = height * 0.14;
        final overlaySize = avatarSize * 0.4;
        final overlayInset = overlaySize * 0.12;
        final isRanked = widget.finishRank != null;
        final rankPanelHeight = math.min(shellSize, height * 0.38);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              left: widget.avatarOnRight ? 0 : cardLeft,
              right: widget.avatarOnRight ? cardLeft : 0,
              top: cardTop,
              bottom: cardBottom,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isRanked ? RoyalColors.gold : Colors.white,
                    width: isRanked ? 2.4 : 2,
                  ),
                  boxShadow: [
                    if (isRanked)
                      BoxShadow(
                        color: RoyalColors.gold.withValues(alpha: 0.46),
                        blurRadius: 22,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: widget.isActive || isRanked ? 0.58 : 0.35,
                      ),
                      blurRadius: widget.isActive || isRanked ? 18 : 12,
                      spreadRadius: widget.isActive || isRanked ? 1 : 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (isRanked)
                      const Positioned.fill(
                        child: CustomPaint(painter: _WinSparklePainter()),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: widget.avatarOnRight ? 9 : contentLeft,
                        right: widget.avatarOnRight ? contentLeft : 9,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: widget.avatarOnRight
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: nameSize + 4,
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: widget.avatarOnRight
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                widget.name,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: nameSize,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  shadows: const [
                                    Shadow(
                                      color: RoyalColors.brown,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: shellSize,
                            width: double.infinity,
                            child: widget.finishRank == null
                                ? CowrieRollPanel(
                                    playerColor: widget.color,
                                    showShells: widget.showShells,
                                    canRoll: widget.isActive && widget.canRoll,
                                    enableTap:
                                        widget.isActive && widget.enableTap,
                                    autoRollSerial: widget.autoRollSerial,
                                    resetSerial: widget.rollResetSerial,
                                    shellCount: widget.shellCount,
                                    shellSize: shellSize,
                                    alignRight: widget.avatarOnRight,
                                    onRollStarted:
                                        rollCallbacksEnabled
                                            ? _handleRollStarted
                                            : null,
                                    onRollComplete:
                                        rollCallbacksEnabled
                                            ? _handleRollComplete
                                            : null,
                                  )
                                : _FinishedRankPanel(
                                    rank: widget.finishRank!,
                                    height: rankPanelHeight,
                                    alignRight: widget.avatarOnRight,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: widget.avatarOnRight ? null : 0,
              right: widget.avatarOnRight ? 0 : null,
              top: avatarTop,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                      boxShadow: [
                        if (isRanked)
                          BoxShadow(
                            color: RoyalColors.gold.withValues(alpha: 0.38),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(avatarSize * 0.04),
                      child: ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: ColoredBox(
                          color: RoyalColors.parchmentLight,
                          child: SizedBox.square(
                            dimension: avatarSize * 0.92,
                            child: Image.asset(
                              widget.avatarAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.finishRank == 1)
                    Positioned(
                      left: widget.avatarOnRight ? null : -avatarSize * 0.05,
                      right: widget.avatarOnRight ? -avatarSize * 0.02 : null,
                      top: -avatarSize * 0.37,
                      child: Transform.rotate(
                        angle: widget.avatarOnRight ? 0.24 : -0.24,
                        child: Image.asset(
                          _firstRankCrownAsset,
                          width: avatarSize * 0.82,
                          height: avatarSize * 0.52,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  if (widget.showShells && _rollOverlayCount != null)
                    Positioned(
                      right: widget.avatarOnRight ? null : -overlayInset,
                      left: widget.avatarOnRight ? -overlayInset : null,
                      bottom: -overlayInset,
                      child: CowrieCountOverlay(
                        value: _rollOverlayCount!,
                        size: overlaySize,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FinishedRankPanel extends StatelessWidget {
  const _FinishedRankPanel({
    required this.rank,
    required this.height,
    required this.alignRight,
  });

  final int rank;
  final double height;
  final bool alignRight;

  String get _label {
    return switch (rank) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${rank}th',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RoyalColors.darkBrown.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: height * 0.1,
              right: height * 0.34,
              top: height * 0.08,
              bottom: height * 0.08,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MedalBadge(rank: rank, size: height * 1.08),
                SizedBox(width: height * 0.14),
                Text(
                  'Finished',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: const [
                      Shadow(
                        color: RoyalColors.darkBrown,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: height * 0.12),
                Text(
                  _label,
                  style: TextStyle(
                    color: RoyalColors.gold,
                    fontSize: height * 0.36,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: const [
                      Shadow(
                        color: RoyalColors.darkBrown,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge({
    required this.rank,
    required this.size,
  });

  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _MedalPainter()),
          ),
          SizedBox.square(
            dimension: size * 0.64,
            child: Center(
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: const [
                    Shadow(
                      color: RoyalColors.darkBrown,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  const _MedalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.32;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = RoyalColors.gold,
    );
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()..color = const Color(0xFFF7BA35),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.14
        ..color = Colors.white.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _MedalPainter oldDelegate) => false;
}

class _WinSparklePainter extends CustomPainter {
  const _WinSparklePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..strokeWidth = math.max(1.0, size.height * 0.018)
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.12, size.height * 0.82),
    ];

    for (final point in points) {
      final sparkle = size.height * 0.055;
      canvas.drawLine(
        point.translate(-sparkle, 0),
        point.translate(sparkle, 0),
        paint,
      );
      canvas.drawLine(
        point.translate(0, -sparkle),
        point.translate(0, sparkle),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WinSparklePainter oldDelegate) => false;
}
