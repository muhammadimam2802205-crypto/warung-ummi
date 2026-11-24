import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// ---------------------------------------------------------------
/// KEDAI MOTION — transisi halaman & sheet yang terpusat.
/// Semua route memakai preset di sini agar karakter gerak konsisten.
/// ---------------------------------------------------------------
class KedaiTransitions {
  const KedaiTransitions._();

  /// Fade lembut untuk halaman pembuka/onboarding.
  static Page<void> fade({
    required LocalKey key,
    required Widget child,
    Duration duration = AppMotion.normal,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standard,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  /// Slide horizontal halus untuk halaman autentikasi.
  static Page<void> slide({
    required LocalKey key,
    required Widget child,
    Duration duration = AppMotion.smooth,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: AppMotion.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasized,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.055, 0.015),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade + scale + slide untuk halaman detail (produk, pesanan, admin).
  static Page<void> detail({
    required LocalKey key,
    required Widget child,
    Duration duration = AppMotion.slow,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: AppMotion.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standard,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.965, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.015, 0.045),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Preset animasi bottom sheet (muncul dari bawah, turun saat ditutup).
  static const AnimationStyle sheetStyle = AnimationStyle(
    duration: AppMotion.slow,
    reverseDuration: AppMotion.fast,
    curve: AppMotion.standard,
    reverseCurve: Curves.easeInCubic,
  );
}

/// Bottom sheet dengan timing & barrier yang seragam di seluruh aplikasi.
Future<T?> showKedaiSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = false,
  Color? backgroundColor,
  Color barrierColor = const Color(0x8C2A1B13),
  bool enableDrag = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    sheetAnimationStyle: KedaiTransitions.sheetStyle,
    builder: builder,
  );
}
