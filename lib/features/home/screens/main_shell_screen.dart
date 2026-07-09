import 'package:flutter/material.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/screens/home_screen.dart';
import 'package:isto_king/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:isto_king/features/store/screens/store_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  HomeNavTab _selectedTab = HomeNavTab.home;
  UserProfile _profile = UserProfile.defaultProfile;

  int get _tabIndex => switch (_selectedTab) {
        HomeNavTab.rules => 0,
        HomeNavTab.home => 1,
        HomeNavTab.store => 2,
      };

  void _onTabSelected(HomeNavTab tab) {
    setState(() => _selectedTab = tab);
  }

  void _onProfileChanged(UserProfile profile) {
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final navPadding = _bottomNavPadding(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const _RulesTabPlaceholder(),
                HomeScreen(
                  profile: _profile,
                  onProfileChanged: _onProfileChanged,
                  embedded: true,
                ),
                StoreScreen(
                  profile: _profile,
                  onProfileChanged: _onProfileChanged,
                  embedded: true,
                ),
              ],
            ),
          ),
          Positioned(
            left: navPadding.left,
            right: navPadding.right,
            bottom: navPadding.bottom,
            child: HomeBottomNavBar(
              selectedTab: _selectedTab,
              onTabSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _bottomNavPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compactWidth = width < 360;
    final narrowWidth = width < 430;
    final horizontalPadding = compactWidth
        ? (width * 0.16).clamp(42.0, 60.0).toDouble()
        : narrowWidth
            ? (width * 0.13).clamp(42.0, 56.0).toDouble()
            : (width * 0.095).clamp(32.0, 42.0).toDouble();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return EdgeInsets.fromLTRB(
      horizontalPadding,
      0,
      horizontalPadding,
      bottomInset > 0 ? bottomInset : 8,
    );
  }
}

class _RulesTabPlaceholder extends StatelessWidget {
  const _RulesTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFFBE9C9)),
      child: Center(
        child: Text(
          'RULES',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF700000),
          ),
        ),
      ),
    );
  }
}
