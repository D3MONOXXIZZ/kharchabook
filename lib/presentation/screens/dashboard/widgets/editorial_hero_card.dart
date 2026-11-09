import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/monthly_budget_summary.dart';
import '../../../widgets/illustrations/editorial_budget_hero_illustration.dart';

/// Editorial Buttercup Yellow Hero Card directly modeled after the reference design.
/// Features bold typography, student university budgeting illustration, and clean unclipped layout.
class EditorialHeroCard extends StatelessWidget {
  final MonthlyBudgetSummary? summary;
  final VoidCallback onEditBudget;
  final String studentName;

  const EditorialHeroCard({
    super.key,
    required this.summary,
    required this.onEditBudget,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = summary?.remainingBudget ?? 15000.0;
    final totalExpense = summary?.totalExpense ?? 0.0;
    final budget = summary?.monthlyBudget ?? 15000.0;
    final percent = summary?.percentageUsed ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.pastelYellow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.inkBlack, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Content on Left, Illustration on Right
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
                        'Semester Budget',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Student Allowance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.inkBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(remaining),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.inkBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${(percent * 100).toInt()}% used • Spent: ${CurrencyFormatter.format(totalExpense)} of ${CurrencyFormatter.format(budget)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlackSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Dedicated unclipped vector illustration container
              const EditorialBudgetHeroIllustration(size: 100),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Row: Student Avatars & "Manage" Pill Button
          Row(
            children: [
              // Student avatar stack
              SizedBox(
                width: 60,
                height: 30,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildMiniAvatar('Z', AppColors.pastelLavender),
                    ),
                    Positioned(
                      left: 18,
                      child: _buildMiniAvatar('H', AppColors.pastelMint),
                    ),
                    Positioned(
                      left: 36,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.inkBlack,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // "Edit Budget" Pill button
              GestureDetector(
                onTap: onEditBudget,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.inkBlack, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Budget',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkBlack,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.inkBlack),
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

  Widget _buildMiniAvatar(String initial, Color bg) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.inkBlack,
          ),
        ),
      ),
    );
  }
}
