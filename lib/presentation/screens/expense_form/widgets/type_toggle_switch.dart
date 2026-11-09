import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Segmented control for toggling Outcome vs Income.
/// Fully theme-aware: adapts between OLED Dark and Editorial Pastel.
class TypeToggleSwitch extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const TypeToggleSwitch({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = selectedType == 'expense';

    final trackBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final inactiveText = isDark ? AppColors.textSecondary : AppColors.slateMuted;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: !isDark
            ? const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Outcome / Expense Pill
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('expense'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.expense : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 16,
                      color: isExpense ? Colors.white : inactiveText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Outcome',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isExpense ? Colors.white : inactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Income Pill
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('income'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isExpense
                      ? (isDark ? AppColors.neonLime : const Color(0xFF10B981))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: !isExpense
                          ? (isDark ? AppColors.darkCanvas : Colors.white)
                          : inactiveText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: !isExpense
                            ? (isDark ? AppColors.darkCanvas : Colors.white)
                            : inactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
