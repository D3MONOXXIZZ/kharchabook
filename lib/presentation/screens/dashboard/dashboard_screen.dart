import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/expense.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/editorial_hero_card.dart';
import 'widgets/weekly_calendar_strip.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/search_filter_bottom_sheet.dart';
import '../expense_form/add_edit_expense_screen.dart';
import '../profile/widgets/edit_budget_dialog.dart';
import '../../widgets/illustrations/editorial_empty_illustration.dart';

/// Screen S4: Student Expense Dashboard supporting dual themes:
/// 1. OLED Dark Neo-Fintech (Monex & Redlio style)
/// 2. Editorial Pastel Illustrated (Yellow Hero Card, Calendar Strip, and character illustrations)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showEditBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditBudgetDialog(),
    );
  }

  void _openFilterSheet(BuildContext context, ExpenseProvider expenseProvider, double budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFilterBottomSheet(
        categories: expenseProvider.categories,
        currentCategoryId: expenseProvider.selectedCategoryId,
        currentQuery: expenseProvider.searchQuery,
        onApply: (catId, query) {
          expenseProvider.setCategoryFilter(catId, budget);
          expenseProvider.setSearchQuery(query, budget);
        },
        onReset: () {
          expenseProvider.resetFilters(budget);
        },
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (final e in expenses) {
      final header = DateFormatter.formatRelativeHeader(e.date);
      grouped.putIfAbsent(header, () => []).add(e);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final studentName = auth.currentUser?.name ?? 'Zain Kashif';
    final budget = auth.monthlyBudget;
    final expenses = expenseProvider.expenses;
    final groupedExpenses = _groupExpensesByDate(expenses);

    final hasActiveFilters = expenseProvider.selectedCategoryId != null ||
        expenseProvider.searchQuery.isNotEmpty ||
        expenseProvider.selectedDay != null;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            // Student Profile Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCardElevated : AppColors.pastelYellow,
                border: Border.all(
                  color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  studentName.isNotEmpty ? studentName.substring(0, 1).toUpperCase() : 'Z',
                  style: TextStyle(
                    color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDark ? 'Assalam-o-Alaikum,' : 'Hi, $studentName',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
                Text(
                  studentName.isNotEmpty ? studentName : 'Student Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: isDark ? AppColors.textPrimary : AppColors.inkBlack,
                ),
                onPressed: () => _openFilterSheet(context, expenseProvider, budget),
              ),
              if (hasActiveFilters)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
            // If in Editorial Pastel Mode, show Bold Headline & Search Pill (Reference Screen 1)
            if (!isDark) ...[
              const SizedBox(height: 6),
              const Text(
                "Let's Track Now!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 12),

              // Search Bar Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.pastelBorder, width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 20, color: AppColors.slateMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 14, color: AppColors.inkBlack),
                        decoration: const InputDecoration(
                          hintText: 'Search semester expense...',
                          hintStyle: TextStyle(color: AppColors.slateLight, fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) => expenseProvider.setSearchQuery(val, budget),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.inkBlack),
                      onPressed: () => _openFilterSheet(context, expenseProvider, budget),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Horizontal Category Tags with Pill Badges (Matching Reference Screen 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildEditorialPill(
                      label: 'Cafeteria',
                      count: '12',
                      color: AppColors.pastelYellow,
                      onTap: () => expenseProvider.setCategoryFilter(1, budget),
                    ),
                    const SizedBox(width: 8),
                    _buildEditorialPill(
                      label: 'Academics',
                      count: '8',
                      color: AppColors.pastelLavender,
                      onTap: () => expenseProvider.setCategoryFilter(2, budget),
                    ),
                    const SizedBox(width: 8),
                    _buildEditorialPill(
                      label: 'Transport',
                      count: '5',
                      color: AppColors.pastelMint,
                      onTap: () => expenseProvider.setCategoryFilter(3, budget),
                    ),
                    const SizedBox(width: 8),
                    _buildEditorialPill(
                      label: 'Hostel',
                      count: '4',
                      color: AppColors.pastelCoral,
                      onTap: () => expenseProvider.setCategoryFilter(4, budget),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Editorial Yellow Hero Card with Character Illustration
              EditorialHeroCard(
                summary: expenseProvider.monthlySummary,
                onEditBudget: () => _showEditBudgetDialog(context),
                studentName: studentName,
              ),
              const SizedBox(height: 16),

              // Weekly Calendar Strip (Matching Reference Screen 3)
              WeeklyCalendarStrip(
                selectedMonth: expenseProvider.selectedMonth,
                selectedDay: expenseProvider.selectedDay,
                onDaySelected: (day) => expenseProvider.setSelectedDay(day),
                onPreviousWeek: () => expenseProvider.previousMonth(budget),
                onNextWeek: () => expenseProvider.nextMonth(budget),
              ),
              const SizedBox(height: 18),
            ] else ...[
              // In OLED Dark mode: show Monex Virtual Card
              BudgetProgressCard(
                summary: expenseProvider.monthlySummary,
                onEditBudget: () => _showEditBudgetDialog(context),
                studentName: studentName,
              ),
              const SizedBox(height: 18),

              // Filter Chips
              FilterChipsRow(
                selectedType: expenseProvider.selectedType,
                onTypeSelected: (type) => expenseProvider.setTypeFilter(type, budget),
                onOpenFilterSheet: () => _openFilterSheet(context, expenseProvider, budget),
                hasActiveFilters: hasActiveFilters,
              ),
              const SizedBox(height: 18),
            ],

            // Section Header for Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expenseProvider.selectedDay != null
                      ? 'Transactions for Selected Day'
                      : 'Transaction History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  '${expenses.length} entries',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Empty State
            if (expenses.isEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.pastelBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const EditorialEmptyIllustration(size: 90),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the + button below to log your daily student kharcha.',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => expenseProvider.resetFilters(budget),
                        child: Text(
                          'Clear Filters',
                          style: TextStyle(
                            color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Grouped Transaction List
              ...groupedExpenses.entries.expand((entry) {
                final dateHeader = entry.key;
                final list = entry.value;

                return [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 8.0, left: 4.0),
                    child: Text(
                      dateHeader,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: secondaryTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  ...list.map((expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TransactionTile(
                          expense: expense,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddEditExpenseScreen(existingExpense: expense),
                              ),
                            );
                          },
                          onDelete: () {
                            expenseProvider.deleteExpense(expense.id, budget);
                          },
                        ),
                      )),
                ];
              }),
            ],
            const SizedBox(height: 100), // padding for floating dock
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialPill({
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inkBlack, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inkBlack, width: 1.0),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.inkBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
