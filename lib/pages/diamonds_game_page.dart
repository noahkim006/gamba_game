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
          //Row holding the text above the slider
          Row(children: [
            const SizedBox(width: 20),
            const Icon(
              Icons.not_interested_rounded,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              '${_value.round()}',
              // Use a monospaced font to prevent layout shifts
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const Spacer(), // Pushes the two groups apart
            const Icon(Icons.diamond_rounded, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              '${(25 - _value).round()}',
              // Use a monospaced font here too for consistency
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(width: 20),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: _value,
              onChanged: (newValue) {
                setState(() => _value = newValue);
              },
              min: 1.0,
              max: 24.0,
              divisions: 23,
              label: '', // Still required, but will be hidden by the theme.
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

//TODO: IMPLEMENT LATE
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
