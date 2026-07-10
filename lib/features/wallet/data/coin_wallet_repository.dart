import 'package:shared_preferences/shared_preferences.dart';

class CoinWalletRepository {
  static const _balanceKey = 'player_coin_balance';
  static const defaultBalance = 120;

  Future<int> getBalance() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_balanceKey) ?? defaultBalance;
  }

  Future<int> addCoins(int amount) async {
    if (amount <= 0) return getBalance();

    final preferences = await SharedPreferences.getInstance();
    final nextBalance = (preferences.getInt(_balanceKey) ?? defaultBalance) + amount;
    await preferences.setInt(_balanceKey, nextBalance);
    return nextBalance;
  }

  Future<void> setBalance(int balance) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_balanceKey, balance);
  }
}
