import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/splash/screens/splash_screen.dart';

class IstoKingApp extends StatelessWidget {
  const IstoKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: RoyalColors.outerRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: RoyalColors.parchment,
        systemNavigationBarIconBrightness: Brightness.dark,
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
        home: const SplashScreen(),
      ),
    );
  }
}
