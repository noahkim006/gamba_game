import 'package:flutter/material.dart';
import 'package:gamba_game/methods/balance_funcs.dart';
import 'package:gamba_game/widgets/custom_appbar.dart';

class RocketGame extends StatefulWidget {
  const RocketGame({super.key});

  @override
  State<RocketGame> createState() => _RocketGame();
}

class _RocketGame extends State<RocketGame> {
  double multiplier = 1.00;
  Future<int> balance = getBalance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
    );
  }
}
