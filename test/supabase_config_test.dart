import 'package:flutter_test/flutter_test.dart';
import 'package:kharchabook/core/config/supabase_config.dart';
import 'package:kharchabook/domain/models/category.dart';
import 'package:kharchabook/domain/models/expense.dart';
import 'package:kharchabook/domain/models/user_profile.dart';

void main() {
  group('Supabase Configuration & Serialization Tests', () {
    test('SupabaseConfig is correctly configured with live cloud credentials', () {
      expect(SupabaseConfig.isConfigured, isTrue);
      expect(SupabaseConfig.url, startsWith('https://'));
      expect(SupabaseConfig.url, contains('supabase.co'));
      expect(SupabaseConfig.anonKey.isNotEmpty, isTrue);
    });

    test('Expense.fromJson safely parses num and string formatted amounts', () {
      final jsonWithNum = {
        'id': 'exp_001',
        'user_id': 'user_001',
        'title': 'Campus Chai',
        'amount': 180.50,
        'type': 'expense',
        'category_id': 1,
        'date': '2026-11-10',
        'note': 'Evening chai',
        'created_at': '2026-11-10T08:00:00Z',
      };

      final expense1 = Expense.fromJson(jsonWithNum);
      expect(expense1.amount, 180.50);
      expect(expense1.isExpense, isTrue);
      expect(expense1.isIncome, isFalse);

      final jsonWithString = {
        'id': 'exp_002',
        'user_id': 'user_001',
        'title': 'Freelance Income',
        'amount': '4500.00',
        'type': 'income',
        'category_id': 8,
        'date': '2026-11-10',
        'created_at': '2026-11-10T08:00:00Z',
      };

      final expense2 = Expense.fromJson(jsonWithString);
      expect(expense2.amount, 4500.00);
      expect(expense2.isIncome, isTrue);
    });

    test('UserProfile.fromJson handles string and numeric budget', () {
      final json = {
        'id': 'usr_001',
        'name': 'Demo Student',
        'email': 'demo@kharchabook.app',
        'monthly_budget': '20000.00',
        'updated_at': '2026-11-10T08:00:00Z',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.monthlyBudget, 20000.0);
      expect(profile.name, 'Demo Student');
    });

    test('Category default presets contain essential student categories', () {
      final categories = Category.defaultCategories;
      expect(categories.length, greaterThanOrEqualTo(8));
      expect(categories.any((c) => c.name.contains('Food')), isTrue);
      expect(categories.any((c) => c.name.contains('Transport')), isTrue);
      expect(categories.any((c) => c.name.contains('Pocket Money')), isTrue);
    });
  });
}
