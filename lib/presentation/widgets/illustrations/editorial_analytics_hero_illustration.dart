import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Self-contained editorial vector illustration for the Analytics Hero Card.
/// Features university student financial discovery: magnifying glass examining academic savings,
/// 3D bar chart steps, student graduation cap, and starburst sparkles.
class EditorialAnalyticsHeroIllustration extends StatelessWidget {
  final double size;

  const EditorialAnalyticsHeroIllustration({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnalyticsIllustrationPainter(),
      ),
    );
  }
}

class _AnalyticsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final ink = Paint()
      ..color = AppColors.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillDeepPurple = Paint()..color = const Color(0xFF6B21A8); // Deep purple
    final fillMint = Paint()..color = AppColors.pastelMint;
    final fillYellow = Paint()..color = AppColors.pastelYellow;
    final fillWhite = Paint()..color = Colors.white;

    // 1. Upward Growth Bar Chart Blocks (Left/Center)
    // Bar 1 (Short - Mint)
    final bar1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.18, h * 0.32),
      const Radius.circular(6),
    );
    canvas.drawRRect(bar1, fillMint);
    canvas.drawRRect(bar1, ink..strokeWidth = 2.0);

    // Bar 2 (Medium - Yellow)
    final bar2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.33, h * 0.42, w * 0.18, h * 0.48),
      const Radius.circular(6),
    );
    canvas.drawRRect(bar2, fillYellow);
    canvas.drawRRect(bar2, ink..strokeWidth = 2.0);

    // Bar 3 (Tall - Deep Purple)
    final bar3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.54, h * 0.28, w * 0.20, h * 0.62),
      const Radius.circular(6),
    );
    canvas.drawRRect(bar3, fillDeepPurple);
    canvas.drawRRect(bar3, ink..strokeWidth = 2.0);

    // 2. Student Graduation Cap perched proudly on top of the tallest bar
    final capCenter = Offset(w * 0.64, h * 0.22);
    final capPath = Path()
      ..moveTo(capCenter.dx - 22, capCenter.dy)
      ..lineTo(capCenter.dx, capCenter.dy - 10)
      ..lineTo(capCenter.dx + 22, capCenter.dy)
      ..lineTo(capCenter.dx, capCenter.dy + 10)
      ..close();
    canvas.drawPath(capPath, Paint()..color = AppColors.inkBlack);
    canvas.drawPath(capPath, ink..strokeWidth = 2.0);

    // Cap button & tassel
    canvas.drawCircle(Offset(capCenter.dx, capCenter.dy - 10), 2.5, fillYellow);
    final tasselPath = Path()
      ..moveTo(capCenter.dx, capCenter.dy - 10)
      ..lineTo(capCenter.dx + 20, capCenter.dy + 4)
      ..lineTo(capCenter.dx + 20, capCenter.dy + 14);
    canvas.drawPath(tasselPath, ink..strokeWidth = 1.6);
    canvas.drawCircle(Offset(capCenter.dx + 20, capCenter.dy + 15), 2.5, fillYellow);

    // 3. Large Stylized Magnifying Glass examining the growth
    final glassCenter = Offset(w * 0.40, h * 0.38);
    final glassRadius = w * 0.26;

    // Glass White Lens with Thick Ink Rim
    canvas.drawCircle(glassCenter, glassRadius, fillWhite);
    canvas.drawCircle(glassCenter, glassRadius, ink..strokeWidth = 3.2);

    // Starburst (✦) glowing inside lens
    _drawStar(canvas, glassCenter, w * 0.14, fillYellow, ink);

    // Magnifying Glass Handle
    final handlePath = Path()
      ..moveTo(glassCenter.dx + glassRadius * 0.70, glassCenter.dy + glassRadius * 0.70)
      ..lineTo(w * 0.86, h * 0.84)
      ..lineTo(w * 0.78, h * 0.92)
      ..lineTo(glassCenter.dx + glassRadius * 0.55, glassCenter.dy + glassRadius * 0.85)
      ..close();
    canvas.drawPath(handlePath, fillDeepPurple);
    canvas.drawPath(handlePath, ink..strokeWidth = 2.0);

    // 4. Floating Sparkles around
    _drawMiniSpark(canvas, Offset(w * 0.15, h * 0.22), ink);
    _drawMiniSpark(canvas, Offset(w * 0.86, h * 0.45), ink);
  }

  void _drawStar(Canvas canvas, Offset center, double s, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - s)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke..strokeWidth = 1.8);
  }

  void _drawMiniSpark(Canvas canvas, Offset pos, Paint stroke) {
    canvas.drawLine(Offset(pos.dx, pos.dy - 4), Offset(pos.dx, pos.dy + 4), stroke..strokeWidth = 1.4);
    canvas.drawLine(Offset(pos.dx - 4, pos.dy), Offset(pos.dx + 4, pos.dy), stroke..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
