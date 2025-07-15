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
  final double _multiplier = 1.00;
  double _value = 1.00;
  bool _isSliderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 5),
          _buildMultiplierText(),
          _buildGameGrid(),
          // const SizedBox(height: 200),
          _buildMinesAndDiamondsRow(),
          _buildSlider(),
          _buildBetControls(),
          _buildPlaceBetButton(),
          // const SizedBox(height: 50),
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

  // Grid of game tiles
  Widget _buildGameGrid() {
    return SizedBox(
      height: 290, // Limit grid height to make tiles smaller
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // prevent scrolling inside grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          mainAxisExtent: 55,
          childAspectRatio: 1,
        ),
        itemCount: 25,
        itemBuilder: _buildGridItems,
      ),
    );
  }

  // Mines and Diamonds counter
  Widget _buildMinesAndDiamondsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.not_interested_rounded, color: Colors.red),
          const SizedBox(width: 4),
          Text('${_value.round()}',
              style: const TextStyle(fontFamily: 'monospace')),
          const Spacer(),
          const Icon(Icons.diamond_rounded, color: Colors.blue),
          const SizedBox(width: 4),
          Text('${(25 - _value).round()}',
              style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  // Mines selection slider
  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: _value,
        onChanged:
            _isSliderEnabled //if _isSliderEnabled true then work, else dont do anytbing
                ? (double value) {
                    setState(() {
                      _value = value;
                    });
                  }
                : null,
        min: 1.0,
        max: 24.0,
        divisions: 23,
        activeColor: Colors.red,
      ),
    );
  }

  // Bet increment/decrement and display
  Widget _buildBetControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
              iconSize: 32,
              onPressed: () async => {
                await decreaseBet(),
              },
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
              onPressed: () async => await increaseBet(),
            ),
          ],
        ),
      ),
    );
  }

  // Place Bet button
  Widget _buildPlaceBetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          onPressed: () {
            // TODO: Implement bet submission logic
            print("Bet submitted!");
            setState(() {
              //implement calculating the multiplier formula when submitted, dont reenable the slider until the game is finsihed OR gmae is cancelled early
              _isSliderEnabled = !_isSliderEnabled;
            });
          },
          child: const Text(
            'PLACE BET',
            style: TextStyle(
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

  // Grid tile builder
  Widget _buildGridItems(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => print('Tapped on item $index'),
      child: Container(
        margin:
            const EdgeInsets.all(4.0), // Add margin for spacing between tiles
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
      ),
    );
  }
}
