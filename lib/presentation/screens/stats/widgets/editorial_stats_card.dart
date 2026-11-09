import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/monthly_budget_summary.dart';
import '../../../widgets/illustrations/editorial_analytics_hero_illustration.dart';

/// Editorial Lavender Hero Card directly modeled after the center card in the reference design.
/// Features bold typography, student financial discovery illustration, and clean unclipped layout.
class EditorialStatsCard extends StatelessWidget {
  final MonthlyBudgetSummary? summary;
  final int transactionCount;

  const EditorialStatsCard({
    super.key,
    required this.summary,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = summary?.totalExpense ?? 0.0;
    final totalIncome = summary?.totalIncome ?? 0.0;
    final percent = summary?.percentageUsed ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.inkBlack, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag on left, Illustration on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inkBlack, width: 1.2),
                      ),
                      child: const Text(
                        'Academic Financial Health',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'From Budget to\nBreakthroughs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.inkBlack,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Outflow: ${CurrencyFormatter.format(totalExpense)} • Inflow: ${CurrencyFormatter.format(totalIncome)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlackSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Dedicated unclipped vector illustration container
              const EditorialAnalyticsHeroIllustration(size: 100),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Row: Entry Count & Budget Consumed Pills
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inkBlack, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.inkBlack),
                    const SizedBox(width: 4),
                    Text(
                      '$transactionCount Entries',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inkBlack, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_graph_rounded, size: 14, color: AppColors.inkBlack),
                    const SizedBox(width: 4),
                    Text(
                      '${(percent * 100).toInt()}% of Allowance',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
