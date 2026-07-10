import 'package:flutter/material.dart';
import 'package:isto_king/features/game/data/saved_pass_and_play_game_repository.dart';
import 'package:isto_king/features/game/screens/isto_game_screen.dart';
import 'package:isto_king/features/home/models/user_profile.dart';
import 'package:isto_king/features/home/screens/home_screen.dart';
import 'package:isto_king/features/home/widgets/continue_game_dialog.dart';
import 'package:isto_king/features/home/widgets/game_setup_dialog.dart';
import 'package:isto_king/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:isto_king/features/rules/models/game_rules_settings.dart';
import 'package:isto_king/features/rules/screens/rules_screen.dart';
import 'package:isto_king/features/store/screens/store_coming_soon_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  HomeNavTab _selectedTab = HomeNavTab.home;
  UserProfile _profile = UserProfile.defaultProfile;
  GameRulesSettings _rulesSettings = GameRulesSettings.defaults;
  final SavedPassAndPlayGameRepository _savedGameRepository =
      SavedPassAndPlayGameRepository();

  int get _tabIndex => switch (_selectedTab) {
    HomeNavTab.rules => 0,
    HomeNavTab.home => 1,
    HomeNavTab.store => 2,
  };

  void _onTabSelected(HomeNavTab tab) {
    setState(() => _selectedTab = tab);
  }

  void _openRulesFromGameSetup() {
    setState(() => _selectedTab = HomeNavTab.rules);
  }

  Future<void> _showGameSetupDialog({bool isPassAndPlay = false}) async {
    if (isPassAndPlay) {
      final savedGame = await _savedGameRepository.load();
      if (!mounted) return;

      if (savedGame != null) {
        final choice = await ContinueGameDialog.show(context);
        if (!mounted || choice == null) return;

        if (choice == ContinueGameChoice.continueGame) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => IstoGameScreen(
                setup: savedGame.setup,
                initialTurnController: savedGame.turnController,
              ),
            ),
          );
          return;
        }

        await _savedGameRepository.clear();
        if (!mounted) return;
      }
    }

    return GameSetupDialog.show(
      context,
      profile: _profile,
      rulesSettings: _rulesSettings,
      isPassAndPlay: isPassAndPlay,
      onOpenRules: _openRulesFromGameSetup,
    );
  }

  void _onProfileChanged(UserProfile profile) {
    setState(() => _profile = profile);
  }

  void _onRulesSettingsChanged(GameRulesSettings settings) {
    setState(() => _rulesSettings = settings);
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
                RulesScreen(
                  profile: _profile,
                  onProfileChanged: _onProfileChanged,
                  rulesSettings: _rulesSettings,
                  onRulesSettingsChanged: _onRulesSettingsChanged,
                  embedded: true,
                ),
                HomeScreen(
                  profile: _profile,
                  onProfileChanged: _onProfileChanged,
                  rulesSettings: _rulesSettings,
                  onShowGameSetup: (isPassAndPlay) =>
                      _showGameSetupDialog(isPassAndPlay: isPassAndPlay),
                  embedded: true,
                ),
                StoreComingSoonScreen(
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
