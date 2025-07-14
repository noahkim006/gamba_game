import 'package:flutter/material.dart';
import 'package:gamba_game/methods/balance_funcs.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBar();
}

class _CustomAppBar extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () async {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.grid_view_rounded),
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  color: Color.fromRGBO(255, 215, 0, 100)),
              const SizedBox(width: 4),
              FutureBuilder<int>(
                future: getBalance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 30,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else {
                    return Text(
                      '${snapshot.data}',
                      style: const TextStyle(fontSize: 20),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
