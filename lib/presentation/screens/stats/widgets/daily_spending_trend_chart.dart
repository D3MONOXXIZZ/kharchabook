import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/expense.dart';

/// Dynamic spending trend chart calculating daily burn rate vs allowance pace.
/// Fully theme-aware: adapts seamlessly between OLED Dark and Editorial Pastel.
class DailySpendingTrendChart extends StatefulWidget {
  final List<Expense> expenses;
  final double monthlyBudget;
  final DateTime selectedMonth;

  const DailySpendingTrendChart({
    super.key,
    required this.expenses,
    required this.monthlyBudget,
    required this.selectedMonth,
  });

  @override
  State<DailySpendingTrendChart> createState() => _DailySpendingTrendChartState();
}

class _DailySpendingTrendChartState extends State<DailySpendingTrendChart> {
  bool _isWeeklyView = false;

  @override
  Widget build(BuildContext context) {
    final onlyExpenses = widget.expenses.where((e) => e.isExpense).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isWeeklyView) {
      return _buildWeeklyChart(context, onlyExpenses, isDark);
    } else {
      return _buildDailyChart(context, onlyExpenses, isDark);
    }
  }

  /// Weekly Aggregation (Week 1 to Week 4)
  Widget _buildWeeklyChart(BuildContext context, List<Expense> expenses, bool isDark) {
    final weeklyTarget = widget.monthlyBudget / 4.0;
    final List<double> weeklyTotals = [0.0, 0.0, 0.0, 0.0];

    for (final e in expenses) {
      final day = e.date.day;
      if (day <= 7) {
        weeklyTotals[0] += e.amount;
      } else if (day <= 14) {
        weeklyTotals[1] += e.amount;
      } else if (day <= 21) {
        weeklyTotals[2] += e.amount;
      } else {
        weeklyTotals[3] += e.amount;
      }
    }

    final maxVal = ([...weeklyTotals, weeklyTarget, 1000.0]
            .reduce((curr, next) => curr > next ? curr : next)) *
        1.25;

    final totalSpent = weeklyTotals.fold(0.0, (sum, val) => sum + val);
    final highestWeek = weeklyTotals.reduce((a, b) => a > b ? a : b);

    final normalBarColor = isDark ? AppColors.neonLime : const Color(0xFF8B5CF6);
    final overBarColor = isDark ? AppColors.expense : const Color(0xFFF43F5E);

    return _buildChartCard(
      context: context,
      isDark: isDark,
      title: 'WEEKLY OUTCOME VS PACE',
      statLabel1: 'Weekly Avg',
      statValue1: CurrencyFormatter.format(totalSpent / 4),
      statLabel2: 'Highest Week',
      statValue2: CurrencyFormatter.format(highestWeek),
      targetLabel: 'Target: ${CurrencyFormatter.format(weeklyTarget)}/wk',
      normalBarColor: normalBarColor,
      overBarColor: overBarColor,
      barGroups: List.generate(4, (index) {
        final amount = weeklyTotals[index];
        final isOver = amount > weeklyTarget && weeklyTarget > 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: isOver ? overBarColor : normalBarColor,
              width: 28,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ],
        );
      }),
      maxY: maxVal,
      targetY: weeklyTarget,
      bottomTitleBuilder: (value) {
        const labels = ['W1 (1-7)', 'W2 (8-14)', 'W3 (15-21)', 'W4 (22+)'];
        final idx = value.toInt();
        if (idx >= 0 && idx < labels.length) {
          return labels[idx];
        }
        return '';
      },
      tooltipBuilder: (index) {
        final labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        return '${labels[index]}\n${CurrencyFormatter.format(weeklyTotals[index])}';
      },
    );
  }

  /// Daily Aggregation (Monday to Sunday)
  Widget _buildDailyChart(BuildContext context, List<Expense> expenses, bool isDark) {
    final dailyTarget = widget.monthlyBudget / 30.0;
    final Map<int, double> weekdayTotals = {
      1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0,
    };

    for (final e in expenses) {
      final weekday = e.date.weekday;
      weekdayTotals[weekday] = (weekdayTotals[weekday] ?? 0.0) + e.amount;
    }

    final maxVal = ([...weekdayTotals.values, dailyTarget, 500.0]
            .reduce((curr, next) => curr > next ? curr : next)) *
        1.25;

    final totalSpent = weekdayTotals.values.fold(0.0, (sum, val) => sum + val);
    final highestDay = weekdayTotals.values.reduce((a, b) => a > b ? a : b);

    final normalBarColor = isDark ? AppColors.neonLime : const Color(0xFF8B5CF6);
    final overBarColor = isDark ? AppColors.expense : const Color(0xFFF43F5E);

    return _buildChartCard(
      context: context,
      isDark: isDark,
      title: 'DAILY OUTCOME BY WEEKDAY',
      statLabel1: 'Daily Avg',
      statValue1: CurrencyFormatter.format(totalSpent / 7),
      statLabel2: 'Peak Day',
      statValue2: CurrencyFormatter.format(highestDay),
      targetLabel: 'Limit: ${CurrencyFormatter.format(dailyTarget)}/day',
      normalBarColor: normalBarColor,
      overBarColor: overBarColor,
      barGroups: List.generate(7, (index) {
        final weekday = index + 1;
        final amount = weekdayTotals[weekday] ?? 0.0;
        final isOver = amount > dailyTarget && dailyTarget > 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: isOver ? overBarColor : normalBarColor,
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
      maxY: maxVal,
      targetY: dailyTarget,
      bottomTitleBuilder: (value) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final idx = value.toInt();
        if (idx >= 0 && idx < days.length) {
          return days[idx];
        }
        return '';
      },
      tooltipBuilder: (index) {
        const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final amount = weekdayTotals[index + 1] ?? 0.0;
        return '${days[index]}\n${CurrencyFormatter.format(amount)}';
      },
    );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String statLabel1,
    required String statValue1,
    required String statLabel2,
    required String statValue2,
    required String targetLabel,
    required Color normalBarColor,
    required Color overBarColor,
    required List<BarChartGroupData> barGroups,
    required double maxY,
    required double targetY,
    required String Function(double) bottomTitleBuilder,
    required String Function(int) tooltipBuilder,
  }) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: !isDark
            ? const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with View Toggle (Daily vs Weekly)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: secondaryTextColor,
                ),
              ),
              // Pill Toggle (Daily vs Weekly)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.pastelCanvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    _buildTogglePill('Daily', !_isWeeklyView, isDark, () {
                      setState(() => _isWeeklyView = false);
                    }),
                    _buildTogglePill('Weekly', _isWeeklyView, isDark, () {
                      setState(() => _isWeeklyView = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Key Stats Row (Avg, Peak, Target pace)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statLabel1,
                      style: TextStyle(fontSize: 11, color: secondaryTextColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statValue1,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryTextColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statLabel2,
                      style: TextStyle(fontSize: 11, color: secondaryTextColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statValue2,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: overBarColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neonLimeSoft : AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.neonLime.withValues(alpha: 0.3) : const Color(0xFF10B981),
                  ),
                ),
                child: Text(
                  targetLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neonLime : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart with Target Limit Indicator
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? AppColors.darkCardElevated : Colors.white,
                    tooltipBorder: BorderSide(
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      width: 1,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        tooltipBuilder(groupIndex),
                        TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            bottomTitleBuilder(value),
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: targetY > 0 ? targetY : 1000,
                  getDrawingHorizontalLine: (value) {
                    if ((value - targetY).abs() < 10) {
                      return FlLine(
                        color: (isDark ? AppColors.neonLime : AppColors.inkBlack).withValues(alpha: 0.5),
                        strokeWidth: 1.5,
                        dashArray: [4, 4],
                      );
                    }
                    return FlLine(
                      color: borderColor.withValues(alpha: 0.5),
                      strokeWidth: 0.8,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(normalBarColor, 'Within Safe Pace', secondaryTextColor),
              const SizedBox(width: 16),
              _buildLegendDot(overBarColor, 'Spike / Above Limit', secondaryTextColor),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: (isDark ? AppColors.neonLime : AppColors.inkBlack).withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text('Budget Line', style: TextStyle(fontSize: 10, color: secondaryTextColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePill(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? AppColors.darkCanvas : Colors.white)
                : (isDark ? AppColors.textSecondary : AppColors.slateMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }
}
