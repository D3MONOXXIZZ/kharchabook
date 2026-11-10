import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../auth/login_screen.dart';
import '../main_shell_screen.dart';
import '../../widgets/illustrations/editorial_student_splash_illustration.dart';

/// Screen S1: Illustrated Student Splash Screen.
/// Seamlessly supports both the OLED Dark Fintech and Editorial Pastel styles.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _checkSession();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    if (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    if (authProvider.isAuthenticated) {
      await expenseProvider.refreshData(authProvider.monthlyBudget);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Prominent Editorial Vector Character Illustration
                  const EditorialStudentSplashIllustration(
                    width: 290,
                    height: 240,
                  ),
                  const SizedBox(height: 20),

                  // 2. Monogram Badge
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.neonLime.withValues(alpha: 0.25)
                              : const Color(0x1A000000),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'KB',
                        style: TextStyle(
                          color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 3. App Title
                  Text(
                    'KharchaBook',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: isDark ? AppColors.textPrimary : AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 4. Subtitle
                  Text(
                    'Student Expense Manager',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondary : AppColors.slateMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 5. Academic Project Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.pastelLavender,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.inkBlack,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Student Budget & Expense Tracker',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 6. Minimalist Progress Indicator
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
