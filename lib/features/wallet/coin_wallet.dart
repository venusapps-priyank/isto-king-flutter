import 'package:flutter/foundation.dart';
import 'package:isto_king/features/wallet/data/coin_wallet_repository.dart';

class CoinWallet {
  CoinWallet._();

  static final CoinWallet instance = CoinWallet._();

  final CoinWalletRepository _repository = CoinWalletRepository();
  final ValueNotifier<int> balance = ValueNotifier<int>(
    CoinWalletRepository.defaultBalance,
  );

  bool _isLoaded = false;

  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    balance.value = await _repository.getBalance();
    _isLoaded = true;
  }

  Future<int> addCoins(int amount) async {
    await ensureLoaded();
    final nextBalance = await _repository.addCoins(amount);
    balance.value = nextBalance;
    return nextBalance;
  }
}
