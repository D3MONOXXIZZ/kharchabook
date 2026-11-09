import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'stats/stats_screen.dart';
import 'transactions/transactions_screen.dart';
import 'profile/profile_screen.dart';
import 'expense_form/add_edit_expense_screen.dart';

/// Screen Shell: Floating arched bottom navigation dock matching reference design.
/// Seamlessly adapts to dual themes (OLED Dark & Editorial Pastel) with a centered elevated '+' button.
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatsScreen(),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditExpenseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dockBg = isDark ? AppColors.darkCardElevated : Colors.white;
    final dockBorder = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final plusBg = isDark ? AppColors.neonLime : AppColors.inkBlack;
    final plusIconColor = isDark ? AppColors.darkCanvas : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 12, top: 0),
          color: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
          child: SizedBox(
            height: 84,
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Arched background dock with custom dome curve
              Positioned.fill(
                child: CustomPaint(
                  painter: ArchedDockPainter(
                    backgroundColor: dockBg,
                    borderColor: dockBorder,
                    borderWidth: 1.2,
                    cornerRadius: 28.0,
                    domePeakHeight: 18.0,
                    domeWidth: 92.0,
                    isDark: isDark,
                  ),
                ),
              ),

              // 2. Symmetric 4 Navigation Items with center space
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  children: [
                    // Tab 0: Home / Wallet
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        icon: Icons.account_balance_wallet_outlined,
                        activeIcon: Icons.account_balance_wallet_rounded,
                        label: 'Home',
                        isDark: isDark,
                      ),
                    ),

                    // Tab 1: Analytics / Stats
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        icon: Icons.pie_chart_outline_rounded,
                        activeIcon: Icons.pie_chart_rounded,
                        label: 'Analytics',
                        isDark: isDark,
                      ),
                    ),

                    // Center spacer: Reserved for elevated center '+' button
                    const SizedBox(width: 68),

                    // Tab 2: Activity / History
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: 'History',
                        isDark: isDark,
                      ),
                    ),

                    // Tab 3: Profile / Settings
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Centered and Elevated Action Button
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _openAddExpense,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: plusBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.neonLime.withValues(alpha: 0.45)
                                : const Color(0x33000000),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: plusIconColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? AppColors.neonLime : AppColors.inkBlack;
    final inactiveColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws the floating dock with a raised dome in the exact horizontal center.
class ArchedDockPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double domePeakHeight;
  final double domeWidth;
  final bool isDark;

  const ArchedDockPainter({
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 1.2,
    this.cornerRadius = 28.0,
    this.domePeakHeight = 18.0,
    this.domeWidth = 92.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final cx = w / 2;
    final barTop = domePeakHeight;
    final halfDome = domeWidth / 2;

    final path = Path();
    path.moveTo(r, barTop);
    path.lineTo(cx - halfDome, barTop);

    // Continuous S-curve up to dome peak (cx, 0)
    path.cubicTo(
      cx - (halfDome * 0.55), barTop,
      cx - (halfDome * 0.45), 0,
      cx, 0,
    );

    // Continuous S-curve down from dome peak to (cx + halfDome, barTop)
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

    // Soft drop shadow
    final shadowPaint = Paint()
      ..color = isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0x18000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);

    // Solid dock background fill
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Dock outline border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ArchedDockPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.domePeakHeight != domePeakHeight ||
        oldDelegate.domeWidth != domeWidth ||
        oldDelegate.isDark != isDark;
  }
}
