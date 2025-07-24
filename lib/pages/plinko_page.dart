import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlinkoGame extends StatefulWidget {
  const PlinkoGame({super.key});

  @override
  State<PlinkoGame> createState() => _PlinkoGame();
}

class _PlinkoGame extends State<PlinkoGame> {
  static const Color _bgColor = Color(0xFF121212);
  int _balance = 1000;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    int? stored = prefs.getInt('user_balance');
    if (stored == null) {
      await prefs.setInt('user_balance', 1000);
      stored = 1000;
    }
    setState(() {
      _balance = stored!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.grid_view_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card_rounded,
                    color: Color.fromRGBO(255, 215, 0, 100)),
                const SizedBox(width: 4),
                Text(
                  '$_balance',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.ondemand_video_rounded,
                      color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPlinkoBoard(),
        ],
      ),
    );
  }

  Widget _buildPlinkoBoard() {
    return Container();
  }
}
