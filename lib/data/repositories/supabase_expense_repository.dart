import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/monthly_budget_summary.dart';
import '../../domain/models/category_spending.dart';
import '../../domain/repositories/expense_repository.dart';

/// Production expense repository communicating with Supabase PostgreSQL via PostgREST.
class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _client;

  SupabaseExpenseRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final res = await _client.from('categories').select().order('id', ascending: true);
      return (res as List).map((json) => Category.fromJson(json)).toList();
    } catch (_) {
      return Category.defaultCategories;
    }
  }

  @override
  Future<List<Expense>> getExpenses({
    DateTime? month,
    String? searchQuery,
    int? categoryId,
    String? typeFilter,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    var query = _client
        .from('expenses')
        .select('*, categories(*)')
        .eq('user_id', user.id);

    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      final startStr = "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-01";
      final endStr = "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}";

      query = query.gte('date', startStr).lte('date', endStr);
    }

    if (categoryId != null && categoryId > 0) {
      query = query.eq('category_id', categoryId);
    }

    if (typeFilter != null && typeFilter != 'all') {
      query = query.eq('type', typeFilter);
    }

    final res = await query.order('date', ascending: false).order('created_at', ascending: false);

    var list = (res as List).map((json) => Expense.fromJson(json)).toList();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((e) {
        final titleMatch = e.title.toLowerCase().contains(q);
        final noteMatch = e.note?.toLowerCase().contains(q) ?? false;
        final categoryMatch = e.category?.name.toLowerCase().contains(q) ?? false;
        return titleMatch || noteMatch || categoryMatch;
      }).toList();
    }

    return list;
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final jsonPayload = <String, dynamic>{
      'user_id': user.id,
      'title': expense.title,
      'amount': expense.amount,
      'type': expense.type,
      'category_id': expense.categoryId,
      'date': "${expense.date.year.toString().padLeft(4, '0')}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}",
      'note': expense.note,
    };
    if (expense.id.isNotEmpty && !expense.id.startsWith('temp_') && !expense.id.startsWith('mock_')) {
      jsonPayload['id'] = expense.id;
    }

    final res = await _client
        .from('expenses')
        .insert(jsonPayload)
        .select('*, categories(*)')
        .single();

    return Expense.fromJson(res);
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final payload = <String, dynamic>{
      'title': expense.title,
      'amount': expense.amount,
      'type': expense.type,
      'category_id': expense.categoryId,
      'date': "${expense.date.year.toString().padLeft(4, '0')}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}",
      'note': expense.note,
    };

    final res = await _client
        .from('expenses')
        .update(payload)
        .eq('id', expense.id)
        .select('*, categories(*)')
        .single();

    return Expense.fromJson(res);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  @override
  Future<MonthlyBudgetSummary> getMonthlySummary({
    required DateTime month,
    required double monthlyBudget,
  }) async {
    final expenses = await getExpenses(month: month);

    double income = 0.0;
    double expense = 0.0;

    for (final item in expenses) {
      if (item.isIncome) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    return MonthlyBudgetSummary(
      monthlyBudget: monthlyBudget,
      totalIncome: income,
      totalExpense: expense,
      month: month,
    );
  }

  @override
  Future<List<CategorySpending>> getCategorySpending({
    required DateTime month,
  }) async {
    final expenses = await getExpenses(month: month, typeFilter: 'expense');
    final categories = await getCategories();

    final Map<int, double> categorySums = {};
    double grandTotal = 0.0;

    for (final e in expenses) {
      categorySums[e.categoryId] = (categorySums[e.categoryId] ?? 0.0) + e.amount;
      grandTotal += e.amount;
    }

    final List<CategorySpending> results = [];
    categorySums.forEach((catId, total) {
      final category = categories.firstWhere(
        (c) => c.id == catId,
        orElse: () => Category(id: catId, name: 'Other', iconKey: 'more-horizontal'),
      );
      final pct = grandTotal > 0 ? (total / grandTotal) * 100.0 : 0.0;
      results.add(CategorySpending(
        category: category,
        totalAmount: total,
        percentage: pct,
      ));
    });

    results.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return results;
  }
}
