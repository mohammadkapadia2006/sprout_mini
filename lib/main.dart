import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before any setup

  await AudioPlayer.global.setAudioContext(
    AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ),
  );
  runApp(const SproutApp());
}

class SproutApp extends StatelessWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprout – Pop the Bubbles!',
      debugShowCheckedModeBanner: false,
      home: const BubbleScreen(),
    );
  }
}

class Bubble {
  final String id;
  final Color color;
  double x;
  double y;
  final double size;
  bool popped;
  double scale;
  double opacity;

  Bubble({
    required this.id,
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    this.popped = false,
    this.scale = 1.0,
    this.opacity = 1.0,
  });
}

class BubbleScreen extends StatefulWidget {
  const BubbleScreen({super.key});

  @override
  State<BubbleScreen> createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final Random _rng = Random();
  late ConfettiController _confettiController;

  AudioPlayer? _cheerPlayer;
  final List<AudioPlayer> _popPlayers = [];

  List<Bubble> _bubbles = [];
  bool _allPopped = false;
  bool _miloVisible = false;

  static const List<Color> _palette = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF6BCB77),
    Color(0xFFA855F7),
    Color(0xFFFF9F43),
    Color(0xFF48CAE4),
    Color(0xFFFF6EB4),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _spawnBubbles();

    _cheerPlayer = AudioPlayer();
    _cheerPlayer!.setVolume(0.15);
    _cheerPlayer!.setReleaseMode(ReleaseMode.loop);
    _cheerPlayer!.play(AssetSource('sounds/cheer.mp3'));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    _cheerPlayer?.dispose();
    for (final p in _popPlayers) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cheerPlayer?.pause();
      for (final p in List.of(_popPlayers)) {
        p.stop();
      }
    } else if (state == AppLifecycleState.resumed) {

        _cheerPlayer?.resume();

    }
  }

  void _spawnBubbles() {
    _bubbles = List.generate(10, (i) {
      return Bubble(
        id: 'bubble_$i',
        color: _palette[_rng.nextInt(_palette.length)],
        x: 0.05 + _rng.nextDouble() * 0.85,
        y: 0.10 + _rng.nextDouble() * 0.75,
        size: 55 + _rng.nextDouble() * 35,
      );
    });
    _allPopped = false;
    _miloVisible = false;
  }

  Future<void> _playPopSound() async {
    final player = AudioPlayer();
    _popPlayers.add(player);
    await player.play(AssetSource('sounds/pop.mp3'));
    player.onPlayerComplete.listen((_) {
      player.dispose();
      _popPlayers.remove(player);
    });
  }

  Future<void> _playCheerSound() async {
    await _cheerPlayer?.setVolume(1.0);
  }

  Future<void> _popBubble(Bubble bubble) async {
    if (bubble.popped) return;

    _playPopSound();

    setState(() => bubble.popped = true);

    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      setState(() => bubble.scale = 1.35);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        bubble.scale = 0.0;
        bubble.opacity = 0.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final allDone = _bubbles.every((b) => b.popped);
      if (allDone && !_allPopped) {
        setState(() {
          _allPopped = true;
          _miloVisible = true;
        });
        _confettiController.play();
        await _playCheerSound();
      }
    });
  }

  void _restart() {
    _confettiController.stop();
    _cheerPlayer?.setVolume(0.15);
    setState(() => _spawnBubbles());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F4FF), Color(0xFFB8E8FF)],
          ),
        ),
        child: Stack(
          children: [
            _buildCloud(left: -20, top: 60, scale: 1.0),
            _buildCloud(left: size.width - 120, top: 30, scale: 0.75),
            _buildCloud(left: size.width * 0.3, top: 90, scale: 0.6),

            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    '🫧 Pop the Bubbles!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A6B9E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_bubbles.where((b) => b.popped).length} / ${_bubbles.length} popped',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A9BC2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            ..._bubbles.map((bubble) => _buildBubble(bubble, size)),

            if (_miloVisible) _buildMiloCelebration(),

            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                colors: _palette,
                shouldLoop: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(Bubble bubble, Size size) {
    return Positioned(
      left: bubble.x * size.width - bubble.size / 2,
      top: bubble.y * size.height - bubble.size / 2,
      child: GestureDetector(
        onTap: () => _popBubble(bubble),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: bubble.opacity,
          child: AnimatedScale(
            scale: bubble.scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              width: bubble.size,
              height: bubble.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bubble.color.withOpacity(0.82),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bubble.color.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: bubble.size * 0.22,
                  height: bubble.size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiloCelebration() {
    return AnimatedOpacity(
      opacity: _miloVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                const Text(
                  'Amazing!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A6B9E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You popped all the bubbles!\nMilo is so happy! 🌟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _restart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Play Again! 🫧',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloud({
    required double left,
    required double top,
    required double scale,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: 0.55,
          child: Row(
            children: [
              _circle(50, Colors.white),
              Transform.translate(
                offset: const Offset(-18, 10),
                child: _circle(35, Colors.white),
              ),
              Transform.translate(
                offset: const Offset(-30, 5),
                child: _circle(45, Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
