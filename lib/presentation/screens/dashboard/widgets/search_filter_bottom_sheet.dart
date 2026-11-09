import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/category.dart';

/// Modal bottom sheet for searching and filtering transactions.
/// Fully theme-aware: adapts between OLED Dark and Editorial Pastel.
class SearchFilterBottomSheet extends StatefulWidget {
  final List<Category> categories;
  final int? currentCategoryId;
  final String currentQuery;
  final void Function(int? categoryId, String query) onApply;
  final VoidCallback onReset;

  const SearchFilterBottomSheet({
    super.key,
    required this.categories,
    required this.currentCategoryId,
    required this.currentQuery,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late TextEditingController _searchController;
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentQuery);
    _selectedCategory = widget.currentCategoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final sheetBg = isDark ? AppColors.darkCardElevated : Colors.white;
    final inputBg = isDark ? AppColors.darkCard : AppColors.pastelCanvas;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final actionBtnBg = isDark ? AppColors.neonLime : AppColors.inkBlack;
    final actionBtnText = isDark ? AppColors.darkCanvas : Colors.white;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search & Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Keyword Input
            TextField(
              controller: _searchController,
              style: TextStyle(color: primaryTextColor, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                hintText: 'Search note or title...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textTertiary : AppColors.slateLight,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: actionBtnBg, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter by Category
            Text(
              'FILTER BY CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // "All Categories" chip
                GestureDetector(
                  onTap: () => setState(() => _selectedCategory = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategory == null ? actionBtnBg : inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedCategory == null ? actionBtnBg : borderColor,
                      ),
                    ),
                    child: Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedCategory == null ? actionBtnText : secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                ...widget.categories.map((cat) {
                  final isSelected = _selectedCategory == cat.id;

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = isSelected ? null : cat.id;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? actionBtnBg : inputBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? actionBtnBg : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.iconData,
                            size: 14,
                            color: isSelected ? actionBtnText : cat.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? actionBtnText : secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedCategory, _searchController.text.trim());
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionBtnBg,
                  foregroundColor: actionBtnText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
