import 'package:flutter/material.dart';
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
const _buttonGapBelowBg = 12.0;

class WinRankingPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (playersByRank.length < 4) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final layoutWidth = width > _positionLockWidth ? _positionLockWidth : width;
        final layoutLeftOffset = (width - layoutWidth) / 2;
        final bgTopInset = height * _bgTopInset;
        final bgWidth = width * (1 - _bgHorizontalInset * 2);
        final baseBgWidth = _positionLockWidth * (1 - _bgHorizontalInset * 2);
        final widthScale = (bgWidth / baseBgWidth).clamp(1.0, 1.6);
        final boostedScale = (1 + ((widthScale - 1) * 1.65)).toDouble();
        final bgBottomInset =
            (height * _bgBottomInset / boostedScale).clamp(height * 0.08, height).toDouble();
        final bgHeight = (height - bgTopInset - bgBottomInset).clamp(0.0, height).toDouble();

        return Stack(
          children: [
            Positioned(
              top: height * _headerTopInset,
              left: layoutLeftOffset,
              width: layoutWidth,
              child: _MatchResultHeader(width: layoutWidth),
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
              ),
            ),
            Positioned(
              left: layoutLeftOffset + (layoutWidth - _centerCardWidth) / 2,
              top: height * 0.16,
              width: _centerCardWidth,
              child: _RankCard(
                player: playersByRank[0],
                rank: 1,
                width: _centerCardWidth,
                height: height * 0.32,
                rankLabel: '1st Place',
                showCrown: true,
              ),
            ),
            Positioned(
              left: layoutLeftOffset + (layoutWidth - _lowerCardWidth) / 2,
              bottom: height * 0.20,
              width: _lowerCardWidth,
              child: _RankCard(
                player: playersByRank[3],
                rank: 4,
                width: _lowerCardWidth,
                height: height * 0.30,
                rankLabel: '4th Place',
              ),
            ),
            Positioned(
              left: layoutLeftOffset + layoutWidth * 0.04,
              top: height * 0.38,
              width: _sideCardWidth,
              child: _RankCard(
                player: playersByRank[1],
                rank: 2,
                width: _sideCardWidth,
                height: height * 0.30,
                rankLabel: '2nd Place',
              ),
            ),
            Positioned(
              right: layoutLeftOffset + layoutWidth * 0.04,
              top: height * 0.38,
              width: _sideCardWidth,
              child: _RankCard(
                player: playersByRank[2],
                rank: 3,
                width: _sideCardWidth,
                height: height * 0.30,
                rankLabel: '3rd Place',
              ),
            ),
            Positioned(
              top: bgTopInset + bgHeight + _buttonGapBelowBg,
              left: 0,
              right: 0,
              child: Center(
                child: WinActionButtons(
                  onPlayAgain: onPlayAgain,
                  onHome: onHome,
                ),
              ),
            ),
          ],
        );
      },
    );
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
    final avatarSize = height * (rank == 1 ? 0.36 : 0.34);
    final radius = rank == 1 ? 22.0 : 18.0;
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
                    width: rank == 1 ? 6.2 : 5.8,
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
                    10,
                    isSecondOrThird ? 8 : 10,
                    10,
                    isSecondOrThird ? 8 : 10,
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
                              border: Border.all(color: borderColor, width: 3),
                            ),
                            child: ClipOval(
                              child: Image.asset(player.avatarAsset, fit: BoxFit.cover),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSecondOrThird ? 6 : 7),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: player.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSecondOrThird ? 6 : 7),
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
                      SizedBox(height: isSecondOrThird ? 6 : 7),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: placeChipColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            rankLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
