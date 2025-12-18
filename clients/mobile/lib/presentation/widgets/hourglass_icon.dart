import 'package:flutter/material.dart';

class HourglassIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color backgroundColor;

  const HourglassIcon({
    super.key,
    this.size = 100,
    this.color = Colors.white,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HourglassPainter(color: color, backgroundColor: backgroundColor),
    );
  }
}

class HourglassPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;

  HourglassPainter({
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the rounded rectangle background
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, strokePaint);

    // Draw the hourglass shape
    final path = Path();
    
    // Upper triangle
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.close();

    // Lower triangle
    path.moveTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.9);
    path.close();

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

