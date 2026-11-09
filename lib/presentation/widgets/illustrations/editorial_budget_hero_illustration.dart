import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Self-contained editorial vector illustration for the Dashboard Yellow Hero Card.
/// Features student university budgeting: Student ID pass card, semester financial ledger,
/// pencil, coin jar, chai cup, and starburst sparkles.
class EditorialBudgetHeroIllustration extends StatelessWidget {
  final double size;

  const EditorialBudgetHeroIllustration({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BudgetIllustrationPainter(),
      ),
    );
  }
}

class _BudgetIllustrationPainter extends CustomPainter {
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

    final fillWhite = Paint()..color = Colors.white;
    final fillLavender = Paint()..color = AppColors.pastelLavender;
    final fillMint = Paint()..color = AppColors.pastelMint;
    final fillYellow = Paint()..color = AppColors.pastelYellowDark;

    // 1. Semester Ledger / Notebook (Tilted slightly on left)
    canvas.save();
    canvas.translate(w * 0.28, h * 0.58);
    canvas.rotate(-0.15); // gentle tilt
    final notebookRect = RRect.fromRectAndRadius(
      const Rect.fromLTRB(-25, -30, 25, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(notebookRect, fillWhite);
    canvas.drawRRect(notebookRect, ink..strokeWidth = 2.2);

    // Notebook grid lines
    for (double ly = -18; ly <= 18; ly += 9) {
      canvas.drawLine(Offset(-16, ly), Offset(16, ly), ink..strokeWidth = 1.2);
    }
    // Ribbon bookmark
    final ribbon = Path()
      ..moveTo(-4, -30)
      ..lineTo(-4, 0)
      ..lineTo(0, -4)
      ..lineTo(4, 0)
      ..lineTo(4, -30);
    canvas.drawPath(ribbon, fillLavender);
    canvas.drawPath(ribbon, ink..strokeWidth = 1.2);
    canvas.restore();

    // 2. Student ID Card (Right)
    final idCardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.32, 48, 56),
      const Radius.circular(8),
    );
    canvas.drawRRect(idCardRect, fillMint);
    canvas.drawRRect(idCardRect, ink..strokeWidth = 2.2);

    // Student ID photo avatar box
    final photoBox = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.50, h * 0.40, 20, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(photoBox, fillWhite);
    canvas.drawRRect(photoBox, ink..strokeWidth = 1.4);
    // Student silhouette
    canvas.drawCircle(Offset(w * 0.60, h * 0.48), 4, Paint()..color = AppColors.inkBlack);

    // ID Text lines
    canvas.drawLine(Offset(w * 0.50, h * 0.70), Offset(w * 0.84, h * 0.70), ink..strokeWidth = 1.4);
    canvas.drawLine(Offset(w * 0.50, h * 0.76), Offset(w * 0.76, h * 0.76), ink..strokeWidth = 1.4);

    // 3. Golden Allowance Coin with "Rs" floating top-center
    final coinCenter = Offset(w * 0.74, h * 0.24);
    canvas.drawCircle(coinCenter, 14, fillYellow);
    canvas.drawCircle(coinCenter, 14, ink..strokeWidth = 2.2);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Rs',
        style: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(coinCenter.dx - (textPainter.width / 2), coinCenter.dy - (textPainter.height / 2)));

    // 4. University Chai / Coffee Cup (Bottom Left)
    final cupRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.68, 22, 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(cupRect, fillLavender);
    canvas.drawRRect(cupRect, ink..strokeWidth = 1.8);
    // Cup handle
    final handle = Path()
      ..moveTo(w * 0.08, h * 0.72)
      ..arcToPoint(Offset(w * 0.08, h * 0.84), radius: const Radius.circular(6));
    canvas.drawPath(handle, ink..strokeWidth = 1.6);

    // 5. Starburst Sparkles
    _drawStar(canvas, Offset(w * 0.16, h * 0.28), 9, fillYellow, ink);
    _drawStar(canvas, Offset(w * 0.90, h * 0.60), 7, fillWhite, ink);
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
    canvas.drawPath(path, stroke..strokeWidth = 1.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
