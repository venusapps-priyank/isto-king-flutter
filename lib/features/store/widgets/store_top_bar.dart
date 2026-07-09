import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/widgets/coin_icon.dart';
import 'package:isto_king/features/home/models/user_profile.dart';

class StoreTopBar extends StatelessWidget {
  const StoreTopBar({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final gap = compact ? 5.0 : 7.0;

        return Row(
          children: [
            _ProfileChip(compact: compact, profile: profile),
            SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
            _CurrencyPill(
              compact: compact,
              icon: const CoinIcon(size: 22),
              amount: '120',
              addColor: const Color(0xFF3AAA45),
            ),
            SizedBox(width: gap),
            _NotificationButton(size: compact ? 32 : 36),
          ],
        );
      },
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.compact, required this.profile});

  final bool compact;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = compact ? 20.0 : 24.0;

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: const Color(0xFFE6C8A1),
          backgroundImage: AssetImage(profile.avatarAsset),
        ),
        SizedBox(width: compact ? 6 : 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w900,
                color: RoyalColors.darkBrown,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Level 12',
              style: TextStyle(
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w700,
                color: RoyalColors.darkBrown,
              ),
            ),
            SizedBox(height: compact ? 3 : 4),
            SizedBox(
              width: compact ? 72 : 96,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: 0.48,
                  minHeight: compact ? 5 : 6,
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

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({
    required this.compact,
    required this.icon,
    required this.amount,
    required this.addColor,
  });

  final bool compact;
  final Widget icon;
  final String amount;
  final Color addColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 30 : 34,
      padding: EdgeInsets.fromLTRB(compact ? 4 : 6, 2, 2, 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1B2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RoyalColors.brown.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: compact ? 4 : 5),
          Text(
            amount,
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 14 : 16,
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          CircleAvatar(
            radius: compact ? 11 : 12,
            backgroundColor: addColor,
            child: Icon(Icons.add, color: Colors.white, size: compact ? 15 : 17),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2DC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD8B98F), width: 1.5),
            ),
            child: Icon(
              Icons.notifications,
              size: size * 0.55,
              color: RoyalColors.darkBrown,
            ),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: RoyalColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
