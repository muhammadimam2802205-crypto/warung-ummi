import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'local_image.dart';

/// ---------------------------------------------------------------
/// SHARED UI KIT — Kedai Ummi 2.0
/// ---------------------------------------------------------------

enum AppButtonVariant { primary, secondary, ghost, dark }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expand = true,
    this.compact = false,
    this.trailingIconInCircle = false,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final bool loading;
  final bool expand;
  final bool compact;
  final bool trailingIconInCircle;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final height = compact ? 46.0 : 54.0;
    final radius = BorderRadius.circular(AppRadii.button);
    final disabled = loading || onPressed == null;
    final tap = disabled
        ? null
        : () {
            HapticFeedback.selectionClick();
            onPressed?.call();
          };
    final foreground = switch (variant) {
      AppButtonVariant.primary => disabled ? AppColors.muted : AppColors.white,
      AppButtonVariant.dark => AppColors.white,
      AppButtonVariant.secondary => AppColors.brown,
      AppButtonVariant.ghost => AppColors.terracottaDark,
    };

    final content = AnimatedSwitcher(
      duration: AppMotion.fast,
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color:
                    variant == AppButtonVariant.primary ||
                        variant == AppButtonVariant.dark
                    ? AppColors.white
                    : AppColors.terracotta,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 9),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 9),
                  if (trailingIconInCircle)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF4E6),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        trailingIcon,
                        size: 15,
                        color: AppColors.terracottaDark,
                      ),
                    )
                  else
                    Icon(trailingIcon, size: 18),
                ],
              ],
            ),
    );

    if (variant == AppButtonVariant.primary) {
      final button = SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: disabled ? AppColors.beige : null,
            gradient: disabled ? null : (gradient ?? AppColors.primaryGradient),
            boxShadow: disabled ? null : AppShadows.button,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: tap,
              borderRadius: radius,
              splashColor: Colors.white.withValues(alpha: 0.14),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!disabled)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: height * 0.52,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadii.button),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.01),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconTheme.merge(
                      data: IconThemeData(color: foreground),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: foreground,
                          fontSize: compact ? 13.5 : 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                        child: content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final wrapped = reduced
          ? button
          : PressScale(
              enabled: !disabled,
              scale: 0.975,
              lift: 0,
              child: button,
            );
      return expand
          ? SizedBox(width: double.infinity, child: wrapped)
          : wrapped;
    }

    final button = switch (variant) {
      AppButtonVariant.primary => throw StateError('handled above'),
      AppButtonVariant.dark => ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.espresso,
          foregroundColor: AppColors.white,
          minimumSize: Size(0, height),
        ),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: tap,
        style: OutlinedButton.styleFrom(minimumSize: Size(0, height)),
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: tap,
        style: TextButton.styleFrom(minimumSize: Size(0, height)),
        child: content,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Angka rupiah yang beranimasi halus ketika nilainya berubah.
///
/// Nilai bisnis tetap dihitung oleh provider; widget ini hanya menginterpolasi
/// tampilan agar perubahan total tidak "meloncat".
class AnimatedRupiah extends StatelessWidget {
  const AnimatedRupiah({
    super.key,
    required this.value,
    this.style,
    this.textAlign,
    this.duration = const Duration(milliseconds: 620),
  });

  final int value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: reduce ? Duration.zero : duration,
      curve: AppMotion.standard,
      builder: (context, animated, _) => Text(
        rupiah(animated.round()),
        style: style,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Badge jumlah dengan bounce lembut setiap kali angkanya berubah.
class BounceBadge extends StatelessWidget {
  const BounceBadge({
    super.key,
    required this.count,
    required this.child,
    this.backgroundColor = AppColors.terracotta,
    this.textColor = AppColors.white,
    this.maxCount = 9,
  });

  final int count;
  final Widget child;
  final Color backgroundColor;
  final Color textColor;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(count),
      tween: Tween<double>(begin: reduce ? 1 : 1.42, end: 1),
      duration: reduce ? Duration.zero : AppMotion.emphasis,
      curve: AppMotion.overshoot,
      builder: (context, scale, badgeChild) {
        return Transform.scale(
          scale: scale,
          child: Badge(
            isLabelVisible: true,
            backgroundColor: backgroundColor,
            textColor: textColor,
            label: Text(
              count > maxCount ? '$maxCount+' : '$count',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: badgeChild,
          ),
        );
      },
      child: child,
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.suffixIcon,
    this.autofillHints,
    this.prefixText,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final String? prefixText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      textInputAction: textInputAction,
      enabled: enabled,
      autofillHints: autofillHints,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.brown,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        prefixText: prefixText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Cari menu...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.brown,
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: AppColors.brownSoft,
          ),
          suffixIcon: (controller != null && controller!.text.isNotEmpty)
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = AppRadii.card,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final useGradient = color == AppColors.surface;
    return Container(
      decoration: BoxDecoration(
        color: useGradient ? null : color,
        gradient: useGradient ? AppColors.cardGradient : null,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: shadow ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.terracotta,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.terracottaDark,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_rounded, size: 15),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    this.path,
    this.emoji = '🍽️',
    this.size,
    this.radius = 16,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.hint = true,
  });

  final String? path;
  final String emoji;
  final double? size;
  final double radius;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool hint;

  @override
  Widget build(BuildContext context) {
    final imagePath = path ?? '';
    if (imagePath.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = size ?? width ?? constraints.maxWidth;
          final h = size ?? height ?? constraints.maxHeight;
          final dimension = (w.isFinite ? w : 160)
              .clamp(40.0, 420.0)
              .toDouble();
          final showHint = hint && dimension >= 150 && h.isFinite && h >= 130;
          return ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: size ?? width,
              height: size ?? height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.creamDeep, AppColors.beigeSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -18,
                    top: -18,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -24,
                    bottom: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.terracotta.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: dimension * 0.52,
                      height: dimension * 0.52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.7),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12241A14),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: dimension * 0.24),
                      ),
                    ),
                  ),
                  if (showHint)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Foto belum tersedia',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownSoft,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return ProductImage(
        emoji: emoji,
        size: size,
        radius: radius,
        width: width,
        height: height,
        hint: hint,
      );
    }

    final image = imagePath.startsWith('assets/')
        ? Image.asset(
            imagePath,
            width: size ?? width,
            height: size ?? height,
            fit: fit,
            filterQuality: FilterQuality.medium,
            errorBuilder: errorBuilder,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: AppMotion.normal,
                switchInCurve: AppMotion.standard,
                child: frame == null
                    ? _ImageLoadingPlaceholder(
                        key: const ValueKey('loading'),
                        emoji: emoji,
                      )
                    : KeyedSubtree(key: const ValueKey('image'), child: child),
              );
            },
          )
        : localImage(
            imagePath,
            width: size ?? width,
            height: size ?? height,
            fit: fit,
            errorBuilder: errorBuilder,
          );

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder({super.key, required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.creamDeep, AppColors.beigeSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.4,
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.background = AppColors.beigeSoft,
    this.foreground = AppColors.brown,
    this.compact = false,
    this.dot = false,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool compact;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusVisual {
  const StatusVisual({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;
}

StatusVisual statusVisual(OrderStatus status) {
  return switch (status) {
    OrderStatus.pendingConfirmation => const StatusVisual(
      icon: Icons.hourglass_top_rounded,
      color: AppColors.warning,
      background: AppColors.warningSoft,
    ),
    OrderStatus.confirmed => const StatusVisual(
      icon: Icons.verified_rounded,
      color: AppColors.info,
      background: AppColors.infoSoft,
    ),
    OrderStatus.preparing => const StatusVisual(
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.terracotta,
      background: AppColors.terracottaSoft,
    ),
    OrderStatus.readyForPickup => const StatusVisual(
      icon: Icons.shopping_bag_rounded,
      color: AppColors.success,
      background: AppColors.successSoft,
    ),
    OrderStatus.outForDelivery => const StatusVisual(
      icon: Icons.delivery_dining_rounded,
      color: AppColors.info,
      background: AppColors.infoSoft,
    ),
    OrderStatus.completed => const StatusVisual(
      icon: Icons.task_alt_rounded,
      color: AppColors.success,
      background: AppColors.successSoft,
    ),
    OrderStatus.rejected || OrderStatus.cancelled => const StatusVisual(
      icon: Icons.cancel_rounded,
      color: AppColors.danger,
      background: AppColors.dangerSoft,
    ),
  };
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visual = statusVisual(status);
    return AppBadge(
      label: status.label,
      background: visual.background,
      foreground: visual.color,
      compact: compact,
      dot: true,
    );
  }
}

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final PaymentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      PaymentStatus.pending ||
      PaymentStatus.unpaid => (AppColors.warningSoft, AppColors.warning),
      PaymentStatus.waitingVerification => (AppColors.infoSoft, AppColors.info),
      PaymentStatus.paid => (AppColors.successSoft, AppColors.success),
      PaymentStatus.rejected => (AppColors.dangerSoft, AppColors.danger),
    };
    return AppBadge(
      label: status.label,
      background: bg,
      foreground: fg,
      compact: compact,
      dot: true,
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final side = compact ? 28.0 : 34.0;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: side,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
          ),
          SizedBox(
            width: compact ? 26 : 32,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.overshoot,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.35),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '$value',
                key: ValueKey<int>(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 13 : 14.5,
                  color: AppColors.brown,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: side,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final active = enabled;
    return Material(
      color: emphasized && active ? AppColors.terracotta : AppColors.beigeSoft,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: active ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: 17,
            color: !active
                ? AppColors.muted.withValues(alpha: 0.35)
                : emphasized
                ? AppColors.white
                : AppColors.brown,
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.eyebrow,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.beigeSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: AppColors.terracotta),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (eyebrow != null) ...[
              Text(
                eyebrow!.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Menyiapkan menu...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.beigeSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: AppColors.brownSoft),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.brown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
    this.note,
  });

  final String label;
  final int value;
  final bool emphasize;
  final Color? valueColor;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: emphasize
                      ? const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        )
                      : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.brownSoft,
                        ),
                ),
                if (note != null)
                  Text(note!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          AnimatedRupiah(
            value: value,
            style: TextStyle(
              fontSize: emphasize ? 20 : 13.5,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              letterSpacing: emphasize ? -0.3 : 0,
              color: valueColor ?? AppColors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.04 : 1.0,
      duration: AppMotion.normal,
      curve: AppMotion.spring,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.surface,
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? AppColors.terracottaDark.withValues(alpha: 0.45)
                  : AppColors.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.terracotta.withValues(alpha: 0.26),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: AppColors.espresso.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.brownSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.backgroundColor = AppColors.beige,
    this.foregroundColor = AppColors.terracottaDark,
  });

  final String name;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 42,
    this.background = AppColors.surface,
    this.foreground = AppColors.brown,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color background;
  final Color foreground;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.46, color: foreground),
        ),
      ),
    );
    if (badgeCount <= 0) return button;
    return Badge(
      isLabelVisible: true,
      backgroundColor: AppColors.terracotta,
      label: Text(
        badgeCount > 9 ? '9+' : '$badgeCount',
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
      ),
      child: button,
    );
  }
}

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final entries = order.timeline.reversed.toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isLatest: i == 0,
            isLast: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isLatest,
    required this.isLast,
  });

  final TimelineEntry entry;
  final bool isLatest;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final visual = statusVisual(entry.status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isLatest ? visual.background : AppColors.beigeSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLatest ? visual.color : AppColors.border,
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  visual.icon,
                  size: 13,
                  color: isLatest ? visual.color : AppColors.muted,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.6,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.status.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isLatest ? FontWeight.w800 : FontWeight.w600,
                      color: isLatest ? AppColors.brown : AppColors.brownSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(entry.at),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.note,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.brownSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pelacakan progres pesanan untuk pelanggan.
class OrderProgressRail extends StatelessWidget {
  const OrderProgressRail({super.key, required this.order});

  final Order order;

  int get _activeIndex {
    switch (order.status) {
      case OrderStatus.pendingConfirmation:
        return -1;
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.readyForPickup:
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return -2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final closed =
        order.status == OrderStatus.rejected ||
        order.status == OrderStatus.cancelled;
    if (closed) {
      return const SizedBox.shrink();
    }

    final handoverLabel = order.serviceType == ServiceType.delivery
        ? 'Diantar'
        : 'Siap';
    final handoverIcon = order.serviceType == ServiceType.delivery
        ? Icons.delivery_dining_rounded
        : Icons.shopping_bag_rounded;
    final steps = <(String, IconData)>[
      ('Dikonfirmasi', Icons.verified_rounded),
      ('Diproses', Icons.soup_kitchen_rounded),
      (handoverLabel, handoverIcon),
      ('Selesai', Icons.task_alt_rounded),
    ];
    final active = _activeIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (active < 0)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Menunggu konfirmasi admin kedai',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i <= active
                                  ? AppColors.terracotta
                                  : AppColors.border,
                            ),
                          )
                        else
                          const Spacer(),
                        AnimatedContainer(
                          duration: AppMotion.normal,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: i <= active
                                ? AppColors.terracotta
                                : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: i <= active
                                  ? AppColors.terracotta
                                  : AppColors.border,
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            i < active ? Icons.check_rounded : steps[i].$2,
                            size: 14,
                            color: i <= active
                                ? AppColors.white
                                : AppColors.muted,
                          ),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i < active
                                  ? AppColors.terracotta
                                  : AppColors.border,
                            ),
                          )
                        else
                          const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      steps[i].$1,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: i == active
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: i <= active ? AppColors.brown : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Animasi masuk yang halus dan berurutan.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 0.05,
    this.duration = AppMotion.reveal,
    this.enabled = true,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;
  final bool enabled;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final start = widget.enabled
        ? (widget.index * 0.07).clamp(0.0, 0.42).toDouble()
        : 0.0;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppMotion.emphasized),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(begin: 0.965, end: 1).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

/// Efek tekan lembut tanpa merebut gesture anak.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.985,
    this.lift = 2.5,
    this.enabled = true,
  });

  final Widget child;
  final double scale;
  final double lift;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduced ? Duration.zero : AppMotion.fast;
    return Listener(
      onPointerDown: widget.enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onPointerUp: widget.enabled
          ? (_) => setState(() => _pressed = false)
          : null,
      onPointerCancel: widget.enabled
          ? (_) => setState(() => _pressed = false)
          : null,
      child: AnimatedContainer(
        duration: duration,
        curve: AppMotion.spring,
        transform: Matrix4.translationValues(0, _pressed ? -widget.lift : 0, 0),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: duration,
          curve: AppMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce == _reduceMotion) return;
    _reduceMotion = reduce;
    if (reduce) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box(double progress) {
    final shift = -2.4 + progress * 4.8;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: LinearGradient(
          begin: Alignment(shift - 1, 0),
          end: Alignment(shift + 1, 0),
          colors: const <Color>[
            Color(0xFFF6EADB),
            Color(0xFFFFFCF6),
            Color(0xFFF6EADB),
          ],
          stops: const <double>[0.15, 0.5, 0.85],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion ?? false) return _box(0.5);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _box(_controller.value),
    );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya, lanjutkan',
  String cancelLabel = 'Batal',
  bool destructive = false,
}) async {
  final accent = destructive ? AppColors.danger : AppColors.terracotta;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: destructive
                    ? AppColors.dangerSoft
                    : AppColors.terracottaSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                destructive
                    ? Icons.warning_amber_rounded
                    : Icons.help_outline_rounded,
                color: accent,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.secondary,
                    compact: true,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    compact: true,
                    onPressed: () => Navigator.pop(context, true),
                    variant: destructive
                        ? AppButtonVariant.dark
                        : AppButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Notifikasi premium: kartu espresso melayang dengan ikon emas.
/// Slide-in/fade serta auto-dismiss ditangani [SnackBar]; kartu ini hanya
/// memperkuat identitas visual Kedai Ummi.
void showAppSnack(
  BuildContext context,
  String message, {
  bool error = false,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(milliseconds: 2800),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  final accent = error ? const Color(0xFFFFB4A8) : const Color(0xFFF3D89B);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: EdgeInsets.zero,
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        content: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: reduce ? 1 : 0.94, end: 1),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 520),
          curve: AppMotion.overshoot,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: error
                    ? const <Color>[Color(0xFF6E241C), Color(0xFF3A1511)]
                    : const <Color>[Color(0xFF3B2A1F), Color(0xFF241710)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (error ? AppColors.dangerSoft : AppColors.gold)
                    .withValues(alpha: 0.28),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x4D1C120E),
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: (error ? AppColors.dangerSoft : AppColors.gold)
                        .withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    error
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    size: 17,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (actionLabel != null) ...<Widget>[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      onAction?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
}
