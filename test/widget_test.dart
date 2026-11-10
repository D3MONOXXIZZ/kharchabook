import 'package:flutter_test/flutter_test.dart';
import 'package:kharchabook/core/utils/currency_formatter.dart';
import 'package:kharchabook/data/mock/mock_auth_repository.dart';
import 'package:kharchabook/data/mock/mock_expense_repository.dart';
import 'package:kharchabook/main.dart';
import 'package:provider/provider.dart';
import 'package:kharchabook/presentation/providers/auth_provider.dart';
import 'package:kharchabook/presentation/providers/expense_provider.dart';
import 'package:kharchabook/presentation/providers/theme_provider.dart';

void main() {
  group('KharchaBook Unit & Widget Tests', () {
    test('CurrencyFormatter formats PKR correctly', () {
      expect(CurrencyFormatter.format(15000), 'Rs. 15,000');
      expect(CurrencyFormatter.formatSigned(450, isIncome: false), '-Rs. 450');
      expect(CurrencyFormatter.formatSigned(3000, isIncome: true), '+Rs. 3,000');
    });

    test('MockExpenseRepository starts empty and computes monthly summary correctly when data is added', () async {
      final repo = MockExpenseRepository();
      final initialExpenses = await repo.getExpenses();
      expect(initialExpenses, isEmpty);

      repo.seedDemoData();
      final now = DateTime.now();
      final summary = await repo.getMonthlySummary(month: now, monthlyBudget: 15000.0);

      expect(summary.monthlyBudget, 15000.0);
      expect(summary.totalIncome, greaterThan(0));
      expect(summary.totalExpense, greaterThan(0));
      expect(summary.remainingBudget, 15000.0 - summary.totalExpense);
    });

    testWidgets('App boots and renders Splash screen with branding', (WidgetTester tester) async {
      final authRepo = MockAuthRepository();
      final expenseRepo = MockExpenseRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(),
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(authRepo),
            ),
            ChangeNotifierProvider<ExpenseProvider>(
              create: (_) => ExpenseProvider(expenseRepo),
            ),
          ],
          child: const KharchaBookApp(),
        ),
      );

      // Verify splash screen elements exist immediately
      expect(find.text('KharchaBook'), findsOneWidget);
      expect(find.text('Student Expense Manager'), findsOneWidget);
      expect(find.text('KB'), findsOneWidget);

      // Advance virtual clock past the 2s splash session timer
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });
  });
}
