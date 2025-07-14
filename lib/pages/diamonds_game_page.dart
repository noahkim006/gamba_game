import 'package:flutter/material.dart';
import 'package:gamba_game/widgets/custom_appbar.dart';
// import 'package:gamba_game/methods/balance_funcs.dart';
// import 'package:gamba_game/widgets/custom_appbar.dart';

class DiamondGame extends StatefulWidget {
  const DiamondGame({super.key});

  @override
  State<DiamondGame> createState() => _DiamondGameState();
}

class _DiamondGameState extends State<DiamondGame> {
  double _multiplier = 1.00;
  double _value = 1.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 50, // Assign a specific height for the Text widget
            child: Center(
                // child: Text(
                //   '$_multiplier',
                //   style: const TextStyle(fontSize: 24),
                // ),
                ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 25,
              itemBuilder: buildGridItems,
            ),
          ),
          Slider(
            value: _value,
            onChanged: (newValue) {
              setState(() => _value = newValue);
            },
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget buildGridItems(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        // Handle grid item tap
        print('Tapped on item $index');
      },
      child: const Icon(Icons.panorama_fish_eye_rounded),
    );
  }
}
