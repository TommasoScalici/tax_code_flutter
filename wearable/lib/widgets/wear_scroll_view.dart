import 'dart:math' as math;
import 'package:flutter/material.dart';

class WearScrollController extends ScrollController {
  final void Function(double)? onRotaryScroll;

  WearScrollController({this.onRotaryScroll});

  void handleRotaryScroll(double delta) {
    if (hasClients) {
      final currentOffset = offset;
      final newOffset = currentOffset + (delta * 20.0);
      animateTo(
        newOffset.clamp(0.0, position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      onRotaryScroll?.call(delta);
    }
  }
}

class WearScrollView extends StatefulWidget {
  final Widget child;
  final WearScrollController? controller;
  final Color progressColor;
  final EdgeInsetsGeometry? padding;

  const WearScrollView({
    super.key,
    required this.child,
    this.controller,
    this.progressColor = Colors.white,
    this.padding,
  });

  @override
  State<WearScrollView> createState() => _WearScrollViewState();
}

class _WearScrollViewState extends State<WearScrollView>
    with SingleTickerProviderStateMixin {
  late WearScrollController _controller;
  double _progress = 0.0;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? WearScrollController();
    _controller.addListener(_handleScroll);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handleScroll() {
    if (_controller.hasClients && _controller.position.maxScrollExtent > 0) {
      setState(() {
        _progress = _controller.offset / _controller.position.maxScrollExtent;
      });

      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _fadeController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _controller,
          padding: EdgeInsets.only(
            right: 8.0,
            left: widget.padding?.horizontal ?? 0,
            top: widget.padding?.vertical ?? 0,
            bottom: widget.padding?.vertical ?? 0,
          ),
          physics: const BouncingScrollPhysics(),
          child: widget.child,
        ),
        // Curved scrollbar
        Positioned(
          right: 2,
          top: 0,
          bottom: 0,
          child: FadeTransition(
            opacity: _fadeController,
            child: Center(
              child: SizedBox(
                height: 40, // Ridotta l'altezza della scrollbar
                width: 2,
                child: CustomPaint(
                  painter: CurvedScrollbarPainter(
                    progress: _progress,
                    color: widget.progressColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _fadeController.dispose();
    super.dispose();
  }
}

class CurvedScrollbarPainter extends CustomPainter {
  final double progress;
  final Color color;

  CurvedScrollbarPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;

    // Aumentata la curvatura
    final curveWidth = 4.0;

    // Path per la traccia di background (la barra completa)
    final trackPath = Path();
    for (var y = 0.0; y < height; y++) {
      final normalizedY = y / height;
      // Usa una funzione sinusoidale modificata per una curvatura più pronunciata
      final x = curveWidth * math.sin(normalizedY * math.pi);

      if (y == 0) {
        trackPath.moveTo(x, y);
      } else {
        trackPath.lineTo(x, y);
      }
    }

    // Disegna la traccia di background
    final trackPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(trackPath, trackPaint);

    // Disegna l'indicatore di posizione (un piccolo segmento che si muove)
    final indicatorPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Calcola la posizione dell'indicatore
    final indicatorPosition = progress * height;
    final indicatorLength =
        height * 0.15; // Lunghezza dell'indicatore (15% della barra)

    final indicatorPath = Path();
    for (var y = -indicatorLength / 2; y < indicatorLength / 2; y++) {
      final normalizedY = (indicatorPosition + y) / height;
      final x = curveWidth * math.sin(normalizedY * math.pi);

      if (y == -indicatorLength / 2) {
        indicatorPath.moveTo(x, indicatorPosition + y);
      } else {
        indicatorPath.lineTo(x, indicatorPosition + y);
      }
    }

    canvas.drawPath(indicatorPath, indicatorPaint);
  }

  @override
  bool shouldRepaint(CurvedScrollbarPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
