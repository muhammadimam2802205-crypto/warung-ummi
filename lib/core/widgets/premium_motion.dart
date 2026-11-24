import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ---------------------------------------------------------------
/// PREMIUM MOTION — Kedai Ummi
/// Primitive animasi ringan untuk tampilan yang lebih "hidup":
/// aurora mesh, partikel, sapuan cahaya, border gradient, dan teks dinamis.
/// ---------------------------------------------------------------

const List<Color> _kAuroraPalette = <Color>[
  Color(0xFFBE5B37),
  Color(0xFFC6A05B),
  Color(0xFF8E3D22),
  Color(0xFF5E7C86),
];

const List<Color> _kGoldPalette = <Color>[
  Color(0xFFC6A05B),
  Color(0xFFFFE6A8),
  Color(0xFFBE5B37),
  Color(0xFFC6A05B),
];

double _fract(double value) => value - value.floor();

bool _reducedMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Durasi animasi yang otomatis menjadi instant saat pengguna meminta
/// pengurangan gerak (digunakan tes & aksesibilitas).
Duration adaptiveDuration(BuildContext context, Duration duration) =>
    _reducedMotion(context) ? Duration.zero : duration;

/// Background gradient yang "bernapas" dengan bintik cahaya.
class AuroraBackdrop extends StatefulWidget {
  const AuroraBackdrop({
    super.key,
    this.child,
    this.baseColors = const <Color>[Color(0xFF2B1E16), AppColors.espresso],
    this.colors = _kAuroraPalette,
    this.duration = const Duration(seconds: 24),
    this.opacity = 1,
    this.showParticles = true,
  });

  final Widget? child;
  final List<Color> baseColors;
  final List<Color> colors;
  final Duration duration;
  final double opacity;
  final bool showParticles;

  @override
  State<AuroraBackdrop> createState() => _AuroraBackdropState();
}

class _AuroraBackdropState extends State<AuroraBackdrop>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant AuroraBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller?.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint({required double progress}) => RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(
          progress: progress,
          baseColors: widget.baseColors,
          colors: widget.colors,
          opacity: widget.opacity,
          particles: widget.showParticles,
        ),
      ),
    );

    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller == null)
          paint(progress: 0.38)
        else
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => paint(progress: controller.value),
          ),
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.progress,
    required this.baseColors,
    required this.colors,
    required this.opacity,
    required this.particles,
  });

  final double progress;
  final List<Color> baseColors;
  final List<Color> colors;
  final double opacity;
  final bool particles;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: baseColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    for (var i = 0; i < colors.length; i++) {
      final phase = i * 1.73;
      final angle = progress * math.pi * 2 + phase;
      final center = Offset(
        size.width * (0.5 + 0.44 * math.cos(angle + i * 0.6)),
        size.height * (0.5 + 0.44 * math.sin(angle * 1.17 + i * 1.4)),
      );
      final radius =
          size.shortestSide * (0.52 + 0.16 * math.sin(angle * 0.83 + i));
      final shader = RadialGradient(
        colors: <Color>[
          colors[i].withValues(alpha: 0.46 * opacity),
          colors[i].withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, Paint()..shader = shader);
    }

    if (particles) {
      final paint = Paint();
      for (var i = 0; i < 26; i++) {
        final x = _fract(i * 0.6180339887) * size.width;
        final y = _fract(i * 0.7548776662 + 0.13) * size.height;
        final twinkle = 0.5 + 0.5 * math.sin(progress * math.pi * 4 + i * 1.9);
        paint.color = Colors.white.withValues(
          alpha: 0.08 + 0.38 * twinkle * opacity,
        );
        canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 1.7 : 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.opacity != opacity ||
      oldDelegate.colors != colors;
}

/// Lapisan bintik cahaya untuk diletakkan di atas gambar/gelap.
class StarDust extends StatefulWidget {
  const StarDust({
    super.key,
    this.count = 22,
    this.color = Colors.white,
    this.opacity = 0.5,
    this.duration = const Duration(seconds: 12),
  });

  final int count;
  final Color color;
  final double opacity;
  final Duration duration;

  @override
  State<StarDust> createState() => _StarDustState();
}

class _StarDustState extends State<StarDust>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint({required double progress}) => CustomPaint(
      painter: _StarDustPainter(
        progress: progress,
        count: widget.count,
        color: widget.color,
        opacity: widget.opacity,
      ),
    );

    final controller = _controller;
    return IgnorePointer(
      child: RepaintBoundary(
        child: controller == null
            ? paint(progress: 0.25)
            : AnimatedBuilder(
                animation: controller,
                builder: (context, _) => paint(progress: controller.value),
              ),
      ),
    );
  }
}

class _StarDustPainter extends CustomPainter {
  const _StarDustPainter({
    required this.progress,
    required this.count,
    required this.color,
    required this.opacity,
  });

  final double progress;
  final int count;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      final x = _fract(i * 0.6180339887 + 0.07) * size.width;
      final y = _fract(i * 0.4142135623 + 0.31) * size.height;
      final twinkle = 0.5 + 0.5 * math.sin(progress * math.pi * 4 + i * 2.3);
      final alpha = opacity * (0.22 + 0.78 * twinkle);
      paint.color = color.withValues(alpha: alpha);
      final r = i % 4 == 0 ? 2.4 : 1.1;
      if (i % 4 == 0) {
        final path = Path()
          ..moveTo(x, y - r * 2)
          ..lineTo(x + r * 0.55, y - r * 0.55)
          ..lineTo(x + r * 2, y)
          ..lineTo(x + r * 0.55, y + r * 0.55)
          ..lineTo(x, y + r * 2)
          ..lineTo(x - r * 0.55, y + r * 0.55)
          ..lineTo(x - r * 2, y)
          ..lineTo(x - r * 0.55, y - r * 0.55)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarDustPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.count != count;
}

/// Sapuan cahaya diagonal yang lewat sesekali di atas kartu.
class ShineSweep extends StatefulWidget {
  const ShineSweep({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.interval = const Duration(milliseconds: 6200),
    this.enabled = true,
  });

  final Widget child;
  final Color color;
  final Duration interval;
  final bool enabled;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || !widget.enabled || _reducedMotion(context)) {
      return;
    }
    _controller = AnimationController(vsync: this, duration: widget.interval)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant ShineSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) {
      _controller?.duration = widget.interval;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!widget.enabled || controller == null) return widget.child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ShinePainter(
                    progress: controller.value,
                    color: widget.color,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ShinePainter extends CustomPainter {
  const _ShinePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = ((progress - 0.06) / 0.34).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;

    final band = size.width * 0.34;
    final x = -size.width * 0.45 + t * size.width * 1.9;
    canvas.save();
    canvas.translate(x, size.height / 2);
    canvas.rotate(-0.32);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: band,
      height: size.height * 2.2,
    );
    final shader = LinearGradient(
      colors: <Color>[
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.05),
        color.withValues(alpha: 0.18),
        color.withValues(alpha: 0.05),
        color.withValues(alpha: 0),
      ],
      stops: const <double>[0, 0.28, 0.5, 0.72, 1],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Bingkai gradient yang berputar dengan efek glow lembut.
class GlowFrame extends StatefulWidget {
  const GlowFrame({
    super.key,
    required this.child,
    this.radius = 28,
    this.colors = _kGoldPalette,
    this.strokeWidth = 1.4,
    this.glow = true,
    this.duration = const Duration(seconds: 9),
  });

  final Widget child;
  final double radius;
  final List<Color> colors;
  final double strokeWidth;
  final bool glow;
  final Duration duration;

  @override
  State<GlowFrame> createState() => _GlowFrameState();
}

class _GlowFrameState extends State<GlowFrame>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint({required double progress}) => CustomPaint(
      painter: _GlowFramePainter(
        progress: progress,
        radius: widget.radius,
        colors: widget.colors,
        strokeWidth: widget.strokeWidth,
        glow: widget.glow,
      ),
    );

    final controller = _controller;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: controller == null
                ? paint(progress: 0)
                : AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => paint(progress: controller.value),
                  ),
          ),
        ),
      ],
    );
  }
}

class _GlowFramePainter extends CustomPainter {
  const _GlowFramePainter({
    required this.progress,
    required this.radius,
    required this.colors,
    required this.strokeWidth,
    required this.glow,
  });

  final double progress;
  final double radius;
  final List<Color> colors;
  final double strokeWidth;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    if (glow) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 4
          ..color = colors.first.withValues(alpha: 0.13)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }
    final shader = SweepGradient(
      colors: <Color>[...colors, colors.first],
      transform: GradientRotation(progress * math.pi * 2),
    ).createShader(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowFramePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Teks dengan gradasi yang mengalir lembut.
class GradientText extends StatefulWidget {
  const GradientText({
    super.key,
    required this.text,
    required this.style,
    this.colors = const <Color>[
      AppColors.espresso,
      AppColors.terracottaDark,
      AppColors.gold,
      AppColors.terracottaDark,
    ],
    this.duration = const Duration(seconds: 8),
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final List<Color> colors;
  final Duration duration;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint({required double t}) => ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: widget.colors,
          begin: Alignment(-1.5 + 2.5 * t, -0.35),
          end: Alignment(-0.5 + 2.5 * t, 0.35),
        ).createShader(bounds);
      },
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
      ),
    );

    final controller = _controller;
    if (controller == null) return paint(t: 0);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => paint(t: controller.value),
    );
  }
}

/// Angka yang menghitung naik saat pertama muncul.
class CountUpNumber extends StatelessWidget {
  const CountUpNumber({
    super.key,
    required this.value,
    this.style,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1400),
    this.textAlign,
    this.overflow,
  });

  final double value;
  final TextStyle? style;
  final int decimals;
  final String prefix;
  final String suffix;
  final Duration duration;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: _reducedMotion(context) ? Duration.zero : duration,
      curve: Curves.easeOutExpo,
      builder: (context, animated, _) {
        return Text(
          '$prefix${animated.toStringAsFixed(decimals)}$suffix',
          style: style,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }
}

/// Teks berjalan tanpa henti (ticker promo).
class MarqueeText extends StatefulWidget {
  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.separator = '   ✦   ',
    this.speed = 46,
  });

  final String text;
  final TextStyle style;
  final String separator;
  final double speed;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  static const _loop = Duration(seconds: 20);

  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: _loop)..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chunk = '${widget.text}${widget.separator}';
    final painter = TextPainter(
      text: TextSpan(text: chunk, style: widget.style),
      textDirection: Directionality.of(context),
    )..layout();
    final unit = painter.width > 0 ? painter.width : 1.0;
    final cycles = math.max(1, (widget.speed * 20 / unit).round());

    final controller = _controller;
    return LayoutBuilder(
      builder: (context, constraints) {
        final copies = (constraints.maxWidth / unit).ceil() + 2;
        Widget row({required double value}) => Transform.translate(
          offset: Offset(value, 0),
          child: Row(
            children: <Widget>[
              for (var i = 0; i < copies; i++)
                Text(chunk, style: widget.style, softWrap: false),
            ],
          ),
        );
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: controller == null
                ? row(value: 0)
                : AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final travel = controller.value * cycles * unit;
                      return row(value: -(travel % unit));
                    },
                  ),
          ),
        );
      },
    );
  }
}

/// Titik "live" dengan halo yang memuai.
class LivePulseDot extends StatefulWidget {
  const LivePulseDot({super.key, required this.color, this.size = 6});

  final Color color;
  final double size;

  @override
  State<LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<LivePulseDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint({required double t}) {
      final halo = widget.size * (1 + t * 1.6);
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: halo,
            height: halo,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.36 * (1 - t)),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 7,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final controller = _controller;
    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: controller == null
          ? paint(t: 0.4)
          : AnimatedBuilder(
              animation: controller,
              builder: (context, _) => paint(t: controller.value),
            ),
    );
  }
}

/// Gerak melayang kontinu untuk aksen dekoratif.
class FloatOn extends StatefulWidget {
  const FloatOn({
    super.key,
    required this.child,
    this.amplitude = 5,
    this.duration = const Duration(milliseconds: 3600),
    this.phase = 0,
  });

  final Widget child;
  final double amplitude;
  final Duration duration;
  final double phase;

  @override
  State<FloatOn> createState() => _FloatOnState();
}

class _FloatOnState extends State<FloatOn> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null || _reducedMotion(context)) return;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value * math.pi * 2 + widget.phase;
        return Transform.translate(
          offset: Offset(
            math.cos(t) * widget.amplitude * 0.35,
            math.sin(t) * widget.amplitude,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Interaksi "magnetik": tombol sedikit mengikuti titik sentuh lalu kembali,
/// disertai ripple halus. Tanpa controller permanen dan tetap ringan.
class MagneticPress extends StatefulWidget {
  const MagneticPress({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.strength = 4,
    this.rippleColor = AppColors.gold,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double strength;
  final Color rippleColor;

  @override
  State<MagneticPress> createState() => _MagneticPressState();
}

class _MagneticPressState extends State<MagneticPress> {
  Offset _pull = Offset.zero;
  Offset? _rippleAt;
  int _rippleId = 0;

  bool get _canMove => mounted && widget.enabled && !_reducedMotion(context);

  Offset _localOf(PointerEvent event) {
    if (!mounted) return Offset.zero;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Offset.zero;
    return box.globalToLocal(event.position);
  }

  void _updatePull(PointerEvent event) {
    if (!_canMove) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    setState(() {
      _pull = Offset(
        (local.dx / box.size.width - 0.5) * 2 * widget.strength,
        (local.dy / box.size.height - 0.5) * 2 * widget.strength,
      );
    });
  }

  void _release(PointerEvent event) {
    if (!_canMove) return;
    setState(() {
      _pull = Offset.zero;
      _rippleAt = _localOf(event);
      _rippleId++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rippleAt = _rippleAt;
    return Listener(
      onPointerDown: widget.enabled ? _updatePull : null,
      onPointerMove: widget.enabled ? _updatePull : null,
      onPointerUp: widget.enabled ? _release : null,
      onPointerCancel: widget.enabled ? _release : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            AnimatedContainer(
              duration: adaptiveDuration(context, AppMotion.fast),
              curve: AppMotion.standard,
              transform: Matrix4.translationValues(_pull.dx, _pull.dy, 0),
              child: widget.child,
            ),
            if (rippleAt != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(_rippleId),
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: adaptiveDuration(
                      context,
                      const Duration(milliseconds: 420),
                    ),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => CustomPaint(
                      painter: _RipplePainter(
                        center: rippleAt,
                        progress: t,
                        color: widget.rippleColor,
                      ),
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

class _RipplePainter extends CustomPainter {
  const _RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  final Offset center;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 6 + progress * math.max(size.width, size.height) * 0.55;
    final alpha = (1 - progress) * 0.16;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * (1 - progress) + 0.3
        ..color = color.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: alpha * 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.center != center;
}
