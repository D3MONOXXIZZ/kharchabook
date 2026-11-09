import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import 'widgets/daily_spending_trend_chart.dart';
import 'widgets/dot_matrix_pie_chart.dart';
import 'widgets/editorial_stats_card.dart';

/// Screen S6: Visual Analytics Screen supporting dual themes.
/// Includes the Lavender Editorial Hero Card with magnifying glass illustration in light mode.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'All'; // 'All' | 'Income' | 'Outcome'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final budget = auth.monthlyBudget;
    final summary = expenseProvider.monthlySummary;
    final totalIncome = summary?.totalIncome ?? 0.0;
    final totalExpense = summary?.totalExpense ?? 0.0;
    final selectedMonth = expenseProvider.selectedMonth;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz_rounded, color: primaryTextColor),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        onRefresh: () => expenseProvider.refreshData(budget),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          children: [
            // In Editorial Pastel Light mode: Show Lavender Hero Card with Magnifying Glass Illustration
            if (!isDark) ...[
              EditorialStatsCard(
                summary: summary,
                transactionCount: expenseProvider.expenses.length,
              ),
              const SizedBox(height: 18),
            ],

            // Period Selector Pills
            Row(
              children: ['All', 'Income', 'Outcome'].map((tab) {
                final isSelected = _selectedPeriod == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedPeriod = tab);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                            : cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                              : borderColor,
                        ),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? (isDark ? AppColors.darkCanvas : Colors.white)
                              : secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Total Spend Header & Month Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total spend this month',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(totalExpense),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                // Month Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => expenseProvider.previousMonth(budget),
                        child: Icon(Icons.chevron_left_rounded, size: 20, color: secondaryTextColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          DateFormatter.formatMonthYear(selectedMonth),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                      ),
                      InkWell(
                        onTap: () => expenseProvider.nextMonth(budget),
                        child: Icon(Icons.chevron_right_rounded, size: 20, color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // High-Utility Dynamic Trend Chart
            DailySpendingTrendChart(
              expenses: expenseProvider.expenses,
              monthlyBudget: budget,
              selectedMonth: selectedMonth,
            ),
            const SizedBox(height: 16),

            // Dual Side-by-Side KPI Cards
            Row(
              children: [
                // Total Income Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.incomeSoft : AppColors.pastelMint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 18,
                            color: isDark ? AppColors.income : const Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          CurrencyFormatter.format(totalIncome),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Income',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Total Outcome Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.expenseSoft : AppColors.pastelCoral,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.credit_card_rounded,
                            size: 18,
                            color: isDark ? AppColors.expense : const Color(0xFFBE123C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          CurrencyFormatter.format(totalExpense),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Outcome',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentLavender.withValues(alpha: 0.12)
                    : AppColors.pastelLavender.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppColors.accentLavender.withValues(alpha: 0.25)
                      : AppColors.pastelLavenderDark,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Budget Health ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.accentLavender : AppColors.inkBlack,
                              ),
                            ),
                            Icon(
                              totalExpense <= budget ? Icons.check_circle_rounded : Icons.warning_rounded,
                              size: 14,
                              color: totalExpense <= budget ? AppColors.income : AppColors.expense,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalExpense <= budget
                              ? 'Spending is currently on track with monthly allowance.'
                              : 'Warning: monthly pocket money limit has been crossed!',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AppColors.accentLavender : AppColors.inkBlack,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Dot Matrix Circular Pie Chart & Category Plans
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  '${expenseProvider.categorySpending.length} categories',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dot Matrix Circle Chart
            DotMatrixPieChart(
              spendingList: expenseProvider.categorySpending,
              monthlyBudget: budget,
              totalExpense: totalExpense,
            ),
            const SizedBox(height: 100), // padding for floating dock
          ],
        ),
      ),
    );
  }
}
