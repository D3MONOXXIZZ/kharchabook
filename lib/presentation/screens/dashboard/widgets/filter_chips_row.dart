import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Filter pills supporting both OLED Dark and Editorial Pastel themes.
class FilterChipsRow extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onOpenFilterSheet;
  final bool hasActiveFilters;

  const FilterChipsRow({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.onOpenFilterSheet,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeBg = isDark ? AppColors.neonLime : AppColors.inkBlack;
    final activeText = isDark ? AppColors.darkCanvas : Colors.white;
    final inactiveBg = isDark ? AppColors.darkCard : Colors.white;
    final inactiveText = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    Widget buildPill(String type, String label) {
      final isSelected = selectedType == type;

      return GestureDetector(
        onTap: () => onTypeSelected(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? activeBg : borderColor,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? activeText : inactiveText,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildPill('all', 'All'),
        const SizedBox(width: AppDimensions.space8),
        buildPill('expense', 'Outcome'),
        const SizedBox(width: AppDimensions.space8),
        buildPill('income', 'Income'),
        const Spacer(),
        // Filter tune button
        GestureDetector(
          onTap: onOpenFilterSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? (isDark ? AppColors.neonLimeSoft : AppColors.pastelLavender)
                  : inactiveBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: hasActiveFilters
                    ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                    : borderColor,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 14,
                  color: hasActiveFilters
                      ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                      : inactiveText,
                ),
                const SizedBox(width: 4),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: hasActiveFilters
                        ? (isDark ? AppColors.neonLime : AppColors.inkBlack)
                        : inactiveText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
