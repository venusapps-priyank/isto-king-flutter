import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/home/screens/home_screen.dart';

class IstoKingApp extends StatelessWidget {
  const IstoKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isto King',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: RoyalColors.parchment,
        colorScheme: ColorScheme.fromSeed(seedColor: RoyalColors.red),
        fontFamily: 'Georgia',
      ),
      home: const HomeScreen(),
    );
  }
}
