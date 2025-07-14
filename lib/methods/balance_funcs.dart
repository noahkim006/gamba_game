import 'package:shared_preferences/shared_preferences.dart';

Future<void> setBalance(int balance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_balance', balance);
}

Future<int> getBalance() async {
  final prefs = await SharedPreferences.getInstance();
  int? balance = prefs.getInt('user_balance');
  if (balance == null) {
    balance = 1000;
    await prefs.setInt('user_balance', balance); // Save the default
  }
  return balance;
}

Future<void> decBalanceTest() async {
  final prefs = await SharedPreferences.getInstance();
  int current = prefs.getInt('user_balance') ?? 1000;
  if (current > 0) {
    await prefs.setInt('user_balance', current - 1);
  }
}
