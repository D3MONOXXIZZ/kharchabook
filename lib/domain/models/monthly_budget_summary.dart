/// Aggregated budget and spending statistics for a single month.
class MonthlyBudgetSummary {
  final double monthlyBudget;
  final double totalIncome;
  final double totalExpense;
  final DateTime month;

  const MonthlyBudgetSummary({
    required this.monthlyBudget,
    required this.totalIncome,
    required this.totalExpense,
    required this.month,
  });

  /// Net balance remaining = totalIncome - totalExpense (or budget based)
  double get netSavings => totalIncome - totalExpense;

  /// Remaining amount of monthly allowance: monthlyBudget - totalExpense
  double get remainingBudget => monthlyBudget - totalExpense;

  /// Fraction of budget consumed (0.0 to 1.0+)
  double get percentageUsed => monthlyBudget > 0 ? (totalExpense / monthlyBudget) : 0.0;

  /// Threshold warning status (>= 80% and < 100%)
  bool get isWarning => percentageUsed >= 0.80 && percentageUsed < 1.0;

  /// Threshold exceeded status (>= 100%)
  bool get isExceeded => percentageUsed >= 1.0;

  /// State classification
  BudgetStatus get status {
    if (isExceeded) return BudgetStatus.exceeded;
    if (isWarning) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }
}

enum BudgetStatus {
  safe,
  warning,
  exceeded,
}
