import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/core/widgets/app_screen_scaffold.dart';
import 'package:istochaka/core/widgets/royal_screen_frame.dart';
import 'package:istochaka/features/home/screens/main_shell_screen.dart';
import 'package:istochaka/features/wallet/coin_wallet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _iconAsset = 'assets/app_icons/app-icon-transperant.png';
  static const _minDisplayDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      CoinWallet.instance.ensureLoaded(),
      Future<void>.delayed(_minDisplayDuration),
    ]);
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const MainShellScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconWidth = MediaQuery.sizeOf(context).width * 0.72;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: RoyalColors.outerRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AppScreenScaffold(
        body: RoyalScreenFrame(
          child: Center(
            child: Image.asset(
              _iconAsset,
              width: iconWidth,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ),
      ),
    );
  }
}
