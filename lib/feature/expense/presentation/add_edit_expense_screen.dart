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
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;

  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );
  final ValueNotifier<ExpenseCategory> _selectedCategory =
      ValueNotifier<ExpenseCategory>(ExpenseCategory.food);
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.expense != null && widget.expense!.id.isNotEmpty;

    _titleController = TextEditingController(text: widget.expense?.title ?? "");
    _amountController = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(2)
          : "",
    );
    _descController = TextEditingController(
      text: widget.expense?.description ?? "",
    );

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
      appBar: AppBar(title: Text(titleText)),
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
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.margin,
                vertical: ScreenUtils.margin,
              ),
              children: [
                if (widget.expense != null &&
                    widget.expense!.isScanFallback) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orangeAccent.withOpacity(0.15),
                          Colors.redAccent.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        ScreenUtils.kBorderRadius,
                      ),
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            size: 20,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "AI Offline / Limit Fallback",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Gemini is offline or limit was reached. Please verify and enter the transaction details manually.",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                          prefixIcon: Icon(
                            Icons.storefront,
                            color: AppColors.accentTeal,
                            size: 20,
                          ),
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
                      // Date Selector Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Date of Expense",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ValueListenableBuilder<DateTime>(
                              valueListenable: _selectedDate,
                              builder: (context, selectedDate, _) {
                                return Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(selectedDate),
                                  style: const TextStyle(
                                    color: AppColors.accentTeal,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Quick Date Selector Presets
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDate,
                        builder: (context, selectedDate, _) {
                          final today = DateTime.now();
                          final yesterday = today.subtract(
                            const Duration(days: 1),
                          );

                          final isToday = DateUtils.isSameDay(
                            selectedDate,
                            today,
                          );
                          final isYesterday = DateUtils.isSameDay(
                            selectedDate,
                            yesterday,
                          );
                          final isCustom = !isToday && !isYesterday;

                          return Row(
                            children: [
                              Expanded(
                                child: _buildDateQuickChip(
                                  label: "Today",
                                  isSelected: isToday,
                                  onTap: () {
                                    _selectedDate.value = DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDateQuickChip(
                                  label: "Yesterday",
                                  isSelected: isYesterday,
                                  onTap: () {
                                    _selectedDate.value = DateTime(
                                      yesterday.year,
                                      yesterday.month,
                                      yesterday.day,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDateQuickChip(
                                  label: isCustom
                                      ? DateFormat(
                                          'MMM dd',
                                        ).format(selectedDate)
                                      : "Choose...",
                                  isSelected: isCustom,
                                  icon: Icons.calendar_month_rounded,
                                  onTap: _pickDate,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: ScreenUtils.spacingStander),
                      // Description input
                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            color: AppColors.accentTeal,
                            size: 20,
                          ),
                          labelText: "Note (Optional)",
                          hintText: "Add items or comments...",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtils.spacingStander),
                // Category header
                const Text(
                  "Select Category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Category grid selection
                ValueListenableBuilder<ExpenseCategory>(
                  valueListenable: _selectedCategory,
                  builder: (context, selectedCategory, _) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.05,
                          ),
                      itemCount: ExpenseCategory.values.length,
                      itemBuilder: (context, index) {
                        final cat = ExpenseCategory.values[index];
                        return _buildCategoryGridCard(
                          category: cat,
                          isSelected: selectedCategory == cat,
                          onTap: () {
                            _selectedCategory.value = cat;
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 36),
                // Premium Linear Gradient Save Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentTeal, AppColors.accentPurple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentTeal.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEditing ? "UPDATE TRANSACTION" : "SAVE TRANSACTION",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateQuickChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accentTeal.withOpacity(0.12)
            : AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.accentTeal
              : AppColors.border.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 12,
                    color: isSelected
                        ? AppColors.accentTeal
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGridCard({
    required ExpenseCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final name = AppConstants.getCategoryName(category);
    final icon = AppConstants.getCategoryIcon(category);
    final color = AppConstants.getCategoryColor(category);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.12)
            : AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.border.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? color.withOpacity(0.4)
                                : AppColors.border.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? color : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: color,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
