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

class _WearScrollViewState extends State<WearScrollView> {
  late WearScrollController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? WearScrollController();
    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (_controller.hasClients && _controller.position.maxScrollExtent > 0) {
      setState(() {
        _progress = _controller.offset / _controller.position.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _controller,
          padding: widget.padding,
          physics: const BouncingScrollPhysics(),
          child: widget.child,
        ),
        // Circular scroll indicator
        Positioned(
          right: 2,
          top: 0,
          bottom: 0,
          child: SizedBox(
            width: 2,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: _progress,
                color: widget.progressColor,
              ),
              size: const Size(2, double.infinity),
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
    super.dispose();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final trackPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      trackPaint,
    );

    // Progress indicator
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height * progress),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
