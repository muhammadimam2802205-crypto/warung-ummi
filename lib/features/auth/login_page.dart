import 'package:flutter/material.dart';

import '../../core/widgets/app_widgets.dart';
import 'widgets/login_backdrop.dart';
import 'widgets/login_card.dart';
import 'widgets/login_hero.dart';

/// Login Kedai Ummi — 3D Premium Food Experience.
///
/// Komposisi: latar restoran sinematik → branding hangat → foto makanan
/// melayang → kartu login cream yang terangkat. Seluruh form berada langsung
/// di halaman ini agar bisa dipakai dalam satu layar, tanpa bottom sheet.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final compact = size.height < 700 || size.width < 360;
    final reduceMotion = media.disableAnimations;

    final brandWidth = compact
        ? (size.width * 0.46).clamp(142.0, 180.0)
        : (size.width * 0.52).clamp(180.0, 228.0);
    final foodWidth = compact
        ? (size.width * 0.48).clamp(150.0, 192.0)
        : (size.width * 0.54).clamp(185.0, 244.0);

    return Scaffold(
      backgroundColor: const Color(0xFF150B05),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: const LoginBackdrop(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.zero,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: compact ? 4 : 16,
                            bottom: media.padding.bottom + 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              LoginHero(
                                brandWidth: brandWidth,
                                foodWidth: foodWidth,
                              ),
                              SizedBox(height: compact ? 8 : 16),
                              const Reveal(
                                index: 2,
                                offset: 0.08,
                                child: LoginCard(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
