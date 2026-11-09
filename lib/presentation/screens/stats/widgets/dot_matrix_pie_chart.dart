import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/category_spending.dart';
import '../../../widgets/category_badge.dart';

/// Tactile Dot Matrix Circular Chart directly inspired by the user's reference image.
/// Renders a circular ring of discrete dots representing category proportions & budget progress.
/// Fully theme-aware: adapts to both OLED Dark and Editorial Pastel.
class DotMatrixPieChart extends StatefulWidget {
  final List<CategorySpending> spendingList;
  final double monthlyBudget;
  final double totalExpense;

  const DotMatrixPieChart({
    super.key,
    required this.spendingList,
    required this.monthlyBudget,
    required this.totalExpense,
  });

  @override
  State<DotMatrixPieChart> createState() => _DotMatrixPieChartState();
}

class _DotMatrixPieChartState extends State<DotMatrixPieChart> {
  int? _selectedCategoryIndex;
  bool _isBudgetScaleMode = false; // Toggle: Category Pie vs Budget Progress

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    if (widget.spendingList.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No expense data to display for this month',
          style: TextStyle(color: secondaryTextColor),
        ),
      );
    }

    final totalSpent = widget.totalExpense;
    final budget = widget.monthlyBudget;
    final budgetPct = budget > 0 ? (totalSpent / budget * 100).toInt() : 0;

    return Column(
      children: [
        // Mode Switcher Pill (Category Split vs Budget Consumed)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModePill(
              label: 'Category Pie',
              isSelected: !_isBudgetScaleMode,
              isDark: isDark,
              onTap: () => setState(() => _isBudgetScaleMode = false),
            ),
            const SizedBox(width: 8),
            _buildModePill(
              label: 'Budget Dial',
              isSelected: _isBudgetScaleMode,
              isDark: isDark,
              onTap: () => setState(() => _isBudgetScaleMode = true),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Main Dot Matrix Circular Chart
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Dot Matrix Canvas
                CustomPaint(
                  size: const Size(240, 240),
                  painter: _DotMatrixCanvasPainter(
                    spendingList: widget.spendingList,
                    totalSpent: totalSpent,
                    budget: budget,
                    isBudgetScaleMode: _isBudgetScaleMode,
                    selectedIndex: _selectedCategoryIndex,
                    totalDots: 44, // 44 discrete circular matrix dots
                    dotRadius: 4.5,
                    isDark: isDark,
                  ),
                ),

                // Center Metric Display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCategoryIndex != null
                          ? widget.spendingList[_selectedCategoryIndex!].category.name
                          : (_isBudgetScaleMode ? 'BUDGET CONSUMED' : 'TOTAL OUTCOME'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedCategoryIndex != null
                          ? CurrencyFormatter.format(widget.spendingList[_selectedCategoryIndex!].totalAmount)
                          : CurrencyFormatter.format(totalSpent),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neonLimeSoft : AppColors.pastelLavender,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.neonLime.withValues(alpha: 0.3)
                              : AppColors.inkBlack.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _selectedCategoryIndex != null
                            ? '${widget.spendingList[_selectedCategoryIndex!].percentage.toStringAsFixed(1)}% of total'
                            : '$budgetPct% of budget',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Mini Dot Matrix Rings Row
        if (widget.spendingList.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: !isDark
                  ? const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.spendingList.take(3).map((item) {
                final fraction = totalSpent > 0 ? (item.totalAmount / totalSpent) : 0.0;
                return _MiniDotRingWidget(
                  category: item.category,
                  amount: item.totalAmount,
                  fraction: fraction,
                  isDark: isDark,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Detailed Category Breakdown Rows with Matrix Progress
        ...widget.spendingList.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == _selectedCategoryIndex;
          final progress = (item.percentage / 100.0).clamp(0.0, 1.0);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = isSelected ? null : index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.category.color.withValues(alpha: isDark ? 0.15 : 0.12)
                    : cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? item.category.color : borderColor,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: !isDark && !isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(1)}% of outcome',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.totalAmount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dotted Progress Bar
                  _DottedProgressBar(
                    fraction: progress,
                    activeColor: item.category.color,
                    dotsCount: 22,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildModePill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? AppColors.neonLime : AppColors.inkBlack;
    final activeText = isDark ? AppColors.darkCanvas : Colors.white;
    final inactiveBg = isDark ? AppColors.darkCard : Colors.white;
    final inactiveText = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeBg : borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering discrete matrix dots arranged in a circular meter.
class _DotMatrixCanvasPainter extends CustomPainter {
  final List<CategorySpending> spendingList;
  final double totalSpent;
  final double budget;
  final bool isBudgetScaleMode;
  final int? selectedIndex;
  final int totalDots;
  final double dotRadius;
  final bool isDark;

  _DotMatrixCanvasPainter({
    required this.spendingList,
    required this.totalSpent,
    required this.budget,
    required this.isBudgetScaleMode,
    required this.selectedIndex,
    required this.totalDots,
    required this.dotRadius,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - dotRadius - 4;
    final inactiveDotColor = isDark ? const Color(0xFF232838) : const Color(0xFFE2E8F0);

    // Calculate dot colors
    final List<Color> dotColors = List.filled(totalDots, inactiveDotColor);

    if (isBudgetScaleMode) {
      final double progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
      final int activeDots = (progress * totalDots).round();

      for (int i = 0; i < totalDots; i++) {
        if (i < activeDots) {
          final frac = i / totalDots;
          if (frac < 0.65) {
            dotColors[i] = isDark ? AppColors.neonLime : const Color(0xFF10B981);
          } else if (frac < 0.85) {
            dotColors[i] = AppColors.warning;
          } else {
            dotColors[i] = AppColors.expense;
          }
        }
      }
    } else {
      if (totalSpent > 0 && spendingList.isNotEmpty) {
        int currentDot = 0;

        for (int i = 0; i < spendingList.length; i++) {
          final item = spendingList[i];
          int catDots = (item.percentage / 100.0 * totalDots).round();
          if (i == spendingList.length - 1) {
            catDots = totalDots - currentDot;
          }

          for (int d = 0; d < catDots && currentDot < totalDots; d++) {
            dotColors[currentDot] = (selectedIndex == null || selectedIndex == i)
                ? item.category.color
                : item.category.color.withValues(alpha: 0.2);
            currentDot++;
          }
        }
      }
    }

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw circular dots
    for (int i = 0; i < totalDots; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / totalDots);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final dotCenter = Offset(x, y);

      final color = dotColors[i];
      final isMuted = color == inactiveDotColor;

      paint.color = color;

      if (!isMuted) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.0);
        canvas.drawCircle(dotCenter, dotRadius, paint);
      } else {
        paint.maskFilter = null;
        canvas.drawCircle(dotCenter, dotRadius * 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotMatrixCanvasPainter oldDelegate) {
    return oldDelegate.totalSpent != totalSpent ||
        oldDelegate.isBudgetScaleMode != isBudgetScaleMode ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.spendingList != spendingList ||
        oldDelegate.isDark != isDark;
  }
}

/// Mini Circular Dot Matrix Ring
class _MiniDotRingWidget extends StatelessWidget {
  final dynamic category;
  final double amount;
  final double fraction;
  final bool isDark;

  const _MiniDotRingWidget({
    required this.category,
    required this.amount,
    required this.fraction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color as Color;
    final catIcon = category.iconData as IconData;
    final catName = category.name as String;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(64, 64),
                painter: _MiniDotMatrixPainter(
                  fraction: fraction,
                  activeColor: catColor,
                  totalDots: 18,
                  dotRadius: 2.5,
                  isDark: isDark,
                ),
              ),
              Icon(catIcon, size: 20, color: catColor),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          catName,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _MiniDotMatrixPainter extends CustomPainter {
  final double fraction;
  final Color activeColor;
  final int totalDots;
  final double dotRadius;
  final bool isDark;

  const _MiniDotMatrixPainter({
    required this.fraction,
    required this.activeColor,
    required this.totalDots,
    required this.dotRadius,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - dotRadius - 2;
    final activeCount = (fraction * totalDots).round().clamp(1, totalDots);
    final inactiveColor = isDark ? const Color(0xFF262C3A) : const Color(0xFFE2E8F0);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / totalDots);
      final pos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final isActive = i < activeCount;
      paint.color = isActive ? activeColor : inactiveColor;
      canvas.drawCircle(pos, isActive ? dotRadius : dotRadius * 0.75, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniDotMatrixPainter oldDelegate) => true;
}

/// Horizontal dotted progress bar for individual category cards.
class _DottedProgressBar extends StatelessWidget {
  final double fraction;
  final Color activeColor;
  final int dotsCount;
  final bool isDark;

  const _DottedProgressBar({
    required this.fraction,
    required this.activeColor,
    this.dotsCount = 20,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeDots = (fraction * dotsCount).round().clamp(1, dotsCount);
    final inactiveColor = isDark ? const Color(0xFF262C3A) : const Color(0xFFE2E8F0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(dotsCount, (index) {
        final isActive = index < activeDots;
        return Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
