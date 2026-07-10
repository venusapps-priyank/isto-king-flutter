import 'package:flutter/material.dart';
import 'package:istochaka/data/rules_assets.dart';

class RulesTitleBadge extends StatelessWidget {
  const RulesTitleBadge({super.key});

  static const _maxWidth = 330.0;
  static const _aspectRatio = 2172 / 724;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(0.0, _maxWidth).toDouble();

        return Center(
          child: SizedBox(
            width: width,
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: Image.asset(
                rulesLabelAsset,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
