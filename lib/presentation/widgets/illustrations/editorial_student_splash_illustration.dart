import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-scene editorial vector illustration of a university student managing semester finances.
/// Features bold black ink outlines, striped sweater, study desk, textbooks, chai mug, and starbursts.
class EditorialStudentSplashIllustration extends StatelessWidget {
  final double width;
  final double height;

  const EditorialStudentSplashIllustration({
    super.key,
    this.width = 280,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EditorialSplashPainter(),
      ),
    );
  }
}

class _EditorialSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final inkPaint = Paint()
      ..color = AppColors.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillLavender = Paint()..color = AppColors.pastelLavender;
    final fillYellow = Paint()..color = AppColors.pastelYellow;
    final fillMint = Paint()..color = AppColors.pastelMint;
    final fillCoral = Paint()..color = AppColors.pastelCoral;
    final fillWhite = Paint()..color = Colors.white;

    // 1. Soft decorative background circle / blob in Lavender
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.9, height: h * 0.85),
      const Radius.circular(32),
    );
    canvas.drawRRect(bgRect, fillLavender);
    canvas.drawRRect(bgRect, inkPaint..strokeWidth = 2.2);

    // 2. Starburst sparkles (✦) in upper corners
    _drawStarburst(canvas, Offset(w * 0.16, h * 0.22), 12, fillYellow, inkPaint);
    _drawStarburst(canvas, Offset(w * 0.84, h * 0.26), 16, fillWhite, inkPaint);
    _drawStarburst(canvas, Offset(w * 0.22, h * 0.76), 9, fillMint, inkPaint);

    // 3. Desk surface line
    final deskY = h * 0.78;
    canvas.drawLine(Offset(w * 0.1, deskY), Offset(w * 0.9, deskY), inkPaint..strokeWidth = 2.5);

    // 4. Semester Textbooks Stack on desk (Left)
    final book1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, deskY - 14, 52, 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(book1, fillMint);
    canvas.drawRRect(book1, inkPaint..strokeWidth = 2.0);

    final book2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, deskY - 26, 46, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(book2, fillYellow);
    canvas.drawRRect(book2, inkPaint..strokeWidth = 2.0);

    // 5. University Chai Mug (Right)
    final mugRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.72, deskY - 28, 24, 28),
      const Radius.circular(5),
    );
    canvas.drawRRect(mugRect, fillCoral);
    canvas.drawRRect(mugRect, inkPaint..strokeWidth = 2.0);

    // Mug handle
    final handlePath = Path()
      ..moveTo(w * 0.72 + 24, deskY - 22)
      ..arcToPoint(Offset(w * 0.72 + 24, deskY - 10), radius: const Radius.circular(7));
    canvas.drawPath(handlePath, inkPaint..strokeWidth = 2.0);

    // Steam coils
    final steam = Path()
      ..moveTo(w * 0.72 + 8, deskY - 32)
      ..quadraticBezierTo(w * 0.72 + 5, deskY - 38, w * 0.72 + 9, deskY - 44);
    canvas.drawPath(steam, inkPaint..strokeWidth = 1.5);

    // 6. Student Torso & Striped Sweater (Center)
    final torsoPath = Path()
      ..moveTo(w * 0.36, deskY)
      ..lineTo(w * 0.38, h * 0.44)
      ..quadraticBezierTo(w * 0.5, h * 0.42, w * 0.62, h * 0.44)
      ..lineTo(w * 0.64, deskY)
      ..close();
    canvas.drawPath(torsoPath, fillYellow);
    canvas.drawPath(torsoPath, inkPaint..strokeWidth = 2.4);

    // Bold horizontal stripes on sweater
    for (double sy = h * 0.48; sy < deskY - 6; sy += 9) {
      canvas.drawLine(Offset(w * 0.375, sy), Offset(w * 0.625, sy), inkPaint..strokeWidth = 1.8);
    }

    // 7. Student Head, Glasses & Hair
    // Neck
    canvas.drawRect(Rect.fromLTWH(w * 0.47, h * 0.38, 16, 14), fillCoral);
    canvas.drawRect(Rect.fromLTWH(w * 0.47, h * 0.38, 16, 14), inkPaint..strokeWidth = 1.8);

    // Head Oval
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.32), width: 44, height: 48);
    canvas.drawOval(headRect, fillWhite);
    canvas.drawOval(headRect, inkPaint..strokeWidth = 2.4);

    // Trendy round glasses
    canvas.drawCircle(Offset(w * 0.46, h * 0.32), 7, fillYellow);
    canvas.drawCircle(Offset(w * 0.46, h * 0.32), 7, inkPaint..strokeWidth = 1.8);
    canvas.drawCircle(Offset(w * 0.54, h * 0.32), 7, fillYellow);
    canvas.drawCircle(Offset(w * 0.54, h * 0.32), 7, inkPaint..strokeWidth = 1.8);
    canvas.drawLine(Offset(w * 0.49, h * 0.32), Offset(w * 0.51, h * 0.32), inkPaint..strokeWidth = 1.8);

    // Hair bun / locks
    final hairPath = Path()
      ..moveTo(w * 0.42, h * 0.30)
      ..quadraticBezierTo(w * 0.42, h * 0.20, w * 0.50, h * 0.20)
      ..quadraticBezierTo(w * 0.58, h * 0.20, w * 0.58, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.26, w * 0.42, h * 0.30);
    canvas.drawPath(hairPath, Paint()..color = AppColors.inkBlack);

    // Top hair bun
    canvas.drawCircle(Offset(w * 0.50, h * 0.17), 10, Paint()..color = AppColors.inkBlack);

    // 8. Student Hands holding Laptop / Kharcha notebook
    final laptopRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, deskY - 14), width: 72, height: 26),
      const Radius.circular(4),
    );
    canvas.drawRRect(laptopRect, fillWhite);
    canvas.drawRRect(laptopRect, inkPaint..strokeWidth = 2.0);

    // Screen line on laptop
    canvas.drawLine(Offset(w * 0.40, deskY - 14), Offset(w * 0.60, deskY - 14), inkPaint..strokeWidth = 1.4);

    // Hands resting on laptop
    canvas.drawCircle(Offset(w * 0.37, deskY - 12), 6, fillCoral);
    canvas.drawCircle(Offset(w * 0.37, deskY - 12), 6, inkPaint..strokeWidth = 1.8);
    canvas.drawCircle(Offset(w * 0.63, deskY - 12), 6, fillCoral);
    canvas.drawCircle(Offset(w * 0.63, deskY - 12), 6, inkPaint..strokeWidth = 1.8);
  }

  void _drawStarburst(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke..strokeWidth = 1.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
