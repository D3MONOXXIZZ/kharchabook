import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/monthly_budget_summary.dart';
import '../../domain/models/category_spending.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../core/services/notification_service.dart';

/// Provider orchestrating expense retrieval, filtering, creation, and budget tracking.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;

  List<Expense> _expenses = [];
  List<Category> _categories = [];
  MonthlyBudgetSummary? _monthlySummary;
  List<CategorySpending> _categorySpending = [];

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _selectedType = 'all'; // 'all' | 'expense' | 'income'

  bool _isLoading = false;
  String? _errorMessage;
  int _lastNotifiedThreshold = 0; // 0: none, 80: warning, 100: exceeded

  ExpenseProvider(this._expenseRepository) {
    loadInitialData(15000.0);
  }

  List<Expense> get expenses {
    if (_selectedDay == null) return _expenses;
    return _expenses.where((e) {
      return e.date.year == _selectedDay!.year &&
          e.date.month == _selectedDay!.month &&
          e.date.day == _selectedDay!.day;
    }).toList();
  }
  DateTime? get selectedDay => _selectedDay;
  List<Category> get categories => _categories;
  MonthlyBudgetSummary? get monthlySummary => _monthlySummary;
  List<CategorySpending> get categorySpending => _categorySpending;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitialData(double currentBudget) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _expenseRepository.getCategories();
      await refreshData(currentBudget);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData(double currentBudget) async {
    try {
      _expenses = await _expenseRepository.getExpenses(
        month: _selectedMonth,
        searchQuery: _searchQuery,
        categoryId: _selectedCategoryId,
        typeFilter: _selectedType,
      );

      _monthlySummary = await _expenseRepository.getMonthlySummary(
        month: _selectedMonth,
        monthlyBudget: currentBudget,
      );

      _categorySpending = await _expenseRepository.getCategorySpending(
        month: _selectedMonth,
      );

      // Check budget threshold notifications
      _checkThresholdAlert(currentBudget);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  void _checkThresholdAlert(double currentBudget) {
    if (_monthlySummary == null || currentBudget <= 0) return;

    final percent = _monthlySummary!.percentageUsed;

    if (percent >= 1.0 && _lastNotifiedThreshold < 100) {
      _lastNotifiedThreshold = 100;
      NotificationService.instance.showBudgetExceededNotification(
        spent: _monthlySummary!.totalExpense,
        budget: currentBudget,
      );
    } else if (percent >= 0.8 && percent < 1.0 && _lastNotifiedThreshold < 80) {
      _lastNotifiedThreshold = 80;
      NotificationService.instance.showBudgetWarningNotification(
        spent: _monthlySummary!.totalExpense,
        budget: currentBudget,
        percentage: (percent * 100).toInt(),
      );
    } else if (percent < 0.8) {
      _lastNotifiedThreshold = 0;
    }
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? note,
    required double currentBudget,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newExpense = Expense(
        id: '',
        userId: 'user_001',
        title: title.trim(),
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        createdAt: DateTime.now(),
      );

      await _expenseRepository.addExpense(newExpense);
      await refreshData(currentBudget);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateExpense({
    required Expense expense,
    required double currentBudget,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _expenseRepository.updateExpense(expense);
      await refreshData(currentBudget);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(String id, double currentBudget) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _expenseRepository.deleteExpense(id);
      await refreshData(currentBudget);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedMonth(DateTime month, double currentBudget) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    refreshData(currentBudget);
  }

  void nextMonth(double currentBudget) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    refreshData(currentBudget);
  }

  void previousMonth(double currentBudget) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    refreshData(currentBudget);
  }

  void setSearchQuery(String query, double currentBudget) {
    _searchQuery = query;
    refreshData(currentBudget);
  }

  void setCategoryFilter(int? categoryId, double currentBudget) {
    _selectedCategoryId = categoryId;
    refreshData(currentBudget);
  }

  void setTypeFilter(String type, double currentBudget) {
    _selectedType = type;
    refreshData(currentBudget);
  }

  void setSelectedDay(DateTime? day) {
    if (_selectedDay != null &&
        day != null &&
        _selectedDay!.year == day.year &&
        _selectedDay!.month == day.month &&
        _selectedDay!.day == day.day) {
      _selectedDay = null; // Toggle off to show full month
    } else {
      _selectedDay = day;
    }
    notifyListeners();
  }

  void resetFilters(double currentBudget) {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedType = 'all';
    _selectedDay = null;
    refreshData(currentBudget);
  }

  /// On-demand demo dataset populator for presentation/viva testing
  Future<void> seedDemoTransactions(double currentBudget) async {
    _isLoading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final y = now.year;
      final m = now.month;

      final sampleList = [
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Monthly Allowance from Home',
          amount: 15000.0,
          type: 'income',
          categoryId: 7,
          date: DateTime(y, m, 1),
          note: 'Sent via EasyPaisa',
          createdAt: DateTime(y, m, 1, 10, 0),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Hostel Mess Bill',
          amount: 4500.0,
          type: 'expense',
          categoryId: 3,
          date: DateTime(y, m, 2),
          note: 'Monthly mess share',
          createdAt: DateTime(y, m, 2, 12, 30),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Metro Card Monthly Recharge',
          amount: 1500.0,
          type: 'expense',
          categoryId: 2,
          date: DateTime(y, m, 3),
          note: 'Orange line transit pass',
          createdAt: DateTime(y, m, 3, 9, 15),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Semester Photocopy & Slides',
          amount: 450.0,
          type: 'expense',
          categoryId: 4,
          date: DateTime(y, m, 4),
          note: 'Campus photostat',
          createdAt: DateTime(y, m, 4, 14, 0),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Campus Lunch with Lab Group',
          amount: 380.0,
          type: 'expense',
          categoryId: 1,
          date: DateTime(y, m, 5),
          note: 'Biryani and drink',
          createdAt: DateTime(y, m, 5, 13, 45),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Freelance UI Design Gig',
          amount: 4000.0,
          type: 'income',
          categoryId: 8,
          date: DateTime(y, m, 9),
          note: 'Landing page wireframe',
          createdAt: DateTime(y, m, 9, 11, 0),
        ),
        Expense(
          id: '',
          userId: 'user_001',
          title: 'Dhaba Dinner with Roommates',
          amount: 720.0,
          type: 'expense',
          categoryId: 1,
          date: DateTime(y, m, 9),
          note: 'Dal chawal and karahi share',
          createdAt: DateTime(y, m, 9, 21, 30),
        ),
      ];

      for (final e in sampleList) {
        await _expenseRepository.addExpense(e);
      }
      await refreshData(currentBudget);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset all transactions to an empty clean slate
  Future<void> clearAllTransactions(double currentBudget) async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentList = List<Expense>.from(_expenses);
      for (final e in currentList) {
        await _expenseRepository.deleteExpense(e.id);
      }
      await refreshData(currentBudget);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
