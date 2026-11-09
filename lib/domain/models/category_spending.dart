import 'category.dart';

/// Aggregation of spending within a single category for charting.
class CategorySpending {
  final Category category;
  final double totalAmount;
  final double percentage; // 0.0 to 100.0

  const CategorySpending({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}
