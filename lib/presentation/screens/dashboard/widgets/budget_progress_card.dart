import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/monthly_budget_summary.dart';

/// Neo-fintech Virtual Student Card displaying monthly budget, remaining funds, and status meter.
/// Directly inspired by the Monex & Redlio digital card designs.
class BudgetProgressCard extends StatelessWidget {
  final MonthlyBudgetSummary? summary;
  final VoidCallback? onEditBudget;
  final String studentName;

  const BudgetProgressCard({
    super.key,
    required this.summary,
    this.onEditBudget,
    this.studentName = 'Zain Kashif',
  });

  @override
  Widget build(BuildContext context) {
    final budget = summary?.monthlyBudget ?? 15000.0;
    final totalSpent = summary?.totalExpense ?? 0.0;
    final totalIncome = summary?.totalIncome ?? 0.0;
    final remaining = budget - totalSpent;
    final rawPercent = budget > 0 ? (totalSpent / budget) : 0.0;
    final progressClamp = rawPercent.clamp(0.0, 1.0);
    final percentDisplay = (rawPercent * 100).toInt();

    Color meterColor = AppColors.neonLime;
    String statusBadge = 'Safe';
    Color badgeColor = AppColors.neonLime;

    if (rawPercent >= 1.0) {
      meterColor = AppColors.expense;
      statusBadge = 'Budget Exceeded';
      badgeColor = AppColors.expense;
    } else if (rawPercent >= 0.8) {
      meterColor = AppColors.warning;
      statusBadge = '$percentDisplay% Spent';
      badgeColor = AppColors.warning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        // High-end dark metallic gradient (Monex style)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E2330),
            Color(0xFF12151E),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: University Tag & Contactless Chip Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkCanvas.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.darkBorder, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'BUIC IT-6A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEditBudget,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonLimeSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 12, color: AppColors.neonLime),
                      SizedBox(width: 4),
                      Text(
                        'Set Limit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonLime,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total Allowance Metric (Big Monex Typography)
          const Text(
            'Total Allowance',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(budget),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusBadge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Indicator Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.format(totalSpent)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                remaining >= 0
                    ? '${CurrencyFormatter.format(remaining)} left'
                    : '${CurrencyFormatter.format(remaining.abs())} over',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: remaining >= 0 ? AppColors.neonLime : AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: LinearProgressIndicator(
                value: progressClamp,
                backgroundColor: AppColors.darkCanvas,
                valueColor: AlwaysStoppedAnimation<Color>(meterColor),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Split Income vs Expense Footer Badges
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCanvas.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.income),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Income', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(CurrencyFormatter.format(totalIncome), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.income)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCanvas.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.expense),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Outcome', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(CurrencyFormatter.format(totalSpent), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.expense)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
