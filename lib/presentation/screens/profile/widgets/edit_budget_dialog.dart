import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../widgets/custom_text_field.dart';

/// Dialog to adjust monthly budget limit with instant notification recalculation.
/// Fully theme-aware: adapts between OLED Dark and Editorial Pastel.
class EditBudgetDialog extends StatefulWidget {
  const EditBudgetDialog({super.key});

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _budgetController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentBudget = Provider.of<AuthProvider>(context, listen: false).monthlyBudget;
    _budgetController = TextEditingController(text: currentBudget.toInt().toString());
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newBudget = double.tryParse(_budgetController.text);
    if (newBudget == null || newBudget <= 0) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    final success = await auth.updateMonthlyBudget(newBudget);
    if (success && mounted) {
      await expenseProvider.refreshData(newBudget);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.inkBlack;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.slateMuted;
    final dialogBg = isDark ? AppColors.darkCardElevated : Colors.white;
    final presetBg = isDark ? AppColors.darkCard : AppColors.pastelCanvas;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.pastelBorder;
    final accentColor = isDark ? AppColors.neonLime : AppColors.inkBlack;

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Set Monthly Budget',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryTextColor),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your monthly pocket money or allowance limit. KharchaBook will notify you at 80% and 100% threshold.',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
            const SizedBox(height: AppDimensions.space16),
            CustomTextField(
              controller: _budgetController,
              label: 'Budget Amount (PKR)',
              hint: '15000',
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Enter a budget amount';
                }
                final num = double.tryParse(val);
                if (num == null || num <= 0) {
                  return 'Must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Quick Presets
            Wrap(
              spacing: 6,
              children: [10000, 15000, 20000, 25000].map((preset) {
                return GestureDetector(
                  onTap: () {
                    _budgetController.text = preset.toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: presetBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'Rs. ${preset ~/ 1000}k',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: isDark ? AppColors.darkCanvas : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Budget', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
