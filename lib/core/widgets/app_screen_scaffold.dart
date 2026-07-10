import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

/// Root scaffold for full-screen routes. Lifts the entire background above the
/// system navigation bar and fills that inset with the app background color.
class AppScreenScaffold extends StatelessWidget {
  const AppScreenScaffold({
    required this.body,
    super.key,
    this.overlays = const [],
    this.backgroundColor = RoyalColors.parchment,
    this.bottomInsetColor = RoyalColors.parchment,
  });

  final Widget body;
  final List<Widget> overlays;
  final Color backgroundColor;
  final Color bottomInsetColor;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: overlays.isEmpty
                ? body
                : Stack(
                    children: [
                      Positioned.fill(child: body),
                      ...overlays,
                    ],
                  ),
          ),
          if (bottomInset > 0)
            ColoredBox(
              color: bottomInsetColor,
              child: SizedBox(height: bottomInset, width: double.infinity),
            ),
        ],
      ),
    );
  }
}
