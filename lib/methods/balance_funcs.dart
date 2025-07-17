import 'package:gamba_game/assets/globals.dart';
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

Future<void> decreaseBet() async {
  if (betValue.value > 100) {
    betValue.value -= 50;
  }
}

Future<void> increaseBet() async {
  int currentBalance = await getBalance();
  if (betValue.value + 50 <= currentBalance) {
    betValue.value += 50;
  }
}

Future<void> decBalanceTest() async {
  final prefs = await SharedPreferences.getInstance();
  int current = prefs.getInt('user_balance') ?? 1000;
  if (current > 0) {
    await prefs.setInt('user_balance', current - 1);
  }
}

Future<void> bet(int betAmount) async {
  final prefs = await SharedPreferences.getInstance();
  int currentBalance = prefs.getInt('user_balance') ?? 1000;

  if (betAmount < currentBalance) {
    await prefs.setInt('user_balance', currentBalance - betAmount);
  }
}

Future<void> addToBalance(int amount) async {
  final prefs = await SharedPreferences.getInstance();
  int currentBalance = prefs.getInt('user_balance') ?? 1000;

  await prefs.setInt('user_balance', currentBalance + amount);
}

Future<void> incBalanceTest() async {
  final prefs = await SharedPreferences.getInstance();
  int currentBalance = prefs.getInt('user_balance') ?? 1000;

  await prefs.setInt('user_balance', currentBalance + 100);
}

double factorial(int n) {
  if (n <= 1) return 1;
  double result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

double combination(int n, int k) {
  if (k > n || k < 0) return 0;
  return factorial(n) / (factorial(k) * factorial(n - k));
}

void updateBalance() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getInt('user_balance') ?? 0;
  currentBalance.value = value;
}

int calculateWinnings(int betAmount, double betMultiplier) {
  return (betAmount * betMultiplier).round();
}
