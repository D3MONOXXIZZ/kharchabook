import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean editorial illustration for empty state (No expenses/transactions recorded).
class EditorialEmptyIllustration extends StatelessWidget {
  final double size;

  const EditorialEmptyIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptyStatePainter(),
      ),
    );
  }
}

class _EmptyStatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final ink = Paint()
      ..color = AppColors.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillLavender = Paint()..color = AppColors.pastelLavender;
    final fillYellow = Paint()..color = AppColors.pastelYellow;
    final fillCoral = Paint()..color = AppColors.pastelCoral;
    final fillWhite = Paint()..color = Colors.white;

    // Background soft disk
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.42, fillLavender);
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.42, ink..strokeWidth = 1.8);

    // Cute Piggy Bank Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.52, height: h * 0.40);
    canvas.drawOval(bodyRect, fillCoral);
    canvas.drawOval(bodyRect, ink..strokeWidth = 2.0);

    // Piggy Snout
    final snoutRect = Rect.fromCenter(center: Offset(w * 0.28, h * 0.56), width: 14, height: 18);
    canvas.drawOval(snoutRect, fillWhite);
    canvas.drawOval(snoutRect, ink..strokeWidth = 1.6);
    canvas.drawCircle(Offset(w * 0.27, h * 0.55), 1.5, Paint()..color = AppColors.inkBlack);
    canvas.drawCircle(Offset(w * 0.27, h * 0.58), 1.5, Paint()..color = AppColors.inkBlack);

    // Eye
    canvas.drawCircle(Offset(w * 0.38, h * 0.48), 2.2, Paint()..color = AppColors.inkBlack);

    // Coin slot on top
    canvas.drawLine(Offset(w * 0.48, h * 0.38), Offset(w * 0.58, h * 0.38), ink..strokeWidth = 2.4);

    // Golden Coin dropping in
    canvas.drawCircle(Offset(w * 0.53, h * 0.28), 9, fillYellow);
    canvas.drawCircle(Offset(w * 0.53, h * 0.28), 9, ink..strokeWidth = 1.8);
    // Currency symbol inside coin
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Rs',
        style: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w * 0.53 - (textPainter.width / 2), h * 0.28 - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
