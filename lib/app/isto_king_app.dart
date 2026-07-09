import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/home/screens/main_shell_screen.dart';

class IstoKingApp extends StatelessWidget {
  const IstoKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: RoyalColors.outerRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Isto King',
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
