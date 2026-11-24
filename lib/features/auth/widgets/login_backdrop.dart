import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Latar sinematik halaman login.
///
/// Foto makanan asli di-blur kuat sehingga hanya menyisakan bokeh hangat ala
/// restoran, lalu ditutup gradasi espresso agar teks dan kartu tetap terbaca.
/// Efek dekoratif dibuat statis (kecuali [StarDust]) supaya tetap ringan.
class LoginBackdrop extends StatelessWidget {
  const LoginBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dasar warm espresso.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF1D110A),
                  Color(0xFF2E1B11),
                  Color(0xFF150B05),
                ],
                stops: <double>[0, 0.48, 1],
              ),
            ),
          ),
          // Foto makanan sebagai bokeh latar.
          Positioned(
            top: -size.height * 0.04,
            left: -36,
            right: -36,
            height: size.height * 0.58,
            child: Opacity(
              opacity: 0.62,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0x55C65A1A),
                    BlendMode.overlay,
                  ),
                  child: Image.asset(
                    'assets/images/products/burger.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    cacheWidth: 800,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          // Overlay gelap agar foreground menonjol.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xE6120804),
                  Color(0x73120804),
                  Color(0xF50E0603),
                ],
                stops: <double>[0, 0.45, 1],
              ),
            ),
          ),
          // Glow keemasan lembut di belakang logo.
          Positioned(
            top: size.height * 0.08,
            left: size.width / 2 - 210,
            child: Container(
              width: 420,
              height: 420,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x2ED6A66A), Color(0x00D6A66A)],
                ),
              ),
            ),
          ),
          // Daun tipis sebagai aksen kedalaman, tidak mengganggu fokus.
          Positioned(
            left: -26,
            top: size.height * 0.12,
            child: const _Leaf(size: 46, angle: 0.6, opacity: 0.22),
          ),
          Positioned(
            right: -16,
            top: size.height * 0.34,
            child: const _Leaf(size: 34, angle: -0.9, opacity: 0.18),
          ),
          Positioned(
            left: 18,
            bottom: 26,
            child: const _Leaf(size: 28, angle: 0.3, opacity: 0.1),
          ),
        ],
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.size, required this.angle, this.opacity = 0.3});

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
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => false;
}
