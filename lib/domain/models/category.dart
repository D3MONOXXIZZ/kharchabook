import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Category model representing income/expense classifications.
class Category {
  final int id;
  final String name;
  final String iconKey;
  final bool isIncome;

  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    this.isIncome = false,
  });

  IconData get iconData {
    switch (iconKey) {
      case 'utensils':
        return Icons.restaurant_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'home':
        return Icons.house_rounded;
      case 'book-open':
        return Icons.menu_book_rounded;
      case 'heart-pulse':
        return Icons.favorite_rounded;
      case 'film':
        return Icons.movie_filter_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'briefcase':
        return Icons.work_rounded;
      case 'more-horizontal':
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (iconKey) {
      case 'utensils':
        return AppColors.accentCoral;
      case 'bus':
        return AppColors.accentCyan;
      case 'home':
        return AppColors.accentLavender;
      case 'book-open':
        return AppColors.neonLime;
      case 'heart-pulse':
        return AppColors.expense;
      case 'film':
        return AppColors.accentPurple;
      case 'wallet':
        return AppColors.income;
      case 'briefcase':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      iconKey: json['icon'] as String? ?? 'more-horizontal',
      isIncome: json['is_income'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': iconKey,
      'is_income': isIncome,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Default student-oriented category presets
  static const List<Category> defaultCategories = [
    Category(id: 1, name: 'Food & Dining', iconKey: 'utensils', isIncome: false),
    Category(id: 2, name: 'Transport & Metro', iconKey: 'bus', isIncome: false),
    Category(id: 3, name: 'Hostel & Rent', iconKey: 'home', isIncome: false),
    Category(id: 4, name: 'Study & Photocopy', iconKey: 'book-open', isIncome: false),
    Category(id: 5, name: 'Health & Medical', iconKey: 'heart-pulse', isIncome: false),
    Category(id: 6, name: 'Entertainment & Cafe', iconKey: 'film', isIncome: false),
    Category(id: 7, name: 'Pocket Money / Allowance', iconKey: 'wallet', isIncome: true),
    Category(id: 8, name: 'Freelance / Part-time', iconKey: 'briefcase', isIncome: true),
    Category(id: 9, name: 'Other Expenses', iconKey: 'more-horizontal', isIncome: false),
  ];
}
