import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/models/player_info.dart';
import 'package:isto_king/features/game/widgets/win_action_buttons.dart';

const _matchResultBannerAsset = 'assets/images/match_result_banner.png';
const _firstRankCrownAsset = 'assets/images/rank_crown_1.png';
const _firstPlaceAsset = 'assets/images/1st.png';
const _secondPlaceAsset = 'assets/images/2nd.png';
const _thirdPlaceAsset = 'assets/images/3rd.png';
const _fourthPlaceAsset = 'assets/images/4th.png';
const _centerCardWidth = 200.0;
const _sideCardWidth = 160.0;
const _lowerCardWidth = 170.0;
const _positionLockWidth = 500.0;
const _bgTopInset = 0.17;
const _headerTopInset = 0.03;
const _bgBottomInset = 0.18;
const _bgHorizontalInset = 0.000;
const _actionButtonHeight = 58.0;
const _buttonGapBelowBg = 12.0;
const _buttonAreaBottomPadding = 4.0;
const _entranceBaseDelayMs = 180;
const _entranceStaggerMs = 120;
const _entranceDurationMs = 400;
const _buttonsEntranceDelayMs = 680;
const _exitDurationMs = 240;
const _exitStaggerMs = 35;
const _panelExitDurationMs = _exitDurationMs + (_exitStaggerMs * 3) + 40;

double _safeClamp(double value, double min, double max) {
  final lower = math.min(min, max);
  final upper = math.max(min, max);
  return value.clamp(lower, upper);
}

extension _WinRankingMotion on Widget {
  Widget animateRankCard({
    required bool exiting,
    required int order,
    Offset slideBegin = const Offset(0, 0.22),
  }) {
    if (exiting) {
      final delay = ((_exitStaggerMs * 3) - order * _exitStaggerMs).ms;
      return animate()
          .fadeOut(duration: 180.ms, delay: delay)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.78, 0.78),
            duration: _exitDurationMs.ms,
            delay: delay,
            curve: Curves.easeInCubic,
          )
          .slide(
            begin: Offset.zero,
            end: slideBegin,
            duration: _exitDurationMs.ms,
            delay: delay,
            curve: Curves.easeInCubic,
          );
    }

    final delay = (_entranceBaseDelayMs + order * _entranceStaggerMs).ms;
    return animate()
        .fadeIn(duration: 220.ms, delay: delay)
        .scale(
          begin: const Offset(0.72, 0.72),
          end: const Offset(1, 1),
          duration: _entranceDurationMs.ms,
          delay: delay,
          curve: Curves.elasticOut,
        )
        .slide(
          begin: slideBegin,
          end: Offset.zero,
          duration: 360.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        );
  }

  Widget animateHeader({required bool exiting}) {
    if (exiting) {
      return animate()
          .fadeOut(duration: 180.ms)
          .slideY(
            begin: 0,
            end: -0.14,
            duration: _exitDurationMs.ms,
            curve: Curves.easeInCubic,
          );
    }
    return animate()
        .fadeIn(duration: 280.ms, delay: 80.ms)
        .slideY(
          begin: -0.18,
          end: 0,
          duration: 340.ms,
          delay: 80.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 340.ms,
          delay: 80.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget animateBackdrop({required bool exiting}) {
    if (exiting) {
      return animate()
          .fadeOut(duration: 200.ms)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.97, 0.97),
            duration: _exitDurationMs.ms,
            curve: Curves.easeInCubic,
          );
    }
    return animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.96, 0.94),
          end: const Offset(1, 1),
          duration: 360.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget animateActionButtons({required bool exiting}) {
    if (exiting) {
      return animate()
          .fadeOut(duration: 160.ms)
          .slideY(
            begin: 0,
            end: 0.2,
            duration: 200.ms,
            curve: Curves.easeInCubic,
          );
    }
    return animate()
        .fadeIn(duration: 260.ms, delay: _buttonsEntranceDelayMs.ms)
        .slideY(
          begin: 0.25,
          end: 0,
          duration: 340.ms,
          delay: _buttonsEntranceDelayMs.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class WinRankingPanel extends StatefulWidget {
  const WinRankingPanel({
    required this.playersByRank,
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  final List<PlayerInfo> playersByRank;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  State<WinRankingPanel> createState() => _WinRankingPanelState();
}

class _WinRankingPanelState extends State<WinRankingPanel> {
  bool _isExiting = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(
        const Duration(milliseconds: _entranceBaseDelayMs),
      );
      if (!mounted || _isExiting) return;
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handlePlayAgain() {
    if (_isExiting) return;

    _confettiController.stop();
    setState(() => _isExiting = true);
    Future<void>.delayed(const Duration(milliseconds: _panelExitDurationMs), () {
      if (!mounted) return;
      widget.onPlayAgain();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isExiting,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final playerCount = widget.playersByRank.length;
          if (playerCount == 0) return const SizedBox.shrink();
          final panelScale = (width / _positionLockWidth).clamp(0.78, 1.0);
          final heightScale = (height / 820).clamp(0.8, 1.0);
          final responsiveScale = (panelScale * heightScale).clamp(0.72, 1.0);

          final layoutWidth = width > _positionLockWidth ? _positionLockWidth : width;
          final layoutLeftOffset = (width - layoutWidth) / 2;
          final bgTopInset = height * _bgTopInset;
          final bgWidth = width * (1 - _bgHorizontalInset * 2);
          final baseBgWidth = _positionLockWidth * (1 - _bgHorizontalInset * 2);
          final widthScale = (bgWidth / baseBgWidth).clamp(1.0, 1.6);
          final boostedScale = (1 + ((widthScale - 1) * 1.65)).toDouble();
          final buttonAreaHeight =
              _actionButtonHeight + _buttonGapBelowBg + _buttonAreaBottomPadding;
          final compactHeight = height < 680;
          final bgBottomInset = math
              .max(
                height * _bgBottomInset / boostedScale,
                buttonAreaHeight + (compactHeight ? 8 : 0),
              )
              .clamp(buttonAreaHeight, height * 0.24)
              .toDouble();
          final bgHeight =
              (height - bgTopInset - bgBottomInset).clamp(0.0, height).toDouble();
          final cardBottomInset = compactHeight ? 0.14 : 0.20;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: height * _headerTopInset,
                left: layoutLeftOffset,
                width: layoutWidth,
                child: _MatchResultHeader(width: layoutWidth).animateHeader(exiting: _isExiting),
              ),
              Positioned(
                left: width * _bgHorizontalInset,
                top: bgTopInset,
                height: bgHeight,
                width: bgWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A190D).withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ).animateBackdrop(exiting: _isExiting),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: playerCount == 4
                      ? _buildFourPlayerCards(
                          width: width,
                          height: height,
                          layoutWidth: layoutWidth,
                          layoutLeftOffset: layoutLeftOffset,
                          responsiveScale: responsiveScale,
                          cardBottomInset: cardBottomInset,
                        )
                      : _buildCompactCards(
                          width: width,
                          height: height,
                          layoutWidth: layoutWidth,
                          layoutLeftOffset: layoutLeftOffset,
                          responsiveScale: responsiveScale,
                          cardBottomInset: cardBottomInset,
                        ),
                ),
              ),
              Positioned(
                top: bgTopInset + bgHeight + _buttonGapBelowBg,
                left: 12,
                right: 12,
                child: WinActionButtons(
                  onPlayAgain: _handlePlayAgain,
                  onHome: widget.onHome,
                ).animateActionButtons(exiting: _isExiting),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFourPlayerCards({
    required double width,
    required double height,
    required double layoutWidth,
    required double layoutLeftOffset,
    required double responsiveScale,
    required double cardBottomInset,
  }) {
    final firstCardWidth = _safeClamp(
      _centerCardWidth * responsiveScale,
      layoutWidth * 0.30,
      math.min(_centerCardWidth, layoutWidth * 0.48),
    );
    final sideCardWidth = _safeClamp(
      _sideCardWidth * responsiveScale,
      layoutWidth * 0.24,
      math.min(_sideCardWidth, layoutWidth * 0.38),
    );
    final lowerCardWidth = _safeClamp(
      _lowerCardWidth * responsiveScale,
      layoutWidth * 0.26,
      math.min(_lowerCardWidth, layoutWidth * 0.40),
    );
    final firstCardLeft = layoutLeftOffset + (layoutWidth - firstCardWidth) / 2;
    final firstCardTop = height * 0.16;
    final firstCardHeight = _safeClamp(
      height * (0.32 * responsiveScale + 0.04),
      height * 0.24,
      height * 0.32,
    );
    final sideCardHeight = _safeClamp(
      height * (0.30 * responsiveScale + 0.03),
      height * 0.22,
      height * 0.30,
    );

    return Stack(
      children: [
        Positioned(
          left: firstCardLeft + (firstCardWidth / 2),
          top: firstCardTop + (firstCardHeight * 0.55),
          child: _buildConfetti(width, height),
        ),
        Positioned(
          left: firstCardLeft,
          top: firstCardTop,
          width: firstCardWidth,
          child: _RankCard(
            player: widget.playersByRank[0],
            rank: 1,
            width: firstCardWidth,
            height: firstCardHeight,
            rankLabel: '1st Place',
            showCrown: true,
          ).animateRankCard(
            exiting: _isExiting,
            order: 0,
            slideBegin: const Offset(0, -0.2),
          ),
        ),
        Positioned(
          left: layoutLeftOffset + (layoutWidth - lowerCardWidth) / 2,
          bottom: height * cardBottomInset,
          width: lowerCardWidth,
          child: _RankCard(
            player: widget.playersByRank[3],
            rank: 4,
            width: lowerCardWidth,
            height: sideCardHeight,
            rankLabel: '4th Place',
          ).animateRankCard(
            exiting: _isExiting,
            order: 3,
            slideBegin: const Offset(0, 0.32),
          ),
        ),
        Positioned(
          left: layoutLeftOffset + layoutWidth * 0.04,
          top: height * 0.38,
          width: sideCardWidth,
          child: _RankCard(
            player: widget.playersByRank[1],
            rank: 2,
            width: sideCardWidth,
            height: sideCardHeight,
            rankLabel: '2nd Place',
          ).animateRankCard(
            exiting: _isExiting,
            order: 1,
            slideBegin: const Offset(-0.35, 0.12),
          ),
        ),
        Positioned(
          right: layoutLeftOffset + layoutWidth * 0.04,
          top: height * 0.38,
          width: sideCardWidth,
          child: _RankCard(
            player: widget.playersByRank[2],
            rank: 3,
            width: sideCardWidth,
            height: sideCardHeight,
            rankLabel: '3rd Place',
          ).animateRankCard(
            exiting: _isExiting,
            order: 2,
            slideBegin: const Offset(0.35, 0.12),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCards({
    required double width,
    required double height,
    required double layoutWidth,
    required double layoutLeftOffset,
    required double responsiveScale,
    required double cardBottomInset,
  }) {
    final firstCardWidth = _safeClamp(
      layoutWidth * (0.42 * responsiveScale + 0.05),
      layoutWidth * 0.32,
      layoutWidth * 0.48,
    );
    final sideCardWidth = _safeClamp(
      layoutWidth * (0.35 * responsiveScale + 0.04),
      layoutWidth * 0.26,
      layoutWidth * 0.40,
    );
    final firstCardTop = height * 0.16;
    final firstCardHeight = _safeClamp(
      height * (0.30 * responsiveScale + 0.04),
      height * 0.23,
      height * 0.30,
    );
    final compactCardGap = height * 0.045;
    final rowTop = firstCardTop + firstCardHeight + compactCardGap;
    final rowHeight = _safeClamp(
      height * (0.25 * responsiveScale + 0.03),
      height * 0.20,
      height * 0.25,
    );
    final remainingPlayers = widget.playersByRank.skip(1).toList(growable: false);
    if (remainingPlayers.isEmpty) {
      return const SizedBox.shrink();
    }
    final spacing = remainingPlayers.length <= 1 ? 0.0 : layoutWidth * 0.04;
    final availableWidth = layoutWidth - spacing;
    final cardWidth = _safeClamp(
      availableWidth / remainingPlayers.length,
      layoutWidth * 0.24,
      sideCardWidth,
    );
    final cardsLeft = layoutLeftOffset + (layoutWidth - (cardWidth * remainingPlayers.length + spacing)) / 2;

    return Stack(
      children: [
        Positioned(
          left: layoutLeftOffset + (layoutWidth - firstCardWidth) / 2 + (firstCardWidth / 2),
          top: firstCardTop + (firstCardHeight * 0.55),
          child: _buildConfetti(width, height),
        ),
        Positioned(
          left: layoutLeftOffset + (layoutWidth - firstCardWidth) / 2,
          top: firstCardTop,
          width: firstCardWidth,
          child: _RankCard(
            player: widget.playersByRank[0],
            rank: 1,
            width: firstCardWidth,
            height: firstCardHeight,
            rankLabel: '1st Place',
            showCrown: true,
          ).animateRankCard(
            exiting: _isExiting,
            order: 0,
            slideBegin: const Offset(0, -0.2),
          ),
        ),
        for (var i = 0; i < remainingPlayers.length; i++)
          Positioned(
            left: cardsLeft + (cardWidth + spacing) * i,
            top: rowTop,
            width: cardWidth,
            child: _RankCard(
              player: remainingPlayers[i],
              rank: i + 2,
              width: cardWidth,
              height: rowHeight,
              rankLabel: '${_ordinalLabel(i + 2)} Place',
            ).animateRankCard(
              exiting: _isExiting,
              order: i + 1,
              slideBegin: const Offset(0, 0.24),
            ),
          ),
      ],
    );
  }

  Widget _buildConfetti(double width, double height) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.05,
      numberOfParticles: 16,
      maxBlastForce: 26,
      minBlastForce: 10,
      gravity: 0.14,
      canvas: Size(width, height),
      shouldLoop: false,
      colors: const [
        RoyalColors.gold,
        RoyalColors.yellow,
        RoyalColors.red,
        RoyalColors.blue,
        RoyalColors.green,
        Colors.white,
      ],
    );
  }

  String _ordinalLabel(int rank) {
    return switch (rank) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      _ => '${rank}th',
    };
  }
}

class _MatchResultHeader extends StatelessWidget {
  const _MatchResultHeader({required this.width});

  final double width;

  static const _starStyle = TextStyle(
    color: RoyalColors.gold,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1,
  );

  static TextStyle get _titleStyle => GoogleFonts.nunito(
        color: RoyalColors.darkBrown,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        height: 1,
        letterSpacing: 0.2,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(width * 0.05, 20, width * 0.05, 0),
          child: Image.asset(
            _matchResultBannerAsset,
            width: width * 0.68,
            fit: BoxFit.contain,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('★', style: _starStyle),
              const SizedBox(width: 8),
              Text('Great Game!', style: _titleStyle),
              const SizedBox(width: 8),
              const Text('★', style: _starStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.player,
    required this.rank,
    required this.width,
    required this.height,
    required this.rankLabel,
    this.showCrown = false,
  });

  final PlayerInfo player;
  final int rank;
  final double width;
  final double height;
  final String rankLabel;
  final bool showCrown;

  String? get _rankEmblemAsset {
    return switch (rank) {
      1 => _firstPlaceAsset,
      2 => _secondPlaceAsset,
      3 => _thirdPlaceAsset,
      4 => _fourthPlaceAsset,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cardScale = (width / _centerCardWidth).clamp(0.72, 1.0);
    final avatarSize = height * (rank == 1 ? 0.36 : 0.34);
    final radius = (rank == 1 ? 22.0 : 18.0) * cardScale;
    final isSecondOrThird = rank == 2 || rank == 3;
    final themeColor = player.color;
    final borderColor = HSLColor.fromColor(themeColor)
        .withLightness((HSLColor.fromColor(themeColor).lightness * 0.72).clamp(0.22, 0.55))
        .toColor();
    final placeChipColor = HSLColor.fromColor(themeColor)
        .withLightness((HSLColor.fromColor(themeColor).lightness * 0.58).clamp(0.16, 0.42))
        .toColor();
    final crownSlotHeight = showCrown ? avatarSize * 0.6 : 0.0;
    final crownSize = avatarSize * 1.75;
    final crownDownOffset = avatarSize * 0.18;

    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: crownSlotHeight),
            child: SizedBox(
              width: width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DA),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: borderColor,
                    width: (rank == 1 ? 6.2 : 5.8) * cardScale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.38),
                      blurRadius: 14,
                      spreadRadius: 1.2,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.34),
                      blurRadius: 6,
                      offset: const Offset(-1.5, -1.5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                    if (rank == 1)
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.42),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    10 * cardScale,
                    (isSecondOrThird ? 8 : 10) * cardScale,
                    10 * cardScale,
                    (isSecondOrThird ? 8 : 10) * cardScale,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 3 * cardScale),
                            ),
                            child: ClipOval(
                              child: Image.asset(player.avatarAsset, fit: BoxFit.cover),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (isSecondOrThird ? 6 : 7) * cardScale),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: player.color,
                          borderRadius: BorderRadius.circular(8 * cardScale),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * cardScale,
                            vertical: 4 * cardScale,
                          ),
                          child: Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: (14 * cardScale).clamp(11.0, 14.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (isSecondOrThird ? 6 : 7) * cardScale),
                      if (_rankEmblemAsset != null)
                        Image.asset(
                          _rankEmblemAsset!,
                          height: height * (rank == 1 ? 0.20 : 0.18),
                          fit: BoxFit.contain,
                        )
                      else
                        Icon(
                          Icons.military_tech,
                          color: borderColor,
                          size: height * 0.13,
                        ),
                      SizedBox(height: (isSecondOrThird ? 6 : 7) * cardScale),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: placeChipColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * cardScale,
                            vertical: 4 * cardScale,
                          ),
                          child: Text(
                            rankLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: (13 * cardScale).clamp(10.5, 13.0),
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
          if (showCrown)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: crownSlotHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, crownDownOffset),
                  child: Image.asset(
                    _firstRankCrownAsset,
                    width: crownSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
