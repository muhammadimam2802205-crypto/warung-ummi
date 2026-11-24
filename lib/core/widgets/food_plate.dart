import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Foto makanan dalam piring oval dengan tepi melebur ke latar.
///
/// Dipakai di login dan splash agar komposisi "3D food" konsisten:
/// halo hangat, bayangan kontak, mask radial, dan rim emas tipis.
class FoodPlate extends StatelessWidget {
  const FoodPlate({
    super.key,
    required this.image,
    required this.width,
    this.heightFactor = 0.68,
    this.imageAlignment = Alignment.center,
    this.cacheWidth = 800,
    this.glow = true,
    this.rim = true,
    this.fallbackIcon = Icons.lunch_dining_rounded,
  });

  final String image;
  final double width;
  final double heightFactor;
  final Alignment imageAlignment;
  final int cacheWidth;
  final bool glow;
  final bool rim;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final height = width * heightFactor;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (glow)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: RadialGradient(
                    radius: 0.85,
                    colors: <Color>[
                      AppColors.gold.withValues(alpha: 0.2),
                      AppColors.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 2,
            child: Container(
              width: width * 0.6,
              height: height * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const RadialGradient(
                  colors: <Color>[Color(0xA6140A04), Color(0x00140A04)],
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x66200F07),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const RadialGradient(
                  radius: 0.98,
                  colors: <Color>[
                    Colors.white,
                    Colors.white,
                    Color(0x00FFFFFF),
                  ],
                  stops: <double>[0, 0.62, 1],
                ).createShader(rect),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  alignment: imageAlignment,
                  cacheWidth: cacheWidth,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: const Color(0xFF3A2417),
                    child: Icon(
                      fallbackIcon,
                      size: width * 0.3,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (rim)
            IgnorePointer(
              child: CustomPaint(
                size: Size(width, height),
                painter: const _FoodPlateRimPainter(),
              ),
            ),
        ],
      ),
    );
  }
}

class _FoodPlateRimPainter extends CustomPainter {
  const _FoodPlateRimPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x73F4D2AE), Color(0x00F4D2AE)],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FoodPlateRimPainter oldDelegate) => false;
}
