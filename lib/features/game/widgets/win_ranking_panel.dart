import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/models/player_info.dart';

const _firstRankCrownAsset = 'assets/images/rank_crown_1.png';
const _firstPlaceAsset = 'assets/images/1st.png';
const _secondPlaceAsset = 'assets/images/2nd.png';
const _thirdPlaceAsset = 'assets/images/3rd.png';

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
        final centerCardWidth = width * 0.43;
        final sideCardWidth = width * 0.31;
        final lowerCardWidth = width * 0.32;

        return Stack(
          children: [
            Positioned(
              left: (width - centerCardWidth) / 2,
              top: height * 0.09,
              width: centerCardWidth,
              child: _RankCard(
                player: playersByRank[0],
                rank: 1,
                height: height * 0.43,
                accent: const Color(0xFFFFC13A),
                rankLabel: '1st Place',
                showCrown: true,
              ),
            ),
            Positioned(
              left: (width - lowerCardWidth) / 2,
              bottom: height * 0.07,
              width: lowerCardWidth,
              child: _RankCard(
                player: playersByRank[3],
                rank: 4,
                height: height * 0.30,
                accent: const Color(0xFFA4B8A7),
                rankLabel: '4th Place',
              ),
            ),
            Positioned(
              left: width * 0.06,
              top: height * 0.38,
              width: sideCardWidth,
              child: _RankCard(
                player: playersByRank[1],
                rank: 2,
                height: height * 0.30,
                accent: const Color(0xFFCFD5DD),
                rankLabel: '2nd Place',
              ),
            ),
            Positioned(
              right: width * 0.06,
              top: height * 0.38,
              width: sideCardWidth,
              child: _RankCard(
                player: playersByRank[2],
                rank: 3,
                height: height * 0.30,
                accent: const Color(0xFFD98E45),
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
    required this.accent,
    required this.rankLabel,
    this.showCrown = false,
  });

  final PlayerInfo player;
  final int rank;
  final double height;
  final Color accent;
  final String rankLabel;
  final bool showCrown;

  String? get _rankEmblemAsset {
    return switch (rank) {
      1 => _firstPlaceAsset,
      2 => _secondPlaceAsset,
      3 => _thirdPlaceAsset,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = height * (rank == 1 ? 0.36 : 0.34);
    final radius = rank == 1 ? 22.0 : 18.0;
    final isSecondOrThird = rank == 2 || rank == 3;
    final borderColor = HSLColor.fromColor(accent).withLightness(0.42).toColor();

    return DecoratedBox(
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
              color: accent.withValues(alpha: 0.42),
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
              if (showCrown)
                Transform.translate(
                  offset: Offset(0, avatarSize * 0.08),
                  child: Image.asset(
                    _firstRankCrownAsset,
                    width: avatarSize * 1.02,
                    fit: BoxFit.contain,
                  ),
                )
              else
                SizedBox(height: isSecondOrThird ? 0 : avatarSize * 0.25),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 3),
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
                  height: height * 0.13,
                  fit: BoxFit.contain,
                )
              else
                Icon(
                  Icons.military_tech,
                  color: accent,
                  size: height * 0.13,
                ),
              SizedBox(height: isSecondOrThird ? 5 : 7),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: RoyalColors.darkBrown,
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
    );
  }
}
