import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamba_game/assets/globals.dart';
import 'package:gamba_game/methods/balance_funcs.dart';

class DiamondGame extends StatefulWidget {
  const DiamondGame({super.key});

  @override
  State<DiamondGame> createState() => _DiamondGameState();
}

class _DiamondGameState extends State<DiamondGame> {
  // Game State
  bool _gameEnabled = false;
  bool _gameLost = false;
  int _turnNumber = 0;
  int _balance = 1000;

  // Slider & Tile State
  double _sliderValue = 1.00;
  Set<int> _diamondTiles = {};
  final Set<int> _flippedTiles = {};

  // Multiplier Animation
  double _displayedMultiplier = 1.00;

  // Theme
  static const _bgColor = Color(0xFF121212);
  static const _tileColor = Color(0xFF1E1E1E);
  static const _greenAccent = Colors.greenAccent;
  static const _redAccent = Colors.redAccent;
  static const _blueAccent = Colors.lightBlueAccent;
  static const _buttonBlue = Color(0xFF2C3E50);
  static const _tileDiamondColor = Colors.green;
  static const _tileBombColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt('user_balance') ?? 1000;
    await prefs.setInt('user_balance', stored);
    setState(() => _balance = stored);
  }

  void _handleTileTap(int index, bool isDiamond) {
    setState(() {
      _flippedTiles.add(index);
      if (!isDiamond) {
        _gameEnabled = false;
        _gameLost = true;
        return;
      }

      _turnNumber++;
      _calculateCashoutMultiplier();

      if (_turnNumber == (25 - _sliderValue.round())) {
        final winnings = calculateWinnings(betValue.value, betMultiplier.value);
        addToBalance(winnings);
        _loadBalance();
      }
    });
  }

  void _toggleGameState() {
    setState(() {
      if (_gameEnabled) {
        if (_flippedTiles.isNotEmpty) {
          final winnings =
              calculateWinnings(betValue.value, betMultiplier.value);
          addToBalance(winnings);
          _loadBalance();
        }
        _gameEnabled = false;
        _gameLost = true;
      } else {
        _startNewGame();
      }
    });
  }

  void _startNewGame() {
    setState(() {
      _gameEnabled = true;
      _gameLost = false;
      _turnNumber = 0;
      _flippedTiles.clear();
      _diamondTiles.clear();
      _generateDiamondTiles();
      betMultiplier.value = 1.00;
      _displayedMultiplier = 1.00;

      bet(betValue.value);
      _loadBalance();
    });
  }

  void _generateDiamondTiles() {
    final totalDiamonds = 25 - _sliderValue.round();
    final positions = List.generate(25, (i) => i)..shuffle();
    _diamondTiles = positions.take(totalDiamonds).toSet();
  }

  void _calculateCashoutMultiplier() {
    const houseEdge = 0.96;
    final b = _sliderValue.round();
    final x = _turnNumber;
    const total = 25;
    final safe = total - b;

    if (x <= 0 || b >= 25 || safe - x < 0) {
      betMultiplier.value = 1.0;
      return;
    }

    final probability = (factorial(safe) / factorial(total)) *
        (factorial(total - x) / factorial(safe - x));

    if (probability <= 0) {
      betMultiplier.value = 1000.0;
      return;
    }

    final multiplier = (1 / probability) * houseEdge;
    betMultiplier.value = double.parse(multiplier.toStringAsFixed(2));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 5),
          _MultiplierDisplay(
            valueListenable: betMultiplier,
            onAnimateComplete: (v) => _displayedMultiplier = v,
            startValue: _displayedMultiplier,
          ),
          _buildGameGrid(),
          _buildInfoRow(),
          _buildSlider(),
          _buildBetControls(),
          _buildPlaceBetButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bgColor,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  color: Color.fromRGBO(255, 215, 0, 100)),
              const SizedBox(width: 4),
              Text('$_balance',
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.ondemand_video_rounded,
                    color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
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
        itemBuilder: (context, index) {
          final flipped = _flippedTiles.contains(index) || _gameLost;
          final isDiamond = _diamondTiles.contains(index);

          return GestureDetector(
            onTap: (_gameEnabled && !flipped)
                ? () => _handleTileTap(index, isDiamond)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: flipped
                    ? (isDiamond ? _tileDiamondColor : _tileBombColor)
                    : _tileColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: flipped
                    ? Icon(
                        isDiamond ? Icons.diamond : FontAwesomeIcons.bomb,
                        color: isDiamond ? Colors.cyanAccent : Colors.black,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.bomb, color: _redAccent),
          const SizedBox(width: 4),
          Text('${_sliderValue.round()}',
              style: const TextStyle(
                  fontFamily: 'monospace', color: Colors.white)),
          const Spacer(),
          const Icon(Icons.diamond_rounded, color: Colors.cyanAccent),
          const SizedBox(width: 4),
          Text('${(25 - _sliderValue.round())}',
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
            : (value) => setState(() => _sliderValue = value),
      ),
    );
  }

  Widget _buildBetControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2.5),
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
              onPressed: _gameEnabled ? null : decreaseBet,
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
              onPressed: _gameEnabled ? null : increaseBet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceBetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gameEnabled ? _tileBombColor : _buttonBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
}

class _MultiplierDisplay extends StatelessWidget {
  final ValueListenable<double> valueListenable;
  final double startValue;
  final void Function(double) onAnimateComplete;

  const _MultiplierDisplay({
    required this.valueListenable,
    required this.startValue,
    required this.onAnimateComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: valueListenable,
      builder: (context, targetValue, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: startValue, end: targetValue),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          onEnd: () => onAnimateComplete(targetValue),
          builder: (context, animatedValue, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent, width: 1.5),
              ),
              child: Text(
                '${animatedValue.toStringAsFixed(2)}x',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  letterSpacing: 1.1,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
