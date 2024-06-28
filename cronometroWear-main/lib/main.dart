import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen(this.mode, {super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late int _count;
  late String _strCount;
  late String _status;

  @override
  void initState() {
    _count = 0;
    _strCount = "00:00:00";
    _status = "Start";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.mode == WearMode.active ? Colors.white : Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.mode == WearMode.active)
              const Text(
                'Cronómetro',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 1.0),
            Center(
              child: Image.asset(
                widget.mode == WearMode.active
                    ? 'assets/img/normal_mode_image.png'
                    : 'assets/img/ambient_mode_image.png',
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: Text(
                _strCount,
                style: TextStyle(
                  color: widget.mode == WearMode.active
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 1.0), // Espacio para la barra inferior
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    if (widget.mode == WearMode.active) {
      return BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (_status == "Start")
              _buildIconButton(Icons.play_arrow, Colors.green, _startTimer),
            if (_status != "Start")
              _buildIconButton(
                _status == "Stop" ? Icons.pause : Icons.play_arrow,
                Colors.orange,
                () {
                  if (_status == "Stop") {
                    _timer.cancel();
                    setState(() {
                      _status = "Continue";
                    });
                  } else if (_status == "Continue") {
                    _startTimer();
                  }
                },
              ),
            if (_status != "Start")
              _buildIconButton(Icons.refresh, Colors.red, () {
                if (_timer != null) {
                  _timer.cancel();
                  setState(() {
                    _count = 0;
                    _strCount = "00:00:00";
                    _status = "Start";
                  });
                }
              }),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _status = "Stop";
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count += 1;
        int hour = _count ~/ 3600;
        int minute = (_count % 3600) ~/ 60;
        int second = (_count % 3600) % 60;
        _strCount = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
      });
    });
  }
}
