import 'package:flutter_test/flutter_test.dart';
import 'package:kharchabook/data/mock/mock_auth_repository.dart';
import 'package:kharchabook/data/mock/mock_expense_repository.dart';
import 'package:kharchabook/presentation/providers/auth_provider.dart';
import 'package:kharchabook/presentation/providers/expense_provider.dart';

void main() {
  group('KharchaBook End-to-End System Audit Tests', () {
    late MockAuthRepository authRepo;
    late MockExpenseRepository expenseRepo;
    late AuthProvider authProvider;
    late ExpenseProvider expenseProvider;

    setUp(() {
      authRepo = MockAuthRepository();
      expenseRepo = MockExpenseRepository(autoSeed: false);
      authProvider = AuthProvider(authRepo);
      expenseProvider = ExpenseProvider(expenseRepo);
    });

    test('Initial Clean State: Zero expenses and unauthenticated start', () async {
      await Future.delayed(const Duration(milliseconds: 150));
      expect(authProvider.isAuthenticated, isFalse);
      expect(expenseProvider.expenses, isEmpty);
    });

    test('User Authentication Flow: SignUp creates session and updates state', () async {
      final success = await authProvider.signUp('Audit Student', 'audit@student.edu', 'password123');
      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.name, 'Audit Student');
      expect(authProvider.currentUser?.email, 'audit@student.edu');
      expect(authProvider.monthlyBudget, 15000.0);
    });

    test('Transaction CRUD & State Sync: Add, Update, Filter, Delete', () async {
      // 1. Add Expense
      final addResult = await expenseProvider.addExpense(
        title: 'Cafeteria Lunch',
        amount: 450.0,
        type: 'expense',
        categoryId: 1,
        date: DateTime.now(),
        note: 'Biryani with cold drink',
        currentBudget: 15000.0,
      );
      expect(addResult, isTrue);
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.expenses.first.title, 'Cafeteria Lunch');
      expect(expenseProvider.expenses.first.amount, 450.0);

      // 2. Add Income
      await expenseProvider.addExpense(
        title: 'Monthly Allowance',
        amount: 15000.0,
        type: 'income',
        categoryId: 7,
        date: DateTime.now(),
        currentBudget: 15000.0,
      );
      expect(expenseProvider.expenses.length, 2);

      // 3. Verify Budget Summary
      expect(expenseProvider.monthlySummary?.totalExpense, 450.0);
      expect(expenseProvider.monthlySummary?.totalIncome, 15000.0);
      expect(expenseProvider.monthlySummary?.remainingBudget, 15000.0 - 450.0);

      // 4. Update Expense
      final firstExpense = expenseProvider.expenses.firstWhere((e) => e.isExpense);
      final updated = firstExpense.copyWith(amount: 550.0, note: 'Added extra roti');
      final updateResult = await expenseProvider.updateExpense(
        expense: updated,
        currentBudget: 15000.0,
      );
      expect(updateResult, isTrue);
      expect(expenseProvider.monthlySummary?.totalExpense, 550.0);

      // 5. Filter by Category
      await expenseProvider.setCategoryFilter(1, 15000.0);
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.expenses.first.title, 'Cafeteria Lunch');

      // 6. Reset Filters
      await expenseProvider.resetFilters(15000.0);
      expect(expenseProvider.expenses.length, 2);

      // 7. Delete Expense
      final deleteResult = await expenseProvider.deleteExpense(firstExpense.id, 15000.0);
      expect(deleteResult, isTrue);
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.monthlySummary?.totalExpense, 0.0);
    });

    test('Budget Threshold Calculations: 80% Warning and 100% Exceeded', () async {
      const budget = 1000.0;

      // Add expense below 80% (e.g. 500 = 50%)
      await expenseProvider.addExpense(
        title: 'Snack',
        amount: 500.0,
        type: 'expense',
        categoryId: 1,
        date: DateTime.now(),
        currentBudget: budget,
      );
      expect(expenseProvider.monthlySummary?.percentageUsed, 0.5);
      expect(expenseProvider.monthlySummary?.isExceeded, isFalse);

      // Add expense to cross 80% (500 + 350 = 850 = 85%)
      await expenseProvider.addExpense(
        title: 'Stationery',
        amount: 350.0,
        type: 'expense',
        categoryId: 4,
        date: DateTime.now(),
        currentBudget: budget,
      );
      expect(expenseProvider.monthlySummary?.percentageUsed, 0.85);
      expect(expenseProvider.monthlySummary?.isWarning, isTrue);
      expect(expenseProvider.monthlySummary?.isExceeded, isFalse);

      // Add expense to cross 100% (850 + 200 = 1050 = 105%)
      await expenseProvider.addExpense(
        title: 'Books',
        amount: 200.0,
        type: 'expense',
        categoryId: 4,
        date: DateTime.now(),
        currentBudget: budget,
      );
      expect(expenseProvider.monthlySummary?.percentageUsed, 1.05);
      expect(expenseProvider.monthlySummary?.isExceeded, isTrue);
    });

    test('Category Spending Distribution Calculation', () async {
      await expenseProvider.addExpense(
        title: 'Food 1',
        amount: 600.0,
        type: 'expense',
        categoryId: 1,
        date: DateTime.now(),
        currentBudget: 5000.0,
      );
      await expenseProvider.addExpense(
        title: 'Transport 1',
        amount: 400.0,
        type: 'expense',
        categoryId: 2,
        date: DateTime.now(),
        currentBudget: 5000.0,
      );

      final distribution = expenseProvider.categorySpending;
      expect(distribution.length, 2);

      final food = distribution.firstWhere((c) => c.category.id == 1);
      final transport = distribution.firstWhere((c) => c.category.id == 2);

      // Total = 1000. Food = 60%, Transport = 40%
      expect(food.totalAmount, 600.0);
      expect(food.percentage, 60.0);
      expect(transport.totalAmount, 400.0);
      expect(transport.percentage, 40.0);
    });

    test('Profile Budget Modification Updates Calculation', () async {
      await authProvider.signUp('Student', 'test@uni.edu', 'password');
      expect(authProvider.monthlyBudget, 15000.0);

      final updated = await authProvider.updateMonthlyBudget(20000.0);
      expect(updated, isTrue);
      expect(authProvider.monthlyBudget, 20000.0);
    });
  });
}
