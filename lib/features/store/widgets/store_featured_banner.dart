import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/widgets/coin_icon.dart';
import 'package:isto_king/features/store/models/store_item.dart';

class StoreFeaturedBanner extends StatefulWidget {
  const StoreFeaturedBanner({
    required this.bundles,
    super.key,
  });

  final List<FeaturedBundle> bundles;

  @override
  State<StoreFeaturedBanner> createState() => _StoreFeaturedBannerState();
}

class _StoreFeaturedBannerState extends State<StoreFeaturedBanner> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.bundles.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _FeaturedCard(bundle: widget.bundles[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.bundles.length, (index) {
            final active = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 7,
              height: active ? 10 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? RoyalColors.darkRed
                    : RoyalColors.brown.withValues(alpha: 0.35),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.bundle});

  final FeaturedBundle bundle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B1B1F), Color(0xFF5A0505)],
        ),
        border: Border.all(color: RoyalColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.darkRed.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: _RibbonBadge(label: bundle.limitedBadge),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _StarburstBadge(label: bundle.valueBadge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.title,
                        style: const TextStyle(
                          color: Color(0xFFFFE39D),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bundle.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const CoinIcon(size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${bundle.coins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.grid_on,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _PriceButton(
                          label: bundle.priceLabel,
                          color: RoyalColors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _BundleIllustration(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/full-board.png',
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 18,
            left: 8,
            child: CoinIcon(size: 34),
          ),
          Positioned(
            top: 8,
            right: 4,
            child: Icon(
              Icons.grid_on,
              size: 28,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            child: Icon(
              Icons.local_fire_department,
              size: 22,
              color: RoyalColors.yellow.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonBadge extends StatelessWidget {
  const _RibbonBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: RoyalColors.red,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StarburstBadge extends StatelessWidget {
  const _StarburstBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: RoyalColors.yellow,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: RoyalColors.darkBrown,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  const _PriceButton({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: RoyalColors.darkBrown,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}
