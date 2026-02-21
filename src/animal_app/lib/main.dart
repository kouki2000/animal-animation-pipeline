import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Animal Animation', home: DogScreen());
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  static const int totalFrames = 5;

  // 各フレームの実測Y座標（分析結果より）
  static const List<double> frameStartY = [0, 44, 88, 134, 179];
  static const double frameWidth = 83;
  static const double frameHeight = 40; // 最小フレームに統一

  int _currentFrame = 0;
  Timer? _timer;
  ui.Image? _spriteSheet;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('images/Dogs.png');
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _spriteSheet = frame.image;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentFrame = (_currentFrame + 1) % totalFrames;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _spriteSheet == null
            ? const CircularProgressIndicator()
            : CustomPaint(
                size: const Size(frameWidth * 3, frameHeight * 3),
                painter: DogPainter(
                  spriteSheet: _spriteSheet!,
                  currentFrame: _currentFrame,
                  frameStartY: frameStartY,
                ),
              ),
      ),
    );
  }
}

class DogPainter extends CustomPainter {
  final ui.Image spriteSheet;
  final int currentFrame;
  final List<double> frameStartY;

  static const double frameWidth = 83;
  static const double frameHeight = 40;

  const DogPainter({
    required this.spriteSheet,
    required this.currentFrame,
    required this.frameStartY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect srcRect = Rect.fromLTWH(
      0,
      frameStartY[currentFrame],
      frameWidth,
      frameHeight,
    );

    final Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(spriteSheet, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(DogPainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame;
  }
}
