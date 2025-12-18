import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dart:math' as math;

class CertificateIllustration extends StatelessWidget {
  final bool isDarkMode;

  const CertificateIllustration({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 280),
      painter: CertificatePainter(isDarkMode: isDarkMode),
    );
  }
}

class CertificatePainter extends CustomPainter {
  final bool isDarkMode;

  CertificatePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    _drawSparkles(canvas, size);
    _drawCertificate(canvas, center);
    _drawBadge(canvas, center);
  }

  void _drawCertificate(Canvas canvas, Offset center) {
    final certWidth = 220.0;
    final certHeight = 160.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: certWidth, height: certHeight),
      const Radius.circular(16),
    );

    // Draw certificate background
    final bgPaint = Paint()
      ..color = isDarkMode 
          ? const Color(0xFF9575CD).withValues(alpha: 0.8) // Light purple in dark mode
          : const Color(0xFFE1BEE7); // Light purple in light mode
    canvas.drawRRect(rect, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(rect, borderPaint);

    // Draw decorative lines on certificate
    final linePaint = Paint()
      ..color = isDarkMode 
          ? Colors.white.withValues(alpha: 0.3)
          : AppColors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    final lineStart = center.dx - certWidth / 2 + 20;
    final lineWidth = certWidth - 40;
    
    for (var i = 0; i < 5; i++) {
      final y = center.dy - certHeight / 2 + 40 + (i * 20);
      canvas.drawLine(
        Offset(lineStart, y),
        Offset(lineStart + lineWidth, y),
        linePaint,
      );
    }

    // Draw signature/checkmark on the right
    _drawCheckmark(canvas, Offset(center.dx + certWidth / 3, center.dy - 10));
  }

  void _drawCheckmark(Canvas canvas, Offset position) {
    final checkPaint = Paint()
      ..color = isDarkMode ? Colors.white : AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(position.dx - 15, position.dy);
    path.lineTo(position.dx - 5, position.dy + 10);
    path.lineTo(position.dx + 15, position.dy - 10);
    
    canvas.drawPath(path, checkPaint);
  }

  void _drawBadge(Canvas canvas, Offset center) {
    final badgePosition = Offset(
      center.dx - 90,
      center.dy - 70,
    );

    // Draw ribbon
    final ribbonPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final ribbonPath = Path()
      ..moveTo(badgePosition.dx, badgePosition.dy)
      ..lineTo(badgePosition.dx + 35, badgePosition.dy)
      ..lineTo(badgePosition.dx + 30, badgePosition.dy + 40)
      ..lineTo(badgePosition.dx + 5, badgePosition.dy + 40)
      ..close();

    canvas.drawPath(ribbonPath, ribbonPaint);

    // Draw star emblem inside badge
    _drawStar(canvas, Offset(badgePosition.dx + 17.5, badgePosition.dy + 20), 8);
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const numberOfPoints = 8;
    
    for (var i = 0; i < numberOfPoints * 2; i++) {
      final angle = i * math.pi / numberOfPoints;
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, starPaint);
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Position sparkles above and to the right of certificate
    final positions = [
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.88, size.height * 0.25),
    ];

    for (final pos in positions) {
      _drawSparkle(canvas, pos, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    const size = 6.0;
    
    // Draw 4-pointed star
    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - (math.pi / 4);
      path.moveTo(
        position.dx + math.cos(angle) * size,
        position.dy + math.sin(angle) * size,
      );
      path.lineTo(position.dx, position.dy);
      path.moveTo(position.dx, position.dy);
      path.lineTo(
        position.dx + math.cos(angle + math.pi) * size,
        position.dy + math.sin(angle + math.pi) * size,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

