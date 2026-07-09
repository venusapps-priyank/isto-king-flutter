import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.avatarAsset,
    required this.themeColor,
  });

  final String name;
  final String avatarAsset;
  final Color themeColor;

  static const defaultProfile = UserProfile(
    name: 'Player',
    avatarAsset: 'assets/avatar/avatar-m1.png',
    themeColor: RoyalColors.red,
  );

  UserProfile copyWith({
    String? name,
    String? avatarAsset,
    Color? themeColor,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
