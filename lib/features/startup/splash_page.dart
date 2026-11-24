import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/food_plate.dart';
import '../../core/widgets/premium_motion.dart';

/// Splash sinematik Kedai Ummi.
///
/// Urutan: latar hangat → logo (scale + fade) → tagline → foto makanan
/// (slide-up + fade) → indikator loading. Navigasi menunggu inisialisasi
/// [SharedPreferences] yang sebenarnya, bukan progress palsu.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2350);

  late final AnimationController _controller;
  late final Future<SharedPreferences> _prefsFuture;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _foodFade;
  late final Animation<Offset> _foodSlide;
  late final Animation<double> _foodScale;
  late final Animation<double> _loaderFade;

  bool _started = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onStatus);

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.04, 0.38, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.58, curve: Curves.easeOutBack),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.58, curve: Curves.easeOut),
    );
    _foodFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.68, curve: Curves.easeOut),
    );
    _foodSlide = Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.30, 0.78, curve: AppMotion.emphasized),
          ),
        );
    _foodScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.78, curve: AppMotion.standard),
      ),
    );
    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.86, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.duration = const Duration(milliseconds: 650);
    }
    _controller.forward();
  }

  Future<void> _onStatus(AnimationStatus status) async {
    if (status != AnimationStatus.completed || _navigated) return;
    _navigated = true;
    final prefs = await _prefsFuture;
    if (!mounted) return;
    final seen = prefs.getBool('onboarding_seen') ?? false;
    context.go(seen ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  String get _status {
    final value = _controller.value;
    if (value < 0.5) return 'Menyiapkan kelezatan...';
    if (value < 0.74) return 'Memuat menu favorit...';
    if (value < 0.9) return 'Menyiapkan pengalaman terbaik...';
    return 'Hampir selesai...';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;
    final logoWidth = (size.width * 0.58).clamp(176.0, 264.0);
    final foodWidth = (size.width * 0.6).clamp(176.0, 276.0);

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SplashBackdrop(),
          SafeArea(
            child: Column(
              children: <Widget>[
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = Curves.easeOutCubic.transform(
                      _controller.value.clamp(0.0, 1.0),
                    );
                    final tilt = (1 - t) * 0.2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateX(tilt * 0.55)
                        ..rotateY(-tilt),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: BrandMark(
                        width: logoWidth,
                        showTagline: false,
                        onDark: true,
                        showGlow: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 4 : 8),
                FadeTransition(
                  opacity: _taglineFade,
                  child: const _SplashTagline(),
                ),
                SizedBox(height: compact ? 6 : 14),
                FadeTransition(
                  opacity: _foodFade,
                  child: SlideTransition(
                    position: _foodSlide,
                    child: ScaleTransition(
                      scale: _foodScale,
                      child: FloatOn(
                        amplitude: 4,
                        duration: const Duration(milliseconds: 4200),
                        child: FoodPlate(
                          image: 'assets/images/products/burger.jpg',
                          width: foodWidth,
                          heightFactor: compact ? 0.56 : 0.62,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _loaderFade,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => _SplashLoader(
                      progress: _controller.value,
                      status: _status,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 26),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    'KEDAI UMMI · LEZAT SETIAP GIGITAN',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashTagline extends StatelessWidget {
  const _SplashTagline();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 18,
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 8),
        const Flexible(
          child: Text(
            '"Lezat Setiap Gigitan"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: Color(0xFFF1DEC7),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader({required this.progress, required this.status});

  final double progress;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: const Size.square(58),
                painter: _OrbitPainter(progress: progress),
              ),
              Transform.rotate(
                angle: progress * math.pi * 4,
                child: CustomPaint(
                  size: const Size.square(58),
                  painter: const _ArcPainter(),
                ),
              ),
              ChefHatMark(size: 18),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 20,
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              status,
              key: ValueKey<String>(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.16),
    );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gold.withValues(alpha: 0.12 + progress * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius, glow);

    final sparkCount = 3;
    for (var i = 0; i < sparkCount; i++) {
      final angle = progress * math.pi * 2 + i * 2.1;
      final dot = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(
        dot,
        1.6,
        Paint()..color = AppColors.gold.withValues(alpha: 0.7 - i * 0.18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: <Color>[
          Color(0x00F3D89B),
          Color(0xFFF3D89B),
          Color(0xFFFFF3DE),
          Color(0x00F3D89B),
        ],
        stops: <double>[0, 0.55, 0.78, 1],
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 1.15, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) => false;
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF4A2112),
                  Color(0xFF321409),
                  Color(0xFF1C120E),
                ],
                stops: <double>[0, 0.42, 1],
              ),
            ),
          ),
          Transform.scale(
            scale: 1.16,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Image.asset(
                'assets/images/products/burger.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 900,
                color: const Color(0xB32A1B13),
                colorBlendMode: BlendMode.multiply,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x33241410),
                  Color(0xB32A1B13),
                  Color(0xF21C120E),
                ],
                stops: <double>[0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.26),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.terracotta.withValues(alpha: 0.24),
                    AppColors.terracotta.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: StarDust(
              count: 18,
              opacity: 0.3,
              duration: Duration(seconds: 14),
            ),
          ),
          Positioned(
            right: size.width * 0.08,
            top: size.height * 0.2,
            child: const FloatOn(
              amplitude: 6,
              duration: Duration(milliseconds: 4200),
              child: Opacity(
                opacity: 0.55,
                child: FoodPlate(
                  image: 'assets/images/products/es-jeruk.jpg',
                  width: 74,
                  heightFactor: 1,
                  rim: false,
                  glow: false,
                  cacheWidth: 220,
                ),
              ),
            ),
          ),
          Positioned(
            left: -24,
            top: size.height * 0.13,
            child: const FloatOn(
              amplitude: 5,
              phase: 0.6,
              duration: Duration(milliseconds: 4600),
              child: _SplashLeaf(size: 44, angle: 0.6, opacity: 0.22),
            ),
          ),
          Positioned(
            right: -18,
            bottom: size.height * 0.18,
            child: const FloatOn(
              amplitude: 4,
              phase: 2.1,
              duration: Duration(milliseconds: 5200),
              child: _SplashLeaf(size: 34, angle: -0.9, opacity: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLeaf extends StatelessWidget {
  const _SplashLeaf({
    required this.size,
    required this.angle,
    this.opacity = 0.3,
  });

  final double size;
  final double angle;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size * 0.6,
            height: size,
            child: CustomPaint(painter: const _SplashLeafPainter()),
          ),
        ),
      ),
    );
  }
}

class _SplashLeafPainter extends CustomPainter {
  const _SplashLeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 1.08, h * 0.28, w * 0.88, h * 0.74, w * 0.5, h)
      ..cubicTo(w * 0.12, h * 0.74, w * -0.08, h * 0.28, w * 0.5, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF8FA766), Color(0xFF4C6436)],
        ).createShader(Offset.zero & size),
    );
    final vein = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..quadraticBezierTo(w * 0.58, h * 0.5, w * 0.5, h * 0.92);
    canvas.drawPath(
      vein,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x88476530),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashLeafPainter oldDelegate) => false;
}
