import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../dashboard/widgets/search_filter_bottom_sheet.dart';
import '../dashboard/widgets/transaction_tile.dart';
import '../expense_form/add_edit_expense_screen.dart';
import '../../widgets/illustrations/editorial_empty_illustration.dart';

/// Screen S8: Dedicated Transaction Ledger & Activity Screen.
/// Supports both OLED Dark and Editorial Pastel themes.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _searchController.text = query;
        },
        onReset: () {
          expenseProvider.resetFilters(budget);
          _searchController.clear();
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
    final budget = auth.monthlyBudget;
    final expenses = expenseProvider.expenses;
    final groupedExpenses = _groupExpensesByDate(expenses);

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final elevatedBg = isDark ? AppColors.darkCardElevated : AppColors.pastelLavender.withValues(alpha: 0.3);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    // Compute totals for current filtered view
    double filteredIncome = 0;
    double filteredOutcome = 0;
    for (final e in expenses) {
      if (e.isIncome) {
        filteredIncome += e.amount;
      } else {
        filteredOutcome += e.amount;
      }
    }

    final hasActiveFilters = expenseProvider.selectedCategoryId != null ||
        expenseProvider.searchQuery.isNotEmpty ||
        expenseProvider.selectedType != 'all' ||
        expenseProvider.selectedDay != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      appBar: AppBar(
        title: Text(
          'Transaction Ledger',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: hasActiveFilters
                  ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                  : secondaryTextColor,
            ),
            tooltip: 'Filter options',
            onPressed: () => _openFilterSheet(context, expenseProvider, budget),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search merchant, note, or item...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textTertiary : AppColors.slateLight,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: secondaryTextColor,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: secondaryTextColor,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  expenseProvider.setSearchQuery('', budget);
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (val) {
                        setState(() {});
                        expenseProvider.setSearchQuery(val, budget);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter Pills (All / Outcome / Income)
                  Row(
                    children: [
                      _buildTypePill(
                        context,
                        label: 'All (${expenses.length})',
                        type: 'all',
                        currentType: expenseProvider.selectedType,
                        isDark: isDark,
                        onTap: () => expenseProvider.setTypeFilter('all', budget),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        context,
                        label: 'Outcome',
                        type: 'expense',
                        currentType: expenseProvider.selectedType,
                        isDark: isDark,
                        onTap: () => expenseProvider.setTypeFilter('expense', budget),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        context,
                        label: 'Income',
                        type: 'income',
                        currentType: expenseProvider.selectedType,
                        isDark: isDark,
                        onTap: () => expenseProvider.setTypeFilter('income', budget),
                      ),
                      if (hasActiveFilters) ...[
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            expenseProvider.resetFilters(budget);
                            _searchController.clear();
                          },
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary strip for current filtered view
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: elevatedBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(filteredOutcome),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 28, color: borderColor),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Received',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(filteredIncome),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.neonLime : const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 28, color: borderColor),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Entries',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${expenses.length}',
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
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // List of transactions or empty state
          if (expenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EditorialEmptyIllustration(size: 90),
                      const SizedBox(height: 16),
                      Text(
                        'No matching transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try clearing search filters or add a new entry with the + button below.',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (hasActiveFilters) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            expenseProvider.resetFilters(budget);
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset All Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
                            foregroundColor: isDark ? AppColors.neonLime : AppColors.inkBlack,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entries = groupedExpenses.entries.toList();
                    final entry = entries[index];
                    final dateHeader = entry.key;
                    final list = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0, bottom: 8.0, left: 4.0),
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
                        ...list.map(
                          (expense) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
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
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: groupedExpenses.length,
                ),
              ),
            ),

          // Bottom padding to avoid dock overlap
          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(
    BuildContext context, {
    required String label,
    required String type,
    required String currentType,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentType == type;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                : (isDark ? AppColors.darkBorder : AppColors.pastelBorder),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? (isDark ? AppColors.darkCanvas : Colors.white)
                : (isDark ? AppColors.textSecondary : AppColors.slateMuted),
          ),
        ),
      ),
    );
  }
}
