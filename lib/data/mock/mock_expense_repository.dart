import 'package:uuid/uuid.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/monthly_budget_summary.dart';
import '../../domain/models/category_spending.dart';
import '../../domain/repositories/expense_repository.dart';

/// In-memory mock repository seeded with authentic student expenses.
class MockExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];
  final List<Category> _categories = List.from(Category.defaultCategories);
  final Uuid _uuid = const Uuid();

  MockExpenseRepository({bool autoSeed = false}) {
    if (autoSeed) {
      seedDemoData();
    }
  }

  void seedDemoData() {
    _expenses.clear();
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;

    final categoriesMap = {for (var c in _categories) c.id: c};

    _expenses.addAll([
      Expense(
        id: 'mock_1',
        userId: 'user_001',
        title: 'Monthly Allowance from Home',
        amount: 15000.0,
        type: 'income',
        categoryId: 7,
        category: categoriesMap[7],
        date: DateTime(y, m, 1),
        note: 'Sent via EasyPaisa',
        createdAt: DateTime(y, m, 1, 10, 0),
      ),
      Expense(
        id: 'mock_2',
        userId: 'user_001',
        title: 'Hostel Mess Bill',
        amount: 4500.0,
        type: 'expense',
        categoryId: 3,
        category: categoriesMap[3],
        date: DateTime(y, m, 2),
        note: 'Monthly mess share',
        createdAt: DateTime(y, m, 2, 12, 30),
      ),
      Expense(
        id: 'mock_3',
        userId: 'user_001',
        title: 'Metro Card Monthly Recharge',
        amount: 1500.0,
        type: 'expense',
        categoryId: 2,
        category: categoriesMap[2],
        date: DateTime(y, m, 3),
        note: 'Orange line pass',
        createdAt: DateTime(y, m, 3, 9, 15),
      ),
      Expense(
        id: 'mock_4',
        userId: 'user_001',
        title: 'Semester Photocopy & Slides',
        amount: 450.0,
        type: 'expense',
        categoryId: 4,
        category: categoriesMap[4],
        date: DateTime(y, m, 4),
        note: 'Printed from campus shop',
        createdAt: DateTime(y, m, 4, 14, 0),
      ),
      Expense(
        id: 'mock_5',
        userId: 'user_001',
        title: 'Campus Lunch with Lab Group',
        amount: 380.0,
        type: 'expense',
        categoryId: 1,
        category: categoriesMap[1],
        date: DateTime(y, m, 5),
        note: 'Biryani and cold drink',
        createdAt: DateTime(y, m, 5, 13, 45),
      ),
      Expense(
        id: 'mock_6',
        userId: 'user_001',
        title: 'Stationery & Registers',
        amount: 320.0,
        type: 'expense',
        categoryId: 4,
        category: categoriesMap[4],
        date: DateTime(y, m, 6),
        note: 'Markers and registers',
        createdAt: DateTime(y, m, 6, 16, 20),
      ),
      Expense(
        id: 'mock_7',
        userId: 'user_001',
        title: 'Chai & Snacks at Canteen',
        amount: 180.0,
        type: 'expense',
        categoryId: 1,
        category: categoriesMap[1],
        date: DateTime(y, m, 7),
        note: 'Evening tea with classmates',
        createdAt: DateTime(y, m, 7, 18, 10),
      ),
      Expense(
        id: 'mock_8',
        userId: 'user_001',
        title: 'Pharmacy & Medicine',
        amount: 280.0,
        type: 'expense',
        categoryId: 5,
        category: categoriesMap[5],
        date: DateTime(y, m, 8),
        note: 'Panadol from pharmacy',
        createdAt: DateTime(y, m, 8, 20, 0),
      ),
      Expense(
        id: 'mock_9',
        userId: 'user_001',
        title: 'Freelance UI Design Gig',
        amount: 4000.0,
        type: 'income',
        categoryId: 8,
        category: categoriesMap[8],
        date: DateTime(y, m, 9),
        note: 'Landing page wireframe',
        createdAt: DateTime(y, m, 9, 11, 0),
      ),
      Expense(
        id: 'mock_10',
        userId: 'user_001',
        title: 'Dinner with Roommates',
        amount: 720.0,
        type: 'expense',
        categoryId: 1,
        category: categoriesMap[1],
        date: DateTime(y, m, 9),
        note: 'Dal chawal and karahi share',
        createdAt: DateTime(y, m, 9, 21, 30),
      ),
    ]);
  }

  void clearExpenses() {
    _expenses.clear();
  }

  @override
  Future<List<Category>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<Expense>> getExpenses({
    DateTime? month,
    String? searchQuery,
    int? categoryId,
    String? typeFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    var filtered = List<Expense>.from(_expenses);

    if (month != null) {
      filtered = filtered.where((e) {
        return e.date.year == month.year && e.date.month == month.month;
      }).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((e) {
        final titleMatch = e.title.toLowerCase().contains(q);
        final noteMatch = e.note?.toLowerCase().contains(q) ?? false;
        final categoryMatch = e.category?.name.toLowerCase().contains(q) ?? false;
        return titleMatch || noteMatch || categoryMatch;
      }).toList();
    }

    if (categoryId != null && categoryId > 0) {
      filtered = filtered.where((e) => e.categoryId == categoryId).toList();
    }

    if (typeFilter != null && typeFilter != 'all') {
      filtered = filtered.where((e) => e.type == typeFilter).toList();
    }

    // Sort descending by date, then createdAt
    filtered.sort((a, b) {
      final dateComp = b.date.compareTo(a.date);
      if (dateComp != 0) return dateComp;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final resolvedCat = expense.category ??
        _categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => _categories.first,
        );

    final newExpense = expense.copyWith(
      id: expense.id.isEmpty ? _uuid.v4() : expense.id,
      category: resolvedCat,
      createdAt: DateTime.now(),
    );

    _expenses.insert(0, newExpense);
    return newExpense;
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) {
      throw Exception('Expense not found.');
    }

    final resolvedCat = expense.category ??
        _categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => _categories.first,
        );

    final updated = expense.copyWith(category: resolvedCat);
    _expenses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _expenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<MonthlyBudgetSummary> getMonthlySummary({
    required DateTime month,
    required double monthlyBudget,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final monthExpenses = _expenses.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();

    double income = 0.0;
    double expense = 0.0;

    for (final item in monthExpenses) {
      if (item.isIncome) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    return MonthlyBudgetSummary(
      monthlyBudget: monthlyBudget,
      totalIncome: income,
      totalExpense: expense,
      month: month,
    );
  }

  @override
  Future<List<CategorySpending>> getCategorySpending({
    required DateTime month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final monthExpenses = _expenses.where((e) {
      return e.date.year == month.year &&
          e.date.month == month.month &&
          e.isExpense;
    }).toList();

    final Map<int, double> categorySums = {};
    double grandTotal = 0.0;

    for (final e in monthExpenses) {
      categorySums[e.categoryId] = (categorySums[e.categoryId] ?? 0.0) + e.amount;
      grandTotal += e.amount;
    }

    final List<CategorySpending> results = [];
    categorySums.forEach((catId, total) {
      final category = _categories.firstWhere(
        (c) => c.id == catId,
        orElse: () => Category(id: catId, name: 'Other', iconKey: 'more-horizontal'),
      );
      final pct = grandTotal > 0 ? (total / grandTotal) * 100.0 : 0.0;
      results.add(CategorySpending(
        category: category,
        totalAmount: total,
        percentage: pct,
      ));
    });

    results.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return results;
  }

  /// Interactive debug method to trigger 85% budget warning for viva/demo
  void pushToWarningThreshold(double currentBudget) {
    final targetExpense = currentBudget * 0.85;
    final currentSummary = _expenses
        .where((e) => e.isExpense)
        .fold(0.0, (sum, e) => sum + e.amount);
    final diff = targetExpense - currentSummary;
    if (diff > 0) {
      addExpense(Expense(
        id: _uuid.v4(),
        userId: 'user_bahria_001',
        title: 'Semester Registration Fee Share',
        amount: diff,
        type: 'expense',
        categoryId: 4,
        date: DateTime.now(),
        note: 'Generated for 85% warning threshold demo',
        createdAt: DateTime.now(),
      ));
    }
  }
}
