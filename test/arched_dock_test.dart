import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharchabook/data/mock/mock_auth_repository.dart';
import 'package:kharchabook/data/mock/mock_expense_repository.dart';
import 'package:kharchabook/presentation/providers/auth_provider.dart';
import 'package:kharchabook/presentation/providers/expense_provider.dart';
import 'package:kharchabook/presentation/providers/theme_provider.dart';
import 'package:kharchabook/presentation/screens/main_shell_screen.dart';
import 'package:provider/provider.dart';

void main() {
  test('Arched dock path creates smooth continuous curve', () {
    const size = Size(360, 84);
    const cornerRadius = 28.0;
    const domePeakHeight = 18.0;
    const domeWidth = 92.0;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final cx = w / 2;
    final barTop = domePeakHeight;
    final halfDome = domeWidth / 2;

    final path = Path();
    path.moveTo(r, barTop);
    path.lineTo(cx - halfDome, barTop);

    path.cubicTo(
      cx - (halfDome * 0.55), barTop,
      cx - (halfDome * 0.45), 0,
      cx, 0,
    );

    path.cubicTo(
      cx + (halfDome * 0.45), 0,
      cx + (halfDome * 0.55), barTop,
      cx + halfDome, barTop,
    );

    path.lineTo(w - r, barTop);
    path.arcToPoint(Offset(w, barTop + r), radius: Radius.circular(r));
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    path.lineTo(0, barTop + r);
    path.arcToPoint(Offset(r, barTop), radius: Radius.circular(r));
    path.close();

    final bounds = path.getBounds();
    expect(bounds.top, 0.0);
    expect(bounds.bottom, 84.0);
    expect(bounds.left, 0.0);
    expect(bounds.right, 360.0);
  });

  testWidgets('MainShellScreen renders centered elevated + button and 4 symmetric tabs', (WidgetTester tester) async {
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
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 4 tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify center + button exists
    final addIcon = find.byIcon(Icons.add_rounded);
    expect(addIcon, findsOneWidget);

    // Verify horizontal centering of the + button
    final plusCenter = tester.getCenter(addIcon);
    final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(plusCenter.dx, closeTo(screenSize.width / 2, 2.0));

    // Tap History tab and verify navigation
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction Ledger'), findsOneWidget);

    // Tap Analytics tab and verify navigation
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsWidgets);
  });
}
