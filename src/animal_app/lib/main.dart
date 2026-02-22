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

class _DogScreenState extends State<DogScreen>
    with SingleTickerProviderStateMixin {
  static const int totalFrames = 5;
  static const List<double> frameStartY = [0, 44, 88, 134, 179];
  static const double frameWidth = 83;
  static const double frameHeight = 40;

  // ===== レスポンシブ基準（画面サイズに対する割合）=====
  static const double dogWidthRatio = 0.4; // 犬の幅 = 画面幅の40%
  static const double groundRatio = 0.65; // 地面の上端 = 画面高さの65%
  // =====================================================

  late AnimationController _controller;
  late Animation<double> _curvedAnimation;

  ui.Image? _spriteSheet;
  ui.Image? _background;

  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 208),
    )..repeat();

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _loadImages();
  }

  Future<void> _loadImages() async {
    final dogData = await rootBundle.load('images/Dogs.png');
    final dogBytes = dogData.buffer.asUint8List();
    final dogCodec = await ui.instantiateImageCodec(dogBytes);
    final dogFrame = await dogCodec.getNextFrame();

    final bgData = await rootBundle.load('images/background.png');
    final bgBytes = bgData.buffer.asUint8List();
    final bgCodec = await ui.instantiateImageCodec(bgBytes);
    final bgFrame = await bgCodec.getNextFrame();

    setState(() {
      _spriteSheet = dogFrame.image;
      _background = bgFrame.image;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _currentFrame =>
      (_curvedAnimation.value * totalFrames).floor() % totalFrames;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 犬のサイズを画面幅の割合で計算
    final dogDisplayWidth = screenWidth * dogWidthRatio;
    final dogDisplayHeight =
        dogDisplayWidth * (frameHeight / frameWidth); // アスペクト比を保つ

    // 犬のY位置 = 地面の上端 - 犬の高さ（地面の上に立つ）
    final dogTop = screenHeight * groundRatio - dogDisplayHeight;

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: _spriteSheet == null || _background == null
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    // 背景スクロール
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: BackgroundPainter(
                        background: _background!,
                        scrollOffset: _controller.value * screenWidth * _speed,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                    ),
                    // 犬アニメーション（地面の上に配置）
                    Positioned(
                      top: dogTop,
                      left: screenWidth / 2 - dogDisplayWidth / 2,
                      child: CustomPaint(
                        size: Size(dogDisplayWidth, dogDisplayHeight),
                        painter: DogPainter(
                          spriteSheet: _spriteSheet!,
                          currentFrame: _currentFrame,
                          frameStartY: frameStartY,
                        ),
                      ),
                    ),
                    // 速度スライダー
                    Positioned(
                      bottom: screenHeight * 0.05,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            '速度: ${_speed.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Slider(
                            value: _speed,
                            min: 0.5,
                            max: 3.0,
                            divisions: 5,
                            onChanged: (value) {
                              setState(() => _speed = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.isAnimating) {
              _controller.stop();
            } else {
              _controller.repeat();
            }
          });
        },
        child: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final ui.Image background;
  final double scrollOffset;
  final double screenWidth;
  final double screenHeight;

  const BackgroundPainter({
    required this.background,
    required this.scrollOffset,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.high;

    // 背景は画面幅に合わせて表示（高さはアスペクト比を保つ）
    // 画面幅に合わせると高さが足りない場合は高さ基準に切り替え
    final double imgAspect = background.width / background.height;
    double bgWidth = screenWidth;
    double bgHeight = screenWidth / imgAspect;

    // 背景の高さが画面より小さい場合は高さ基準にする
    if (bgHeight < screenHeight) {
      bgHeight = screenHeight;
      bgWidth = screenHeight * imgAspect;
    }

    final double offset = scrollOffset % bgWidth;

    // 2枚並べてループスクロール
    canvas.drawImageRect(
      background,
      Rect.fromLTWH(
        0,
        0,
        background.width.toDouble(),
        background.height.toDouble(),
      ),
      Rect.fromLTWH(-offset, 0, bgWidth, bgHeight),
      paint,
    );
    canvas.drawImageRect(
      background,
      Rect.fromLTWH(
        0,
        0,
        background.width.toDouble(),
        background.height.toDouble(),
      ),
      Rect.fromLTWH(bgWidth - offset, 0, bgWidth, bgHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset;
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
