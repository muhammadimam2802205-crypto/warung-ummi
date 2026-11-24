import 'package:flutter/material.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/food_plate.dart';
import '../../../core/widgets/premium_motion.dart';

/// Branding + hero food.
///
/// Logo tampil lebih dulu, lalu foto makanan melayang sangat halus. Foto
/// diberi mask radial sehingga tepinya melebur ke latar gelap — kesan foto
/// produk restoran, bukan gambar yang ditempel.
class LoginHero extends StatelessWidget {
  const LoginHero({
    super.key,
    required this.brandWidth,
    required this.foodWidth,
  });

  final double brandWidth;
  final double foodWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Reveal(
          index: 0,
          offset: 0.03,
          child: BrandMark(width: brandWidth, onDark: true, showGlow: true),
        ),
        const SizedBox(height: 2),
        Reveal(
          index: 1,
          offset: 0.05,
          child: FloatOn(
            amplitude: 4.5,
            duration: const Duration(milliseconds: 3900),
            child: FoodPlate(
              image: 'assets/images/products/burger.jpg',
              width: foodWidth,
            ),
          ),
        ),
      ],
    );
  }
}
