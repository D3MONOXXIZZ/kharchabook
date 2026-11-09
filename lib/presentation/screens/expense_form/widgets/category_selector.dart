import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/category.dart';

/// Category grid with theme-aware active borders and cards.
class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final selectedCardBg = isDark ? AppColors.darkCardElevated : AppColors.pastelLavender.withValues(alpha: 0.35);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final activeBorderColor = isDark ? AppColors.neonLime : AppColors.inkBlack;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = cat.id == selectedCategoryId;
        final color = cat.color;

        return InkWell(
          onTap: () => onCategorySelected(cat.id),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? selectedCardBg : cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? activeBorderColor : borderColor,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: !isDark && !isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat.iconData,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
