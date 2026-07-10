import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/home/screens/main_shell_screen.dart';
import 'package:isto_king/features/wallet/coin_wallet.dart';

class IstoKingApp extends StatefulWidget {
  const IstoKingApp({super.key});

  @override
  State<IstoKingApp> createState() => _IstoKingAppState();
}

class _IstoKingAppState extends State<IstoKingApp> {
  @override
  void initState() {
    super.initState();
    CoinWallet.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: RoyalColors.outerRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Chaka',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: RoyalColors.parchment,
          colorScheme: ColorScheme.fromSeed(seedColor: RoyalColors.red),
          fontFamily: 'Georgia',
        ),
        home: const MainShellScreen(),
      ),
    );
  }
}
