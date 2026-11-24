import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/food_plate.dart';
import '../../../core/widgets/premium_motion.dart';

enum OnboardingVisualKind { welcome, menu, order }

/// Komposisi visual onboarding dengan parallax ringan berdasarkan [delta]
/// (0 = halaman aktif, ±1 = halaman di kiri/kanan).
class OnboardingVisual extends StatelessWidget {
  const OnboardingVisual({
    super.key,
    required this.kind,
    required this.delta,
    required this.priceLabel,
  });

  final OnboardingVisualKind kind;
  final double delta;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = delta.clamp(-1.0, 1.0);
    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.8,
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.14),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          switch (kind) {
            OnboardingVisualKind.welcome => _WelcomeVisual(delta: clamped),
            OnboardingVisualKind.menu => _MenuVisual(
              delta: clamped,
              priceLabel: priceLabel,
            ),
            OnboardingVisualKind.order => _OrderVisual(delta: clamped),
          },
        ],
      ),
    );
  }
}

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final drift = delta * 26;
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(drift * 0.35, 0),
              child: SizedBox(
                width: width * 0.88,
                height: height * 0.9,
                child: _HeroFoodCard(delta: delta),
              ),
            ),
            Positioned(
              right: width * 0.01,
              bottom: height * 0.06,
              child: FloatOn(
                amplitude: 5,
                duration: const Duration(milliseconds: 4200),
                child: Transform.translate(
                  offset: Offset(-drift * 0.55, 0),
                  child: const FoodPlate(
                    image: 'assets/images/products/es-jeruk.jpg',
                    width: 82,
                    heightFactor: 1,
                    rim: false,
                    glow: false,
                    cacheWidth: 220,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroFoodCard extends StatelessWidget {
  const _HeroFoodCard({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 - delta.abs() * 0.03,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: AppShadows.float,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                'assets/images/products/burger.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 900,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.beigeSoft,
                  child: Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 56,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x1A2A1B13),
                      Color(0x002A1B13),
                      Color(0xD92A1B13),
                    ],
                    stops: <double>[0, 0.48, 1],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 12,
                        color: Color(0xFFF6E7D2),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'KEDAI UMMI',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFFF6E7D2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Lezat Setiap Gigitan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Color(0xFFFFF6E8),
                        shadows: <Shadow>[
                          Shadow(
                            color: Color(0x99301D14),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dimasak segar setiap hari',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuVisual extends StatelessWidget {
  const _MenuVisual({required this.delta, required this.priceLabel});

  final double delta;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 326,
        height: 348,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 4,
              top: 34,
              child: Transform.translate(
                offset: Offset(-delta * 20, 0),
                child: Transform.rotate(
                  angle: -0.11,
                  child: const _FoodCard(
                    image: 'assets/images/products/kebab.jpg',
                    width: 168,
                    height: 202,
                    label: 'Kebab',
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 8,
              child: Transform.translate(
                offset: Offset(delta * 16, 0),
                child: Transform.rotate(
                  angle: 0.1,
                  child: const _FoodCard(
                    image: 'assets/images/products/mozarella.jpg',
                    width: 166,
                    height: 200,
                    label: 'Mozarella',
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              child: Transform.translate(
                offset: Offset(delta * 8, 0),
                child: Transform.scale(
                  scale: 1 - delta.abs() * 0.04,
                  child: _FoodCard(
                    image: 'assets/images/products/burger.jpg',
                    width: 208,
                    height: 240,
                    label: 'Burger',
                    badge: priceLabel,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 4,
              child: FloatOn(
                amplitude: 4,
                duration: const Duration(milliseconds: 3800),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.terracotta.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.image,
    required this.width,
    required this.height,
    required this.label,
    this.badge,
  });

  final String image;
  final double width;
  final double height;
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.float,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              image,
              fit: BoxFit.cover,
              cacheWidth: 520,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.beigeSoft,
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.terracotta,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x002A1B13),
                    Color(0x002A1B13),
                    Color(0xB32A1B13),
                  ],
                  stops: <double>[0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFF6E8),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderVisual extends StatelessWidget {
  const _OrderVisual({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 286,
        height: 380,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(-delta * 16, 0),
              child: Transform.scale(
                scale: 1 - delta.abs() * 0.035,
                child: const _PhoneMockup(),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _PopIn(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.float,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pesanan diterima',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 26,
              child: FloatOn(
                amplitude: 5,
                duration: const Duration(milliseconds: 4200),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFFB96D43), Color(0xFF85452F)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: AppShadows.button,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 23,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 208,
      height: 362,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B13),
        borderRadius: BorderRadius.circular(36),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2A1B13).withValues(alpha: 0.4),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ColoredBox(
          color: AppColors.cream,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 12,
                      color: AppColors.brown,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 12,
                      color: AppColors.muted.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(height: 1, color: AppColors.border),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    children: <Widget>[
                      _PhoneCartItem(
                        image: 'assets/images/products/burger.jpg',
                        name: 'Burger Spesial',
                        qty: '1',
                      ),
                      SizedBox(height: 7),
                      _PhoneCartItem(
                        image: 'assets/images/products/es-jeruk.jpg',
                        name: 'Es Jeruk Segar',
                        qty: '2',
                      ),
                      Spacer(),
                      _PhoneTotal(),
                    ],
                  ),
                ),
              ),
              Container(
                height: 35,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFB96D43), Color(0xFF85452F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.terracotta.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneCartItem extends StatelessWidget {
  const _PhoneCartItem({
    required this.image,
    required this.name,
    required this.qty,
  });

  final String image;
  final String name;
  final String qty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            image,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            cacheWidth: 120,
            errorBuilder: (_, _, _) => Container(
              width: 40,
              height: 40,
              color: AppColors.beigeSoft,
              child: const Icon(
                Icons.fastfood_rounded,
                size: 18,
                color: AppColors.terracotta,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.terracottaSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'x$qty',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: AppColors.terracottaDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneTotal extends StatelessWidget {
  const _PhoneTotal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
      decoration: BoxDecoration(
        color: AppColors.beigeSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          _row('Subtotal', 74),
          const SizedBox(height: 4),
          _row('Ongkir', 44),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            children: <Widget>[
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brown,
                ),
              ),
              const Spacer(),
              Container(
                width: 52,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double lineWidth) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: AppColors.brownSoft,
          ),
        ),
        const Spacer(),
        Container(
          width: lineWidth,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.borderStrong.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

/// Scale + fade sekali saat pertama dibangun (tidak berulang).
class _PopIn extends StatefulWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _scale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: AppMotion.overshoot),
      ),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
