import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dart:math' as math;

class OnboardingIllustration extends StatelessWidget {
  final bool isDarkMode;

  const OnboardingIllustration({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 280),
      painter: BooksAndGlassesPainter(isDarkMode: isDarkMode),
    );
  }
}

class BooksAndGlassesPainter extends CustomPainter {
  final bool isDarkMode;

  BooksAndGlassesPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background gradient circle
    final gradient = RadialGradient(
      colors: isDarkMode
          ? [AppColors.illustrationDarkStart, AppColors.illustrationDarkEnd]
          : [AppColors.illustrationLightStart, AppColors.illustrationLightEnd],
      center: Alignment.center,
      radius: 0.8,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);

    // Sparkles
    void drawSparkles(Canvas canvas, Size size) {
      final sparklePaint = Paint()
        ..color = isDarkMode
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.yellow.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      final positions = [
        Offset(size.width * 0.2, size.height * 0.15),
        Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.15, size.height * 0.7),
        Offset(size.width * 0.85, size.height * 0.8),
      ];

      for (var pos in positions) {
        drawStar(canvas, pos, 5, 5, sparklePaint);
      }
    }

    drawSparkles(canvas, size);

    // Books
    void drawBook(Canvas canvas, Offset position, Color color, double rotationAngle) {
      final bookWidth = size.width * 0.3;
      final bookHeight = size.height * 0.4;
      final bookThickness = size.width * 0.05;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotationAngle);

      // Book cover
      final coverPaint = Paint()..color = color;
      final coverPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(-bookWidth / 2, -bookHeight / 2, bookWidth, bookHeight),
            const Radius.circular(8)));
      canvas.drawPath(coverPath, coverPaint);

      // Book spine
      final spinePaint = Paint()..color = color.withValues(alpha: 0.8);
      final spinePath = Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(
                -bookWidth / 2 - bookThickness, -bookHeight / 2, bookThickness, bookHeight),
            const Radius.circular(4)));
      canvas.drawPath(spinePath, spinePaint);

      // Pages
      final pagePaint = Paint()..color = AppColors.white.withValues(alpha: 0.8);
      final pagePath = Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(-bookWidth / 2 + 5, -bookHeight / 2 + 5, bookWidth - 10,
                bookHeight - 10),
            const Radius.circular(4)));
      canvas.drawPath(pagePath, pagePaint);

      canvas.restore();
    }

    drawBook(canvas, Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.1),
        AppColors.bookRed, -math.pi / 12);
    drawBook(canvas, Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.1),
        AppColors.bookBlue, math.pi / 12);
    drawBook(canvas, Offset(center.dx - size.width * 0.05, center.dy - size.height * 0.1),
        AppColors.bookOrange, -math.pi / 24);
    drawBook(canvas, Offset(center.dx + size.width * 0.05, center.dy - size.height * 0.1),
        AppColors.bookBeige, math.pi / 24);

    // Glasses
    void drawGlasses(Canvas canvas, Offset position) {
      final framePaint = Paint()
        ..color = isDarkMode ? Colors.white : AppColors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final lensPaint = Paint()
        ..color = isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppColors.greyLight.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      final lensRadius = size.width * 0.1;
      final bridgeWidth = size.width * 0.08;

      // Left lens
      canvas.drawCircle(
          Offset(position.dx - lensRadius - bridgeWidth / 2, position.dy), lensRadius, lensPaint);
      canvas.drawCircle(
          Offset(position.dx - lensRadius - bridgeWidth / 2, position.dy), lensRadius, framePaint);

      // Right lens
      canvas.drawCircle(
          Offset(position.dx + lensRadius + bridgeWidth / 2, position.dy), lensRadius, lensPaint);
      canvas.drawCircle(
          Offset(position.dx + lensRadius + bridgeWidth / 2, position.dy), lensRadius, framePaint);

      // Bridge
      canvas.drawLine(Offset(position.dx - bridgeWidth / 2, position.dy),
          Offset(position.dx + bridgeWidth / 2, position.dy), framePaint);
    }

    drawGlasses(canvas, Offset(center.dx, center.dy - size.height * 0.25));
  }

  void drawStar(Canvas canvas, Offset center, int numPoints, double outerRadius, Paint paint) {
    final path = Path();
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < numPoints; i++) {
      final outerAngle = (i * 2 * math.pi / numPoints) - math.pi / 2;
      final innerAngle = ((i + 0.5) * 2 * math.pi / numPoints) - math.pi / 2;

      if (i == 0) {
        path.moveTo(center.dx + outerRadius * math.cos(outerAngle),
            center.dy + outerRadius * math.sin(outerAngle));
      } else {
        path.lineTo(center.dx + outerRadius * math.cos(outerAngle),
            center.dy + outerRadius * math.sin(outerAngle));
      }
      path.lineTo(center.dx + innerRadius * math.cos(innerAngle),
          center.dy + innerRadius * math.sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
