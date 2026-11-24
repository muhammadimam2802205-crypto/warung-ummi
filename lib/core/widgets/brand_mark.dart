import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo Kedai Ummi: topi koki + wordmark script + slogan.
/// Dipakai di splash, onboarding, login, dan registrasi agar konsisten.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.width = 280,
    this.showTagline = true,
    this.onDark = true,
    this.showGlow = true,
  });

  final double width;
  final bool showTagline;
  final bool onDark;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final scale = width / 280;
    final taglineColor = onDark
        ? const Color(0xFFF1DEC7)
        : const Color(0xFF7A4A2A);

    final logo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChefHatMark(size: 62 * scale),
        SizedBox(height: 1 * scale),
        _ScriptLine(text: 'Kedai', size: 44 * scale, letterSpacing: -1 * scale),
        Transform.translate(
          offset: Offset(0, -10 * scale),
          child: _ScriptLine(
            text: 'Ummi',
            size: 82 * scale,
            letterSpacing: -2 * scale,
          ),
        ),
        if (showTagline) ...[
          Transform.translate(
            offset: Offset(0, -10 * scale),
            child: _Swoosh(width: 118 * scale),
          ),
          Transform.translate(
            offset: Offset(0, -6 * scale),
            child: Text(
              '"Lezat Setiap Gigitan"',
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14 * scale,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: taglineColor,
                shadows: onDark
                    ? const [
                        Shadow(
                          color: Color(0x99301D14),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ],
    );

    if (!showGlow) return SizedBox(width: width, child: logo);

    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: width * 0.85,
              height: width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: onDark ? 0.18 : 0.14),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          logo,
        ],
      ),
    );
  }
}

class _ScriptLine extends StatelessWidget {
  const _ScriptLine({
    required this.text,
    required this.size,
    required this.letterSpacing,
  });

  final String text;
  final double size;
  final double letterSpacing;

  TextStyle get _base => TextStyle(
    fontFamily: 'Pacifico',
    fontFamilyFallback: const ['Georgia', 'Noto Serif', 'serif'],
    fontSize: size,
    height: 0.95,
    letterSpacing: letterSpacing,
  );

  @override
  Widget build(BuildContext context) {
    final goldOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.14
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF8A5A2B);
    final brownOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.055
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF432718);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, size * 0.07),
          child: Text(
            text,
            maxLines: 1,
            style: _base.copyWith(
              color: const Color(0xFF2A1B13),
              shadows: [
                Shadow(
                  color: const Color(0x992A1B13),
                  blurRadius: size * 0.14,
                  offset: Offset(0, size * 0.05),
                ),
              ],
            ),
          ),
        ),
        Text(text, maxLines: 1, style: _base.copyWith(foreground: goldOutline)),
        Text(
          text,
          maxLines: 1,
          style: _base.copyWith(foreground: brownOutline),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF7), Color(0xFFF9E5C4), Color(0xFFE8C18C)],
          ).createShader(rect),
          child: Text(
            text,
            maxLines: 1,
            style: _base.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ChefHatMark extends StatelessWidget {
  const ChefHatMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _ChefHatPainter(),
    );
  }
}

class _ChefHatPainter extends CustomPainter {
  const _ChefHatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    Path hat = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w * 0.30, h * 0.42), radius: w * 0.20),
      );
    hat = Path.combine(
      PathOperation.union,
      hat,
      Path()..addOval(
        Rect.fromCircle(center: Offset(w * 0.50, h * 0.30), radius: w * 0.225),
      ),
    );
    hat = Path.combine(
      PathOperation.union,
      hat,
      Path()..addOval(
        Rect.fromCircle(center: Offset(w * 0.70, h * 0.42), radius: w * 0.20),
      ),
    );
    hat = Path.combine(
      PathOperation.union,
      hat,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.30, h * 0.38, w * 0.40, h * 0.42),
          Radius.circular(w * 0.05),
        ),
      ),
    );

    canvas.drawPath(
      hat.shift(Offset(0, h * 0.05)),
      Paint()
        ..color = const Color(0x73301D14)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05),
    );

    canvas.drawPath(
      hat,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF6), Color(0xFFF7E7CE), Color(0xFFE8CCA5)],
        ).createShader(rect),
    );

    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.61, w * 0.36, h * 0.19),
      Radius.circular(w * 0.045),
    );
    canvas.drawRRect(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF1), Color(0xFFEFD9B8)],
        ).createShader(band.outerRect),
    );

    canvas.drawLine(
      Offset(w * 0.33, h * 0.61),
      Offset(w * 0.67, h * 0.61),
      Paint()
        ..color = const Color(0x33A65D3F)
        ..strokeWidth = w * 0.014,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.30), radius: w * 0.185),
      3.55,
      1.05,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.03
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    canvas.drawPath(
      hat,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..color = const Color(0xFF5B3828),
    );
  }

  @override
  bool shouldRepaint(covariant _ChefHatPainter oldDelegate) => false;
}

class _Swoosh extends StatelessWidget {
  const _Swoosh({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 9,
      child: CustomPaint(painter: const _SwooshPainter()),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.52, h * -0.85, w, h * 0.38);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0x00FFFFFF), Color(0xFFFFF6E8), Color(0xFFEAC792)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _SwooshPainter oldDelegate) => false;
}
