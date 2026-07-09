import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:isto_king/data/home_assets.dart';

class OnlineComingSoonDialog extends StatelessWidget {
  const OnlineComingSoonDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showRoyalDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const OnlineComingSoonDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'ONLINE',
      maxWidth: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ComingSoonSubtitle(),
          const SizedBox(height: 12),
          Image.asset(
            playTogetherAsset,
            width: 260,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'Challenge players online will be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const _FeatureItem(
            icon: Icons.timer_outlined,
            iconColor: RoyalColors.red,
            title: 'Real-time battles',
            subtitle: 'Play live with players around the world.',
          ),
          const SizedBox(height: 8),
          const _FeatureItem(
            icon: Icons.groups_outlined,
            iconColor: RoyalColors.green,
            title: 'Private rooms',
            subtitle: 'Create rooms and play with your friends.',
          ),
          const SizedBox(height: 8),
          const _FeatureItem(
            icon: Icons.emoji_events_outlined,
            iconColor: RoyalColors.gold,
            title: 'Ranked matches',
            subtitle: 'Climb the leaderboard and earn rewards.',
          ),
          const SizedBox(height: 14),
          const _DialogDivider(),
          const SizedBox(height: 14),
          RoyalDialogActionButton(
            label: 'OK',
            icon: Icons.check_rounded,
            backgroundColor: RoyalColors.red,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonSubtitle extends StatelessWidget {
  const _ComingSoonSubtitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _goldLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'COMING SOON',
            style: TextStyle(
              color: RoyalColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.1,
              height: 1,
            ),
          ),
        ),
        Expanded(child: _goldLine()),
      ],
    );
  }

  Widget _goldLine() {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoyalColors.gold.withValues(alpha: 0.1),
            RoyalColors.gold,
            RoyalColors.gold.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = RoyalColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(backgroundColor, Colors.white, 0.12) ?? backgroundColor,
            Color.lerp(backgroundColor, Colors.black, 0.24) ?? backgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome,
            color: RoyalColors.gold.withValues(alpha: 0.7),
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _DialogDivider extends StatelessWidget {
  const _DialogDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: CustomPaint(
        painter: _DividerPainter(),
        size: const Size(double.infinity, 12),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = RoyalColors.gold.withValues(alpha: 0.75)
      ..strokeWidth = 1.2;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashSpace;
    }

    final diamond = Path()
      ..moveTo(size.width / 2, y - 4)
      ..lineTo(size.width / 2 + 4, y)
      ..lineTo(size.width / 2, y + 4)
      ..lineTo(size.width / 2 - 4, y)
      ..close();

    canvas.drawPath(
      diamond,
      Paint()
        ..color = RoyalColors.gold
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}