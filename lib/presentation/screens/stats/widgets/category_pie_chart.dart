import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/category_spending.dart';
import '../../../widgets/category_badge.dart';

/// Segmented multi-color Donut Ring directly modeled after the Redliodesigns "Saving Plans" screen.
class CategoryPieChart extends StatefulWidget {
  final List<CategorySpending> spendingList;

  const CategoryPieChart({
    super.key,
    required this.spendingList,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.spendingList.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'No expense data to analyze for this month',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final totalSpending = widget.spendingList.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );

    return Column(
      children: [
        // Donut Ring Container
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 65,
                  sections: widget.spendingList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isTouched = index == _touchedIndex;
                    final radius = isTouched ? 30.0 : 22.0;

                    return PieChartSectionData(
                      color: item.category.color,
                      value: item.totalAmount,
                      title: '',
                      radius: radius,
                    );
                  }).toList(),
                ),
              ),
              // Center Label (Redlio style)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touchedIndex >= 0 && _touchedIndex < widget.spendingList.length
                        ? widget.spendingList[_touchedIndex].category.name
                        : 'Total Outcome',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _touchedIndex >= 0 && _touchedIndex < widget.spendingList.length
                        ? CurrencyFormatter.format(widget.spendingList[_touchedIndex].totalAmount)
                        : CurrencyFormatter.format(totalSpending),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Student Ledger',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonLime,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Category Breakdown List with Progress Bars (Redlio style)
        ...widget.spendingList.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isTouched = index == _touchedIndex;
          final progress = (item.percentage / 100.0).clamp(0.0, 1.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isTouched
                  ? item.category.color.withValues(alpha: 0.12)
                  : AppColors.darkCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isTouched ? item.category.color : AppColors.darkBorder,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: item.category, size: 36, iconSize: 18),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(1)}% of spending',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.totalAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.darkCanvas,
                      valueColor: AlwaysStoppedAnimation<Color>(item.category.color),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
