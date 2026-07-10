import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/game/widgets/coin_balance_pill.dart';
import 'package:istochaka/features/home/models/user_profile.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.profile,
    required this.onEditProfileTap,
    required this.onSettingsTap,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfileTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final gap = compact ? 6.0 : 8.0;

        return Row(
          children: [
            _ProfileIdentity(
              compact: compact,
              profile: profile,
              onEditTap: onEditProfileTap,
            ),
            SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
            const CoinBalancePill(),
            SizedBox(width: gap),
            _SettingsButton(
              onTap: onSettingsTap,
              size: compact ? 34 : 36,
            ),
          ],
        );
      },
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.compact,
    required this.profile,
    required this.onEditTap,
  });

  final bool compact;
  final UserProfile profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = compact ? 23.0 : 28.0;
    final editSize = compact ? 19.0 : 22.0;
    final editIconSize = compact ? 11.0 : 13.0;
    final textGap = compact ? 7.0 : 10.0;
    final nameSize = compact ? 15.0 : 18.0;
    final levelSize = compact ? 9.0 : 10.0;
    final progressWidth = compact ? 88.0 : 116.0;
    final progressHeight = compact ? 6.0 : 8.0;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEditTap,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFFE6C8A1),
                  backgroundImage: AssetImage(profile.avatarAsset),
                ),
                Positioned(
                  right: -2,
                  bottom: -1,
                  child: Container(
                    height: editSize,
                    width: editSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8ECD2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD8B98F),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: editIconSize,
                      color: RoyalColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: textGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                fontSize: nameSize,
                fontWeight: FontWeight.w900,
                height: 0.9,
                color: RoyalColors.darkBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Level 12',
              style: TextStyle(
                fontSize: levelSize,
                fontWeight: FontWeight.w700,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: compact ? 4 : 6),
            SizedBox(
              width: progressWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: 0.48,
                  minHeight: progressHeight,
                  backgroundColor: const Color(0xFFE8D6B3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(profile.themeColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap, required this.size});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.58;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DC),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD8B98F),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.brown.withValues(alpha: 0.16),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            height: size,
            width: size,
            child: Center(
              child: Icon(
                Icons.settings,
                size: iconSize,
                color: RoyalColors.darkBrown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
