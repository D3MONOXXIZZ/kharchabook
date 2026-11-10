import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/mock/mock_auth_repository.dart';
import 'data/mock/mock_expense_repository.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_expense_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications service for budget threshold warnings
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
  } catch (_) {
    // Graceful fallback on non-supported platforms or web
  }

  AuthRepository authRepository = MockAuthRepository();
  ExpenseRepository expenseRepository = MockExpenseRepository();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.anonKey,
      );
      authRepository = SupabaseAuthRepository();
      expenseRepository = SupabaseExpenseRepository();
      debugPrint('KharchaBook: Supabase cloud backend successfully initialized.');
    } catch (e) {
      debugPrint('KharchaBook: Supabase init fallback to Mock repositories: $e');
      authRepository = MockAuthRepository();
      expenseRepository = MockExpenseRepository();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(expenseRepository),
        ),
      ],
      child: const KharchaBookApp(),
    ),
  );
}

class KharchaBookApp extends StatelessWidget {
  const KharchaBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Graceful fallback if ThemeProvider is omitted in isolated test harnesses
    ThemeMode mode = ThemeMode.dark;
    try {
      final themeProvider = Provider.of<ThemeProvider?>(context, listen: true);
      if (themeProvider != null) {
        mode = themeProvider.themeMode;
      }
    } catch (_) {}

    return MaterialApp(
      title: 'KharchaBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(), // Editorial Pastel light theme
      darkTheme: AppTheme.dark(), // OLED Obsidian Neo-fintech dark theme
      themeMode: mode,
      home: const SplashScreen(),
    );
  }
}
