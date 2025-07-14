import 'package:flutter/material.dart';
import 'package:gamba_game/pages/diamonds_game_page.dart';
import 'package:gamba_game/pages/rocket_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FOR TESTING BUTTON
// ignore: unused_import
import 'package:gamba_game/methods/balance_funcs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamba Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gamba Game Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.ondemand_video_rounded),
                  onPressed: () {},
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: _createGameGrid(),
    );
  }

  Widget _createGameGrid() {
    return Center(
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: [
          SizedBox(
            child: IconButton(
              icon: const Icon(Icons.rocket_launch_rounded),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RocketGame(),
                    ));
                await _loadBalance();
              },
              hoverColor: Colors.transparent,
            ),
          ),
          SizedBox(
            child: IconButton(
              icon: const ImageIcon(AssetImage('lib/assets/plinko.jpg')),
              onPressed: () {},
              hoverColor: Colors.transparent,
            ),
          ),
          SizedBox(
            child: IconButton(
              icon: const Icon(Icons.grid_on_rounded),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiamondGame(),
                    ));
                await _loadBalance();
              },
              hoverColor: Colors.transparent,
            ),
          ),
          //------------------------------------------------------------------------------------------------------------------------------------
          // SizedBox(
          //   child: IconButton(
          //     icon: const Icon(Icons.grid_on_rounded),
          //     onPressed: () async {
          //       await decBalanceTest();
          //       await _loadBalance();
          //     },
          //   ),
          // ),
          //------------------------------------------------------------------------------------------------------------------------------------
        ],
      ),
    );
  }
}
