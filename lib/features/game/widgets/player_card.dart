import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/game_constants.dart';
import 'package:isto_king/features/game/widgets/cowrie_count_overlay.dart';
import 'package:isto_king/features/game/widgets/cowrie_roll_panel.dart';

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
    this.rollResetSerial = 0,
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
  final int rollResetSerial;
  final ValueChanged<int>? onRollComplete;

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  int? _rollOverlayCount;

  void _handleRollStarted() {
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
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: widget.isActive ? 0.58 : 0.35,
                      ),
                      blurRadius: widget.isActive ? 18 : 12,
                      spreadRadius: widget.isActive ? 1 : 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
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
                      CowrieRollPanel(
                        playerColor: widget.color,
                        showShells: widget.showShells,
                        canRoll: widget.isActive && widget.canRoll,
                        resetSerial: widget.rollResetSerial,
                        shellCount: widget.shellCount,
                        shellSize: shellSize,
                        alignRight: widget.avatarOnRight,
                        onRollStarted: widget.isActive && widget.canRoll
                            ? _handleRollStarted
                            : null,
                        onRollComplete: widget.isActive && widget.canRoll
                            ? _handleRollComplete
                            : null,
                      ),
                    ],
                  ),
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
