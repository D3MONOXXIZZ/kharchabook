import 'package:flutter/material.dart';
import '../../domain/models/category.dart';

/// Circular category icon avatar matching the Monex & Redlio design.
class CategoryBadge extends StatelessWidget {
  final Category category;
  final double size;
  final double iconSize;

  const CategoryBadge({
    super.key,
    required this.category,
    this.size = 44.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          category.iconData,
          color: catColor,
          size: iconSize,
        ),
      ),
    );
  }
}
