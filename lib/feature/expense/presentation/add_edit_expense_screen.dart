import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_constants.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/frosted_card.dart';
import '../domain/expense.dart';
import 'expense_viewmodel.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<ExpenseCategory> _selectedCategory = ValueNotifier<ExpenseCategory>(ExpenseCategory.food);
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.expense != null && widget.expense!.id.isNotEmpty;
    
    _titleController = TextEditingController(text: widget.expense?.title ?? "");
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toStringAsFixed(2) : "",
    );
    _descController = TextEditingController(text: widget.expense?.description ?? "");
    
    if (widget.expense != null) {
      _selectedDate.value = widget.expense!.date;
      _selectedCategory.value = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _selectedDate.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentTeal,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectedDate.value = picked;
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final description = _descController.text.trim();

    final now = DateTime.now();

    final newExpense = Expense(
      id: (widget.expense != null && widget.expense!.id.isNotEmpty)
          ? widget.expense!.id
          : const Uuid().v4(),
      title: title,
      amount: amount,
      date: _selectedDate.value,
      categoryIndex: _selectedCategory.value.index,
      description: description.isNotEmpty ? description : null,
      receiptImagePath: widget.expense?.receiptImagePath,
      createdAt: widget.expense?.createdAt ?? now,
      updatedAt: now,
    );

    final viewModel = ref.read(expenseProvider.notifier);
    if (_isEditing) {
      await viewModel.updateExpense(newExpense);
    } else {
      await viewModel.addExpense(newExpense);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = "Add Transaction";
    if (_isEditing) {
      titleText = "Edit Transaction";
    } else if (widget.expense != null) {
      titleText = "Review Scanned Receipt";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0D0D1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.margin, vertical: ScreenUtils.margin),
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "ENTER AMOUNT",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      "₹",
                      style: TextStyle(
                        color: AppColors.accentTeal,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(color: AppColors.border),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter an amount";
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return "Please enter a valid amount";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FrostedCard(
                  opacity: 0.1,
                  borderRadius: ScreenUtils.kBorderRadius,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (Merchant) input
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.storefront, color: AppColors.accentTeal, size: 20),
                          labelText: "Merchant / Title",
                          hintText: "Where did you spend?",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a merchant name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: ScreenUtils.spacingStander),
                      // Date Picker Box
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(ScreenUtils.cardCircularRadius),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.margin, vertical: ScreenUtils.margin),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(ScreenUtils.cardCircularRadius),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: AppColors.accentTeal),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Date",
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: ScreenUtils.fontTextSmall),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ValueListenableBuilder<DateTime>(
                                    valueListenable: _selectedDate,
                                    builder: (context, selectedDate, _) {
                                      return Text(
                                        DateFormat('MMM dd, yyyy').format(selectedDate),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtils.fontTextSmall,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtils.spacingStander),
                      // Description input
                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.description_outlined, color: AppColors.accentTeal, size: 20),
                          labelText: "Note (Optional)",
                          hintText: "Add items or comments...",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtils.spacingStander),
                // Category header
                Text(
                  "Select Category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtils.fontTextSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ScreenUtils.spacingControl),
                // Category grid/wrap selection
                ValueListenableBuilder<ExpenseCategory>(
                  valueListenable: _selectedCategory,
                  builder: (context, selectedCategory, _) {
                    return Wrap(
                      spacing: ScreenUtils.fieldSpace,
                      runSpacing: ScreenUtils.fieldSpace,
                      children: ExpenseCategory.values.map((cat) {
                        return CategoryChip(
                          category: cat,
                          isSelected: selectedCategory == cat,
                          onTap: () {
                            _selectedCategory.value = cat;
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 48),
                // Save Button
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(_isEditing ? "UPDATE TRANSACTION" : "SAVE TRANSACTION"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
