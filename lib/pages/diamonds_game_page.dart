import 'package:flutter/material.dart';
import 'package:gamba_game/assets/globals.dart';
import 'package:gamba_game/methods/balance_funcs.dart';
import 'package:gamba_game/widgets/custom_appbar.dart';

class DiamondGame extends StatefulWidget {
  const DiamondGame({super.key});

  @override
  State<DiamondGame> createState() => _DiamondGameState();
}

class _DiamondGameState extends State<DiamondGame> {
  bool _gameEnabled = false;
  bool _gameOver = false;

  double _sliderValue = 1.00;
  Set<int> _diamondTiles = {};
  final Set<int> _flippedTiles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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

  Widget _buildMultiplierText() {
    return ValueListenableBuilder<double>(
      valueListenable: betMultiplier,
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade400, width: 1.5),
          ),
          child: Text(
            '${value.toStringAsFixed(2)}x',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green,
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
    final flipped = _flippedTiles.contains(index) || _gameOver;
    final isDiamond = _diamondTiles.contains(index);

    return GestureDetector(
      onTap: (_gameEnabled && !flipped)
          ? () {
              setState(() => _flippedTiles.add(index));
              if (!isDiamond) {
                _gameEnabled = false;
                _gameOver = true;
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color:
              flipped ? (isDiamond ? Colors.green : Colors.red) : Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: flipped
              ? Icon(
                  isDiamond ? Icons.diamond : Icons.close,
                  color: isDiamond ? Colors.blueAccent : Colors.white,
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
          const Icon(Icons.not_interested_rounded, color: Colors.red),
          const SizedBox(width: 4),
          Text('${_sliderValue.round()}',
              style: const TextStyle(fontFamily: 'monospace')),
          const Spacer(),
          const Icon(Icons.diamond_rounded, color: Colors.blue),
          const SizedBox(width: 4),
          Text('${(25 - _sliderValue).round()}',
              style: const TextStyle(fontFamily: 'monospace')),
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
        max: 24.0,
        divisions: 23,
        activeColor: Colors.red,
        onChanged: _gameEnabled
            ? null
            : (double value) {
                setState(() {
                  _sliderValue = value;
                });
              },
      ),
    );
  }

  Widget _buildBetControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
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
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
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
            backgroundColor: _gameEnabled ? Colors.red : Colors.blue.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.transparent,
          ),
          onPressed: () {
            setState(() {
              if (_gameEnabled) {
                // End game early (manual cash out)
                _gameEnabled = false;
                _gameOver = true;
              } else {
                // Start new game
                _gameEnabled = true;
                _gameOver = false;
                _flippedTiles.clear();
                _diamondTiles.clear();
                _generateDiamondTiles();
              }
            });
          },
          child: Text(
            _gameEnabled ? 'End Game' : 'PLACE BET',
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

  void _generateDiamondTiles() {
    final total = 25 - _sliderValue.round(); //find number of bombs
    final positions = List.generate(25, (i) => i)..shuffle();
    _diamondTiles = positions.take(total).toSet();
  }
}
