import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'widgets/type_toggle_switch.dart';
import 'widgets/category_selector.dart';

/// Screen S5: Add or Edit Student Expense / Income.
/// Fully theme-aware: adapts between OLED Dark and Editorial Pastel.
class AddEditExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddEditExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  late String _type; // 'expense' | 'income'
  late int _selectedCategoryId;
  late DateTime _selectedDate;

  bool _isLoading = false;

  bool get isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    _type = expense?.type ?? 'expense';
    _selectedCategoryId = expense?.categoryId ?? 1; // Default to Food / Cafeteria
    _selectedDate = expense?.date ?? DateTime.now();

    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toInt().toString() : '',
    );
    _titleController = TextEditingController(text: expense?.title ?? '');
    _noteController = TextEditingController(text: expense?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String newType) {
    setState(() {
      _type = newType;
      if (_type == 'expense') {
        _selectedCategoryId = 1; // Food
      } else {
        _selectedCategoryId = 7; // Allowance
      }
    });
  }

  void _addQuickAmount(int addValue) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    final updated = current + addValue;
    setState(() {
      _amountController.text = updated.toInt().toString();
    });
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.neonLime,
                    onPrimary: AppColors.darkCanvas,
                    surface: AppColors.darkCard,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.inkBlack,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final budget = auth.monthlyBudget;

    bool success;
    if (isEditing) {
      final updated = widget.existingExpense!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      success = await expenseProvider.updateExpense(
        expense: updated,
        currentBudget: budget,
      );
    } else {
      success = await expenseProvider.addExpense(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
        note: _noteController.text.trim(),
        currentBudget: budget,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Entry?',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.inkBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently remove this transaction?',
          style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.slateMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.slateMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.deleteExpense(widget.existingExpense!.id, auth.monthlyBudget);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseProvider = context.watch<ExpenseProvider>();

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final pillBg = isDark ? AppColors.darkCardElevated : AppColors.pastelCanvas;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;

    final categories = expenseProvider.categories
        .where((c) => _type == 'income' ? c.isIncome : !c.isIncome)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.pastelCanvas,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaction' : 'Record Transaction',
          style: TextStyle(fontWeight: FontWeight.w800, color: primaryTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Segmented Control: Outcome vs Income
            TypeToggleSwitch(
              selectedType: _type,
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 20),

            // Big Numeric Hero Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: !isDark
                    ? const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    'AMOUNT (PKR)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rs.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _type == 'income'
                              ? (isDark ? AppColors.neonLime : const Color(0xFF047857))
                              : AppColors.expense,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          autofocus: !isEditing,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: _type == 'income'
                                ? (isDark ? AppColors.neonLime : const Color(0xFF047857))
                                : primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.textTertiary : AppColors.slateLight,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            final num = double.tryParse(val);
                            if (num == null || num <= 0) {
                              return 'Must be > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick amount increment buttons
                  Wrap(
                    spacing: 8,
                    children: [50, 100, 500, 1000].map((val) {
                      return GestureDetector(
                        onTap: () => _addQuickAmount(val),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '+Rs. $val',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title Field
            CustomTextField(
              controller: _titleController,
              label: 'Title / Description',
              hint: _type == 'expense' ? 'e.g. Mess bill, Metro fare' : 'e.g. Monthly pocket money',
              prefixIcon: Icons.edit_note_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Quick Title Presets
            if (_type == 'expense')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Mess bill', 'Metro fare', 'Chai & Cafe', 'Photostat', 'Biryani lunch']
                      .map((preset) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: GestureDetector(
                              onTap: () {
                                _titleController.text = preset;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  preset,
                                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 18),

            // Category Selection
            Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 10),
            CategorySelector(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (catId) {
                setState(() {
                  _selectedCategoryId = catId;
                });
              },
            ),
            const SizedBox(height: 20),

            // Date Picker Row
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: secondaryTextColor),
                        const SizedBox(width: 12),
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormatter.formatShortDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.neonLime : AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional Note
            CustomTextField(
              controller: _noteController,
              label: 'Note (Optional)',
              hint: 'Additional memo or description...',
              prefixIcon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            // Save CTA Button
            PrimaryButton(
              label: isEditing ? 'Save Changes' : 'Record Transaction',
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
