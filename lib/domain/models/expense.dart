import 'category.dart';

/// Represents a single income or expense transaction.
class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final int categoryId;
  final Category? category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? type,
    int? categoryId,
    Category? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json, {Category? resolvedCategory}) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      type: json['type'] as String,
      categoryId: json['category_id'] as int,
      category: resolvedCategory ??
          (json['categories'] != null
              ? Category.fromJson(json['categories'] as Map<String, dynamic>)
              : null),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
