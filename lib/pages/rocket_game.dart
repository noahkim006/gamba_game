import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamba_game/assets/globals.dart';
import 'package:gamba_game/methods/balance_funcs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RocketGame extends StatefulWidget {
  const RocketGame({super.key});

  @override
  State<RocketGame> createState() => _RocketGameState();
}

class _RocketGameState extends State<RocketGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rocketProgress;
  int _balance = 1000;
  bool _gameRunning = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );

    _rocketProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
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

  void _toggleGame() {
    if (_gameRunning) {
      // CASH OUT
      _controller.stop();
      int winnings =
          calculateWinnings(betValue.value, _rocketProgress.value * 10);
      // print(_rocketProgress.value);
      addToBalance(winnings);
      _loadBalance();
    } else {
      // PLACE BET
      bet(betValue.value);
      _loadBalance();
      _controller.reset();
      _controller.forward();
    }

    setState(() {
      _gameRunning = !_gameRunning;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildGameCanvas(),
          _buildBetControls(),
          _buildStartButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      leading: IconButton(
        icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildGameCanvas() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomPaint(
          painter: RocketCurvePainter(progress: _rocketProgress.value),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildBetControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
              iconSize: 32,
              onPressed: _gameRunning ? null : () => decreaseBet(),
            ),
            const SizedBox(width: 16),
            ValueListenableBuilder(
              valueListenable: betValue,
              builder: (context, value, _) => Text(
                '$value',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
              iconSize: 32,
              onPressed: _gameRunning ? null : () => increaseBet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _toggleGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: _gameRunning ? Colors.red : Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _gameRunning ? 'CASH OUT' : 'LAUNCH',
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

class RocketCurvePainter extends CustomPainter {
  final double progress;

  RocketCurvePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pathPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Paint rocketPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, size.height);

    const double a = 1;
    const double b = 0.03;

    List<Offset> points = [];

    for (double x = 0; x <= size.width; x += 1) {
      double y = size.height - ((a / 9) * exp(b * x));
      y = y.clamp(0, size.height);
      points.add(Offset(x, y));
    }

    // Draw curve path
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, pathPaint);

    // Draw rocket
    if (progress > 0 && progress <= 1) {
      int rocketIndex =
          (points.length * progress).clamp(0, points.length - 1).toInt();
      Offset rocketPosition = points[rocketIndex];

      canvas.drawCircle(rocketPosition, 8, rocketPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RocketCurvePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
