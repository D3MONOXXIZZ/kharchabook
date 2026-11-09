import '../models/category.dart';
import '../models/expense.dart';
import '../models/monthly_budget_summary.dart';
import '../models/category_spending.dart';

/// Abstract contract for expenses and financial retrieval.
abstract class ExpenseRepository {
  Future<List<Category>> getCategories();
  
  Future<List<Expense>> getExpenses({
    DateTime? month,
    String? searchQuery,
    int? categoryId,
    String? typeFilter, // 'all' | 'income' | 'expense'
  });

  Future<Expense> addExpense(Expense expense);

  Future<Expense> updateExpense(Expense expense);

  Future<void> deleteExpense(String id);

  Future<MonthlyBudgetSummary> getMonthlySummary({
    required DateTime month,
    required double monthlyBudget,
  });

  Future<List<CategorySpending>> getCategorySpending({
    required DateTime month,
  });
}
