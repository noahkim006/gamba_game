import 'package:flutter/material.dart';
import 'package:gamba_game/assets/globals.dart';
import 'package:gamba_game/methods/balance_funcs.dart';
// import 'package:gamba_game/widgets/custom_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiamondGame extends StatefulWidget {
  const DiamondGame({super.key});

  @override
  State<DiamondGame> createState() => _DiamondGameState();
}

class _DiamondGameState extends State<DiamondGame> {
  bool _gameEnabled = false;
  bool _gameLost = false;

  int _turnNumber = 0;
  double _sliderValue = 1.00;
  Set<int> _diamondTiles = {};
  final Set<int> _flippedTiles = {};

  // Theme Colors
  static const Color _bgColor = Color(0xFF121212);
  static const Color _tileColor = Color(0xFF1E1E1E);
  static const Color _greenAccent = Colors.greenAccent;
  static const Color _redAccent = Colors.redAccent;
  static const Color _blueAccent = Colors.lightBlueAccent;
  static const Color _buttonBlue = Color(0xFF2C3E50);
  static const Color _tileDiamondColor = Colors.green;
  static const Color _tileBombColor = Colors.red;

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
          const SizedBox(height: 5),
          _buildMultiplierText(),
          _buildGameGrid(),
          _buildMinesAndDiamondsRow(),
          _buildSlider(),
          _buildBetControls(),
          _buildPlaceBetButton(),
        ],
      ),
    );
  }

  // ----- UI Builders -----

  Widget _buildMultiplierText() {
    return ValueListenableBuilder<double>(
      valueListenable: betMultiplier,
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _greenAccent, width: 1.5),
          ),
          child: Text(
            '${value.toStringAsFixed(2)}x',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _greenAccent,
              fontFamily: 'monospace',
              letterSpacing: 1.1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameGrid() {
    return SizedBox(
      height: 290,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          mainAxisExtent: 55,
        ),
        itemCount: 25,
        itemBuilder: _buildGameTile,
      ),
    );
  }

  Widget _buildGameTile(BuildContext context, int index) {
    final flipped = _flippedTiles.contains(index) || _gameLost;
    final isDiamond = _diamondTiles.contains(index);

    return GestureDetector(
      onTap: (_gameEnabled && !flipped)
          ? () => _handleTileTap(index, isDiamond)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: flipped
              ? (isDiamond ? _tileDiamondColor : _tileBombColor)
              : _tileColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: flipped
              ? Icon(
                  isDiamond ? Icons.diamond : Icons.close,
                  color: isDiamond ? Colors.cyanAccent : Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMinesAndDiamondsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.not_interested_rounded, color: _redAccent),
          const SizedBox(width: 4),
          Text('${_sliderValue.round()}',
              style: const TextStyle(
                  fontFamily: 'monospace', color: Colors.white)),
          const Spacer(),
          const Icon(Icons.diamond_rounded, color: Colors.cyanAccent),
          const SizedBox(width: 4),
          Text('${(25 - _sliderValue).round()}',
              style: const TextStyle(
                  fontFamily: 'monospace', color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: _sliderValue,
        min: 1.0,
        max: 20.0,
        activeColor: _redAccent,
        inactiveColor: _blueAccent,
        onChanged: _gameEnabled
            ? null
            : (double value) => setState(() => _sliderValue = value),
      ),
    );
  }

  Widget _buildBetControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: _redAccent),
              iconSize: 32,
              onPressed: _gameEnabled ? null : () => decreaseBet(),
            ),
            const SizedBox(width: 16),
            ValueListenableBuilder(
              valueListenable: betValue,
              builder: (context, value, _) {
                return Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.add_circle, color: _greenAccent),
              iconSize: 32,
              onPressed: _gameEnabled ? null : () => increaseBet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceBetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gameEnabled ? _tileBombColor : _buttonBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.transparent,
          ),
          onPressed: _toggleGameState,
          child: Text(
            _gameEnabled ? 'CASH OUT' : 'PLACE BET',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ----- Game Logic -----

  void _handleTileTap(int index, bool isDiamond) {
    setState(() {
      _flippedTiles.add(index);
      if (!isDiamond) {
        _gameEnabled = false;
        _gameLost = true;
        return;
      }
      _turnNumber++;
      // print(_turnNumber);
      _calculateCashoutMultiplier();
      // print("turnNumber: " + _turnNumber.toString());
      // print("num of diamonds: " + (25 - _sliderValue).toString());
      if (_turnNumber == (25 - _sliderValue)) {
        // print("winwinwinwinwiwnwinwinwiwniwn");
        setState(() {
          int winnings = calculateWinnings(betValue.value, betMultiplier.value);
          addToBalance(winnings);
          _loadBalance();
        });
      }
    });
  }

  void _toggleGameState() {
    setState(() {
      if (_gameEnabled) {
        // print(betMultiplier.value);
        int winnings = calculateWinnings(betValue.value, betMultiplier.value);
        addToBalance(winnings);
        _loadBalance();
        _gameEnabled = false;
        _gameLost = true;
      } else {
        _startNewGame();
      }
    });
  }

  void _startNewGame() {
    //============CLEAN UP=========================
    _gameEnabled = true;
    _gameLost = false;
    _turnNumber = 0;
    _flippedTiles.clear();
    _diamondTiles.clear();
    _generateDiamondTiles();
    betMultiplier.value = 1.00;
    //============================================

    // bet(betValue.value);
    setState(() {
      bet(betValue.value);
      _loadBalance();
    });
  }

  void _generateDiamondTiles() {
    final total = 25 - _sliderValue.round();
    final positions = List.generate(25, (i) => i)..shuffle();
    _diamondTiles = positions.take(total).toSet();
  }

  void _calculateCashoutMultiplier() {
    const double houseEdge = 0.96;

    int b = _sliderValue.round(); // number of mines
    int x = _turnNumber; // number of successful turns
    int total = 25;
    int safe = total - b;

    // edge cases to avoid invalid math
    if (x <= 0 || b >= 25 || safe - x < 0) {
      betMultiplier.value = 1.0;
      return;
    }

    double numeratorLeft = factorial(safe);
    double denominatorLeft = factorial(total);

    double numeratorRight = factorial(total - x);
    double denominatorRight = factorial(safe - x);

    double probability =
        (numeratorLeft / denominatorLeft) * (numeratorRight / denominatorRight);

    // Defensive check for division by zero or extremely small probability
    if (probability <= 0) {
      betMultiplier.value = 1000.0; // or some max cap
      return;
    }

    double multiplier = (1 / probability) * houseEdge;

    // Optional: Round for cleaner UI
    betMultiplier.value = double.parse(multiplier.toStringAsFixed(2));

    print("Calculated cashout multiplier: ${betMultiplier.value}");
  }
}
