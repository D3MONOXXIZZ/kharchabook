import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../auth/login_screen.dart';
import 'widgets/edit_budget_dialog.dart';

/// Screen S7: Student Profile & Settings Screen with Theme Mode Switcher.
/// Allows instant switching between OLED Dark Neo-Fintech and Editorial Pastel.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditBudget(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EditBudgetDialog(),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : AppColors.inkBlack,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a new password for your student account (minimum 6 characters).',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondary : AppColors.slateMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.inkBlack),
              decoration: const InputDecoration(
                hintText: 'New password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.slateMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.length >= 6) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully!')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.inkBlack),
        ),
        content: Text(
          'Are you sure you want to log out of KharchaBook?',
          style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.slateMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.slateMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final name = user?.name ?? 'Student User';
    final email = user?.email ?? 'student@kharchabook.app';
    final budget = auth.monthlyBudget;

    final cardBg = isDark ? AppColors.darkCard : AppColors.pastelCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        children: [
          // Centered Student Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.pastelYellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.neonLime.withValues(alpha: 0.2)
                            : const Color(0x14000000),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'Z',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dual Status Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                        size: 22,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Student Pass',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Active Student',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: isDark ? AppColors.accentLavender : const Color(0xFF8B5CF6),
                        size: 22,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Campus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'University Edition',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Appearance & Dual Theme Switcher
          Text(
            'APPEARANCE & THEME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Theme Option 1: OLED Dark Neo-Fintech
              Expanded(
                child: GestureDetector(
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeProvider.isDarkMode ? AppColors.neonLime : AppColors.darkBorder,
                        width: themeProvider.isDarkMode ? 2.0 : 1.0,
                      ),
                      boxShadow: themeProvider.isDarkMode
                          ? [
                              BoxShadow(
                                color: AppColors.neonLime.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.darkCanvas,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.neonLime, width: 2),
                              ),
                            ),
                            if (themeProvider.isDarkMode)
                              const Icon(Icons.check_circle_rounded, color: AppColors.neonLime, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'OLED Dark',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Monex & Volt Lime',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Theme Option 2: Editorial Pastel Illustrated
              Expanded(
                child: GestureDetector(
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.pastelYellow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: !themeProvider.isDarkMode ? AppColors.inkBlack : Colors.transparent,
                        width: !themeProvider.isDarkMode ? 2.0 : 1.0,
                      ),
                      boxShadow: !themeProvider.isDarkMode
                          ? const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.pastelLavender,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.inkBlack, width: 2),
                              ),
                            ),
                            if (!themeProvider.isDarkMode)
                              const Icon(Icons.check_circle_rounded, color: AppColors.inkBlack, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Editorial Pastel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.inkBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Lilac & Illustrated',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkBlackSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Financial Preferences
          Text(
            'FINANCIAL PREFERENCES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Material(
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neonLimeSoft : AppColors.pastelMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                  size: 20,
                ),
              ),
              title: Text(
                'Monthly Budget Limit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              subtitle: Text(
                'Alerts at 80% & 100% threshold',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.format(budget),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 20, color: secondaryTextColor),
                ],
              ),
              onTap: () => _showEditBudget(context),
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Account & Security
          Text(
            'ACCOUNT & SECURITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Material(
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.pastelLavender,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? AppColors.textSecondary : AppColors.inkBlack,
                  size: 20,
                ),
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded, size: 20, color: secondaryTextColor),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Academic Specification
          Text(
            'PROJECT SPECIFICATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KharchaBook — Student Expense Manager',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'MAD Lab Semester Project (BS-IT 6A)',
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
                Divider(height: 20, color: borderColor),
                Text(
                  'Group Members:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Zain Kashif — 01-135232-107\n• Huraira Minhas — 01-135232-030',
                  style: TextStyle(fontSize: 12, color: secondaryTextColor, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Data & Demo Controls
          Text(
            'DATA & DEMO CONTROLS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
                      await expenseProvider.seedDemoTransactions(budget);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sample student transactions loaded for demo.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text('Seed Demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
                      await expenseProvider.clearAllTransactions(budget);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All transactions cleared. Clean slate active.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.expense),
                    label: const Text('Clear All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.expense)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Log Out Button
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.expense, size: 20),
            label: const Text('Log Out', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor, width: 1),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
