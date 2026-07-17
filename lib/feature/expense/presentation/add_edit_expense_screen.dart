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
  
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
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
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      setState(() {
        _selectedDate = picked;
      });
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
      date: _selectedDate,
      categoryIndex: _selectedCategory.index,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                FrostedCard(
                  opacity: 0.1,
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (Merchant) input
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
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
                      const SizedBox(height: 16),
                      // Amount input
                      TextFormField(
                        controller: _amountController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          hintText: "0.00",
                          prefixText: "\$ ",
                          prefixStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter an amount";
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return "Please enter a valid amount greater than 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Picker Box
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Date",
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                              ),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.calendar_today, size: 16, color: AppColors.accentTeal),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description input
                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Note (Optional)",
                          hintText: "Add items or comments...",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Category header
                const Text(
                  "Select Category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Category grid/wrap selection
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ExpenseCategory.values.map((cat) {
                    return CategoryChip(
                      category: cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                // Save Button
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
