import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';

/// A Material 3 curved position indicator (scrollbar) calibrated for Wear OS.
///
/// Complies with Wear OS Quality Guidelines (WO-V8: Show the scrollbar):
/// - Draws a curved arc hugging the edge of circular watch screens.
/// - Falls back to a rounded straight bar on rectangular/square screens.
/// - Automatically fades in upon user interaction (touch or rotary crown).
/// - Fades out smoothly after a period of inactivity.
/// - Only renders when content actually exceeds the viewport.
class WearScrollbar extends StatefulWidget {
  const WearScrollbar({
    required this.child,
    this.controller,
    this.thumbColor = AppColors.emeraldLight,
    this.trackColor,
    this.thickness = 4.0,
    this.margin = 3.0,
    this.arcAngleDegrees = 72.0,
    this.autoHideDuration = const Duration(milliseconds: 1500),
    this.isRound = true,
    super.key,
  });

  /// The scrollable widget being wrapped.
  final Widget child;

  /// Optional [ScrollController] controlling the scrollable.
  ///
  /// If provided, listening directly to controller changes ensures instant
  /// response to rotary input events (crown/bezel) that use programmatic offsets.
  final ScrollController? controller;

  /// The color of the scroll indicator thumb.
  final Color thumbColor;

  /// The color of the underlying track (defaults to low-contrast outline).
  final Color? trackColor;

  /// Stroke width of the scrollbar arc / line.
  final double thickness;

  /// Distance from the edge of the circular display.
  final double margin;

  /// Total angular span of the track arc in degrees on round screens.
  final double arcAngleDegrees;

  /// How long the scrollbar remains visible after scrolling stops.
  final Duration autoHideDuration;

  /// Whether the target display is round. Defaults to true for Wear OS.
  final bool isRound;

  @override
  State<WearScrollbar> createState() => _WearScrollbarState();
}

class _WearScrollbarState extends State<WearScrollbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  double _scrollOffset = 0.0;
  double _maxScrollExtent = 0.0;
  double _viewportDimension = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    widget.controller?.addListener(_onControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onControllerChange();
    });
  }

  @override
  void didUpdateWidget(covariant WearScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onControllerChange(triggerShow: false);
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChange);
    _hideTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onControllerChange({bool triggerShow = true}) {
    final controller = widget.controller;
    if (controller != null && controller.hasClients) {
      final position = controller.position;
      _updateMetrics(
        offset: position.pixels,
        maxExtent: position.maxScrollExtent,
        viewport: position.viewportDimension,
        triggerShow: triggerShow,
      );
    }
  }

  void _updateMetrics({
    required double offset,
    required double maxExtent,
    required double viewport,
    bool triggerShow = true,
  }) {
    if (!mounted) return;

    final changed = _scrollOffset != offset ||
        _maxScrollExtent != maxExtent ||
        _viewportDimension != viewport;

    if (changed) {
      setState(() {
        _scrollOffset = offset;
        _maxScrollExtent = maxExtent;
        _viewportDimension = viewport;
      });
    }

    if (_maxScrollExtent > 0.0 && triggerShow) {
      _showAndScheduleHide();
    }
  }

  void _showAndScheduleHide() {
    _hideTimer?.cancel();
    if (_fadeController.status != AnimationStatus.forward &&
        _fadeController.value < 1.0) {
      _fadeController.forward();
    }

    _hideTimer = Timer(widget.autoHideDuration, () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      final metrics = notification.metrics;
      _updateMetrics(
        offset: metrics.pixels,
        maxExtent: metrics.maxScrollExtent,
        viewport: metrics.viewportDimension,
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTrackColor = widget.trackColor ??
        AppColors.darkOutline.withValues(alpha: 0.22);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (_maxScrollExtent > 0.0)
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  key: const ValueKey('wear_scrollbar_fade'),
                  opacity: _fadeAnimation,
                  child: CustomPaint(
                    painter: _WearScrollbarPainter(
                      offset: _scrollOffset,
                      maxExtent: _maxScrollExtent,
                      viewport: _viewportDimension,
                      thumbColor: widget.thumbColor,
                      trackColor: effectiveTrackColor,
                      thickness: widget.thickness,
                      margin: widget.margin,
                      arcAngleDegrees: widget.arcAngleDegrees,
                      isRound: widget.isRound,
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

class _WearScrollbarPainter extends CustomPainter {
  const _WearScrollbarPainter({
    required this.offset,
    required this.maxExtent,
    required this.viewport,
    required this.thumbColor,
    required this.trackColor,
    required this.thickness,
    required this.margin,
    required this.arcAngleDegrees,
    required this.isRound,
  });

  final double offset;
  final double maxExtent;
  final double viewport;
  final Color thumbColor;
  final Color trackColor;
  final double thickness;
  final double margin;
  final double arcAngleDegrees;
  final bool isRound;

  @override
  void paint(Canvas canvas, Size size) {
    if (maxExtent <= 0.0 || size.isEmpty) return;

    final scrollFraction = (offset / maxExtent).clamp(0.0, 1.0);
    final contentLength = maxExtent + viewport;
    final thumbProportion = (viewport / math.max(contentLength, 1.0))
        .clamp(0.12, 0.70);

    if (isRound) {
      _paintCircular(canvas, size, scrollFraction, thumbProportion);
    } else {
      _paintRectangular(canvas, size, scrollFraction, thumbProportion);
    }
  }

  void _paintCircular(
    Canvas canvas,
    Size size,
    double scrollFraction,
    double thumbProportion,
  ) {
    final side = math.min(size.width, size.height);
    final radius = (side / 2.0) - margin - (thickness / 2.0);
    if (radius <= 0) return;

    final center = Offset(size.width / 2.0, size.height / 2.0);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final trackSweepRad = arcAngleDegrees * (math.pi / 180.0);
    final trackStartRad = -(trackSweepRad / 2.0);

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, trackStartRad, trackSweepRad, false, trackPaint);

    // Thumb arc
    const minThumbAngle = 10.0 * (math.pi / 180.0);
    final thumbSweepRad = math.max(
      trackSweepRad * thumbProportion,
      minThumbAngle,
    );
    final availableAngle = math.max(0.0, trackSweepRad - thumbSweepRad);
    final thumbStartRad = trackStartRad + (scrollFraction * availableAngle);

    final thumbPaint = Paint()
      ..color = thumbColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, thumbStartRad, thumbSweepRad, false, thumbPaint);
  }

  void _paintRectangular(
    Canvas canvas,
    Size size,
    double scrollFraction,
    double thumbProportion,
  ) {
    final trackHeight = size.height * 0.45;
    final trackTop = (size.height - trackHeight) / 2.0;
    final rightX = size.width - margin - (thickness / 2.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(rightX, trackTop),
      Offset(rightX, trackTop + trackHeight),
      trackPaint,
    );

    const minThumbHeight = 14.0;
    final thumbHeight = math.max(trackHeight * thumbProportion, minThumbHeight);
    final availableTravel = math.max(0.0, trackHeight - thumbHeight);
    final thumbTop = trackTop + (scrollFraction * availableTravel);

    final thumbPaint = Paint()
      ..color = thumbColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(rightX, thumbTop),
      Offset(rightX, thumbTop + thumbHeight),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WearScrollbarPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.viewport != viewport ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.thickness != thickness ||
        oldDelegate.margin != margin ||
        oldDelegate.arcAngleDegrees != arcAngleDegrees ||
        oldDelegate.isRound != isRound;
  }
}
