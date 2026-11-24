import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_mark.dart';

/// Pull-to-refresh beridentitas Kedai Ummi.
///
/// Gestur & trigger tetap ditangani [RefreshIndicator.noSpinner] bawaan
/// Flutter, sehingga perilaku standar Android tidak rusak. Di atasnya kami
/// menambahkan chef hat yang mengikuti tarikan, ring emas, dan animasi
/// sukses setelah refresh selesai.
class KedaiRefreshIndicator extends StatefulWidget {
  const KedaiRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.semanticsLabel = 'Menyegarkan Kedai Ummi',
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final String semanticsLabel;

  @override
  State<KedaiRefreshIndicator> createState() => _KedaiRefreshIndicatorState();
}

class _KedaiRefreshIndicatorState extends State<KedaiRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  double _pull = 0;
  bool _refreshing = false;
  bool _success = false;
  bool? _reduceMotion;
  RefreshIndicatorStatus? _status;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce == _reduceMotion) return;
    _reduceMotion = reduce;
    if (reduce) {
      _spin.stop();
    } else if (_refreshing || _status == RefreshIndicatorStatus.refresh) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_reduceMotion ?? false) return;
    if (!_spin.isAnimating) _spin.repeat();
  }

  void _stopSpin() {
    if (_spin.isAnimating) _spin.stop();
  }

  bool _onScroll(ScrollNotification notification) {
    final status = _status;
    if (status != RefreshIndicatorStatus.drag &&
        status != RefreshIndicatorStatus.armed) {
      return false;
    }
    if (notification is OverscrollNotification &&
        notification.overscroll < 0 &&
        notification.metrics.pixels <=
            notification.metrics.minScrollExtent + 0.5) {
      final next = (_pull + (-notification.overscroll) / 110).clamp(0.0, 1.1);
      if ((next - _pull).abs() > 0.01) {
        setState(() => _pull = next);
      }
    }
    return false;
  }

  void _onStatus(RefreshIndicatorStatus? status) {
    if (status == null) return;
    if (status == _status) return;
    setState(() {
      _status = status;
      switch (status) {
        case RefreshIndicatorStatus.armed:
        case RefreshIndicatorStatus.refresh:
        case RefreshIndicatorStatus.snap:
          _pull = 1;
        case RefreshIndicatorStatus.canceled:
        case RefreshIndicatorStatus.done:
          _pull = 0;
        case RefreshIndicatorStatus.drag:
          break;
      }
    });
    if (status == RefreshIndicatorStatus.refresh) {
      _startSpin();
    } else if (status == RefreshIndicatorStatus.canceled ||
        status == RefreshIndicatorStatus.done) {
      _stopSpin();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _success = false;
    });
    _startSpin();
    final startedAt = DateTime.now();
    await widget.onRefresh();
    final elapsed = DateTime.now().difference(startedAt);
    const minimum = Duration(milliseconds: 520);
    if (elapsed < minimum) {
      await Future<void>.delayed(minimum - elapsed);
    }
    if (!mounted) return;
    _stopSpin();
    setState(() {
      _refreshing = false;
      _success = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (mounted) setState(() => _success = false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _pull > 0.02 || _refreshing || _success;
    final progress = _pull.clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          RefreshIndicator.noSpinner(
            onRefresh: _refresh,
            onStatusChange: _onStatus,
            semanticsLabel: widget.semanticsLabel,
            child: widget.child,
          ),
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: visible ? 1 : 0,
                child: AnimatedSlide(
                  duration: AppMotion.fast,
                  curve: AppMotion.standard,
                  offset: visible ? Offset.zero : const Offset(0, -0.8),
                  child: Center(
                    child: _ChefRefreshBubble(
                      progress: _success ? 1 : progress,
                      spin: _spin,
                      refreshing: _refreshing,
                      success: _success,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChefRefreshBubble extends StatelessWidget {
  const _ChefRefreshBubble({
    required this.progress,
    required this.spin,
    required this.refreshing,
    required this.success,
  });

  final double progress;
  final Animation<double> spin;
  final bool refreshing;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final scale = 0.7 + progress * 0.3;
    final accent = success ? AppColors.success : AppColors.gold;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.brown.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: spin,
              builder: (context, _) {
                return Transform.rotate(
                  angle: spin.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size.square(52),
                    painter: _RefreshRingPainter(
                      progress: progress,
                      color: accent,
                      spinning: refreshing && !success,
                    ),
                  ),
                );
              },
            ),
            AnimatedSwitcher(
              duration: AppMotion.normal,
              switchInCurve: AppMotion.overshoot,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: success
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey<String>('success'),
                      size: 22,
                      color: AppColors.success,
                    )
                  : Transform.rotate(
                      key: const ValueKey<String>('chef'),
                      angle: (1 - progress) * -0.16,
                      child: Transform.scale(
                        scale: 0.86 + progress * 0.14,
                        child: const ChefHatMark(size: 22),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshRingPainter extends CustomPainter {
  const _RefreshRingPainter({
    required this.progress,
    required this.color,
    required this.spinning,
  });

  final double progress;
  final Color color;
  final bool spinning;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    canvas.drawCircle(
      rect.center,
      rect.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.borderStrong.withValues(alpha: 0.4),
    );
    final sweep = spinning ? math.pi * 1.35 : math.pi * 1.5 * progress;
    if (sweep <= 0.05) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RefreshRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.spinning != spinning;
}
