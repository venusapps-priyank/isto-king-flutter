import 'package:flutter/material.dart';
import 'package:isto_king/features/game/models/player_info.dart';

const _firstRankCrownAsset = 'assets/images/rank_crown_1.png';
const _firstPlaceAsset = 'assets/images/1st.png';
const _secondPlaceAsset = 'assets/images/2nd.png';
const _thirdPlaceAsset = 'assets/images/3rd.png';
const _fourthPlaceAsset = 'assets/images/4th.png';
const _centerCardWidth = 220.0;
const _sideCardWidth = 160.0;
const _lowerCardWidth = 170.0;
const _positionLockWidth = 500.0;

class WinRankingPanel extends StatelessWidget {
  const WinRankingPanel({required this.playersByRank, super.key});

  final List<PlayerInfo> playersByRank;

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

        return Stack(
          children: [
            Positioned(
              left: layoutLeftOffset + (layoutWidth - _centerCardWidth) / 2,
              top: height * 0.12,
              width: _centerCardWidth,
              child: _RankCard(
                player: playersByRank[0],
                rank: 1,
                height: height * 0.32,
                rankLabel: '1st Place',
                showCrown: true,
              ),
            ),
            Positioned(
              left: layoutLeftOffset + (layoutWidth - _lowerCardWidth) / 2,
              bottom: height * 0.13,
              width: _lowerCardWidth,
              child: _RankCard(
                player: playersByRank[3],
                rank: 4,
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
                height: height * 0.30,
                rankLabel: '3rd Place',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.player,
    required this.rank,
    required this.height,
    required this.rankLabel,
    this.showCrown = false,
  });

  final PlayerInfo player;
  final int rank;
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
    final crownAreaHeight = showCrown ? avatarSize * 0.52 : 0.0;

    return SizedBox(
      height: height + crownAreaHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: crownAreaHeight,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F0DE),
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
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    10,
                    isSecondOrThird ? 8 : 10,
                    10,
                    isSecondOrThird ? 8 : 12,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        isSecondOrThird ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      if (!showCrown)
                        SizedBox(height: isSecondOrThird ? 0 : avatarSize * 0.25),
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
                      SizedBox(height: isSecondOrThird ? 6 : 8),
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
                      SizedBox(height: isSecondOrThird ? 5 : 7),
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
                      SizedBox(height: isSecondOrThird ? 5 : 7),
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
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                _firstRankCrownAsset,
                width: avatarSize * 1.02,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
