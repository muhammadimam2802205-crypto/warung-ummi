import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/brand_mark.dart';
import 'onboarding_visuals.dart';

class _SlideData {
  const _SlideData({
    required this.kind,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final OnboardingVisualKind kind;
  final String eyebrow;
  final String title;
  final String description;
}

const List<_SlideData> _slides = <_SlideData>[
  _SlideData(
    kind: OnboardingVisualKind.welcome,
    eyebrow: 'SELAMAT DATANG',
    title: 'Selamat Datang\ndi Kedai Ummi',
    description: 'Nikmati berbagai hidangan lezat dengan kualitas terbaik.',
  ),
  _SlideData(
    kind: OnboardingVisualKind.menu,
    eyebrow: 'TEMUKAN FAVORITMU',
    title: 'Temukan Menu\nFavoritmu',
    description:
        'Beragam pilihan makanan dan minuman lezat tersedia untuk menemani harimu.',
  ),
  _SlideData(
    kind: OnboardingVisualKind.order,
    eyebrow: 'PESAN LEBIH MUDAH',
    title: 'Pesan Lebih Mudah',
    description: 'Pesan makanan favoritmu dengan cepat dan praktis.',
  ),
];

/// Pengenalan aplikasi: hanya tampil pada peluncuran pertama.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialPage.clamp(0, _slides.length - 1),
  );
  late int _index = widget.initialPage.clamp(0, _slides.length - 1);
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppMotion.smooth,
      curve: AppMotion.emphasized,
    );
  }

  void _goTo(int index) {
    if (index == _index) return;
    _controller.animateToPage(
      index,
      duration: AppMotion.smooth,
      curve: AppMotion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _OnboardingBackdrop()),
          Positioned(
            left: -16,
            bottom: 120,
            child: const _Leaf(size: 46, angle: 0.5, opacity: 0.34),
          ),
          Positioned(
            right: -10,
            top: 120,
            child: const _Leaf(size: 34, angle: -0.9, opacity: 0.28),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 12, 0),
                  child: Row(
                    children: <Widget>[
                      const BrandMark(
                        width: 106,
                        showTagline: false,
                        onDark: false,
                        showGlow: false,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finishing ? null : _finish,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.brownSoft,
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Lewati'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    allowImplicitScrolling: true,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _SlideView(
                        slide: _slides[index],
                        index: index,
                        controller: _controller,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    4,
                    24,
                    MediaQuery.paddingOf(context).bottom + 18,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (var i = 0; i < _slides.length; i++)
                            GestureDetector(
                              onTap: () => _goTo(i),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: AppMotion.normal,
                                curve: AppMotion.emphasized,
                                width: i == _index ? 26 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: i == _index
                                      ? AppColors.terracotta
                                      : AppColors.borderStrong,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: i == _index
                                      ? <BoxShadow>[
                                          BoxShadow(
                                            color: AppColors.terracotta
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: _isLast ? 'Mulai Sekarang' : 'Selanjutnya',
                        trailingIcon: Icons.arrow_forward_rounded,
                        trailingIconInCircle: true,
                        onPressed: _finishing ? null : _next,
                        loading: _finishing,
                      ),
                    ],
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

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.controller,
  });

  final _SlideData slide;
  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        var page = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? page;
        }
        final delta = (page - index).clamp(-1.0, 1.0);
        final drift = delta.abs();

        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Opacity(
                  opacity: 1 - drift * 0.38,
                  child: Transform.translate(
                    offset: Offset(delta * 22, drift * 8),
                    child: Transform.scale(
                      scale: 1 - drift * 0.035,
                      child: OnboardingVisual(
                        kind: slide.kind,
                        delta: delta,
                        priceLabel: 'Favorit',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: 1 - drift * 0.32,
                child: Transform.translate(
                  offset: Offset(0, drift * 16),
                  child: Column(
                    children: <Widget>[
                      Text(
                        slide.eyebrow,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          letterSpacing: -0.7,
                          color: AppColors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
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
                  Color(0xFFFFF6EA),
                  AppColors.cream,
                  Color(0xFFFBF0E2),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.2),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.terracotta.withValues(alpha: 0.11),
                    AppColors.terracotta.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.size, required this.angle, this.opacity = 0.4});

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
            child: CustomPaint(painter: const _LeafPainter()),
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter();

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
          colors: <Color>[Color(0xFF93B268), Color(0xFF5E7E3E)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.08)
        ..quadraticBezierTo(w * 0.58, h * 0.5, w * 0.5, h * 0.92),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x88476530),
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => false;
}
