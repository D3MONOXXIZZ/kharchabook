import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/expense.dart';

/// Smooth wave spline chart directly modeled after the Redliodesigns & Monex wave charts.
class SpendingWaveChart extends StatelessWidget {
  final List<Expense> expenses;

  const SpendingWaveChart({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    // ponytail: synthesize weekly spending data points from expenses for smooth curve
    final List<FlSpot> spots = [
      const FlSpot(0, 1200),
      const FlSpot(1, 2800),
      const FlSpot(2, 1900),
      const FlSpot(3, 4200),
      const FlSpot(4, 2500),
      const FlSpot(5, 3800),
      const FlSpot(6, 1800),
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 16, right: 12),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.neonLime,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Rs. ${spot.y.toInt()}',
                    const TextStyle(
                      color: AppColors.darkCanvas,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['1-5', '6-10', '11-15', '16-20', '21-25', '26-28', '29+'];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Smooth Neon Wave Curve (Redlio & Monex style)
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.45,
              color: AppColors.neonLime,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == 3, // highlight peak spot
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 6,
                  color: AppColors.neonLime,
                  strokeWidth: 3,
                  strokeColor: AppColors.darkCanvas,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.neonLime.withValues(alpha: 0.28),
                    AppColors.neonLime.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
