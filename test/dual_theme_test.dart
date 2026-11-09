import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharchabook/data/mock/mock_auth_repository.dart';
import 'package:kharchabook/data/mock/mock_expense_repository.dart';
import 'package:kharchabook/presentation/providers/auth_provider.dart';
import 'package:kharchabook/presentation/providers/expense_provider.dart';
import 'package:kharchabook/presentation/providers/theme_provider.dart';
import 'package:kharchabook/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:kharchabook/presentation/screens/dashboard/widgets/budget_progress_card.dart';
import 'package:kharchabook/presentation/screens/dashboard/widgets/editorial_hero_card.dart';
import 'package:kharchabook/presentation/screens/dashboard/widgets/weekly_calendar_strip.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Theme switching toggles between Dark Monex and Pastel Editorial', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    final authRepo = MockAuthRepository();
    final expenseRepo = MockExpenseRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(authRepo),
          ),
          ChangeNotifierProvider<ExpenseProvider>(
            create: (_) => ExpenseProvider(expenseRepo),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return MaterialApp(
              themeMode: theme.themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: const Scaffold(
                body: DashboardScreen(),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // In dark mode (default): BudgetProgressCard is visible
    expect(find.byType(BudgetProgressCard), findsOneWidget);
    expect(find.byType(EditorialHeroCard), findsNothing);

    // Switch to light theme (Editorial Pastel)
    await themeProvider.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();

    // In light mode: EditorialHeroCard & WeeklyCalendarStrip are visible
    expect(find.byType(EditorialHeroCard), findsOneWidget);
    expect(find.byType(WeeklyCalendarStrip), findsOneWidget);
    expect(find.text("Let's Track Now!"), findsOneWidget);
  });
}
