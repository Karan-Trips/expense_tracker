import 'package:expense_tracker/feature/expense/domain/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_constants.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/expense_card.dart';
import 'expense_viewmodel.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final ValueNotifier<ExpenseCategory?> _selectedCategory =
      ValueNotifier<ExpenseCategory?>(null);
  final TextEditingController _searchController = TextEditingController();

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));
    final checkMidnight = DateTime(date.year, date.month, date.day);

    if (checkMidnight == todayMidnight) {
      return "Today";
    } else if (checkMidnight == yesterdayMidnight) {
      return "Yesterday";
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  @override
  void dispose() {
    _selectedCategory.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0D0D1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.margin,
                  vertical: ScreenUtils.spacingStandardControl,
                ),
                child: AnimatedBuilder(
                  animation: _searchController,
                  builder: (context, _) {
                    final query = _searchController.text;
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        hintText: "Search transactions...",
                      ),
                    );
                  },
                ),
              ),
              // Category Filter list
              SizedBox(
                height: 50,
                child: ValueListenableBuilder<ExpenseCategory?>(
                  valueListenable: _selectedCategory,
                  builder: (context, selectedCategory, _) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.margin,
                      ),
                      itemCount: ExpenseCategory.values.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All" option
                          final isSelected = selectedCategory == null;
                          return Padding(
                            key: const ValueKey('category_chip_all'),
                            padding: EdgeInsets.only(
                              right: ScreenUtils.spacingStandardControl,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _selectedCategory.value = null;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.fontTextSmall,
                                  vertical: ScreenUtils.spacingStandardControl,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accentTeal.withOpacity(0.15)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    ScreenUtils.textRadius,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentTeal
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accentTeal
                                                .withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 15,
                                      color: isSelected
                                          ? AppColors.accentTeal
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "All",
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: ScreenUtils.fontTextSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final cat = ExpenseCategory.values[index - 1];
                        final isSelected = selectedCategory == cat;

                        return Padding(
                          key: ValueKey('category_chip_${cat.name}'),
                          padding: EdgeInsets.only(
                            right: ScreenUtils.spacingStandardControl,
                          ),
                          child: CategoryChip(
                            category: cat,
                            isSelected: isSelected,
                            onTap: () {
                              _selectedCategory.value = isSelected ? null : cat;
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: ScreenUtils.spacingControl),
              // History list
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _selectedCategory,
                    _searchController,
                  ]),
                  builder: (context, _) {
                    final query = _searchController.text.trim();
                    final selectedCategory = _selectedCategory.value;

                    var filteredExpenses = expenseState.expenses;

                    // Apply Category Filter
                    if (selectedCategory != null) {
                      filteredExpenses = filteredExpenses
                          .where(
                            (e) => e.categoryIndex == selectedCategory.index,
                          )
                          .toList();
                    }

                    // Apply Search Query Filter
                    if (query.isNotEmpty) {
                      filteredExpenses = filteredExpenses
                          .where(
                            (e) => e.title.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                          )
                          .toList();
                    }

                    final filteredCount = filteredExpenses.length;
                    final double filteredTotal = filteredExpenses.fold(
                      0.0,
                      (sum, item) => sum + item.amount,
                    );
                    final String formattedFilteredTotal =
                        NumberFormat.simpleCurrency(
                          locale: 'en_IN',
                          decimalDigits: 2,
                        ).format(filteredTotal);

                    final summaryBar = Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.margin,
                        vertical: ScreenUtils.spacingStandardControl,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Found $filteredCount transaction${filteredCount == 1 ? '' : 's'}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Total: $formattedFilteredTotal",
                            style: const TextStyle(
                              color: AppColors.accentTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (filteredExpenses.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          summaryBar,
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    child: Lottie.network(
                                      'https://lottie.host/c5c84d72-9b24-4f24-9b5f-5573426e95bf/PzY4Dk9v5I.json',
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.receipt_long_outlined,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No matching transactions found",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Sort descending by date
                    final sortedExpenses = List<Expense>.from(filteredExpenses)
                      ..sort((a, b) => b.date.compareTo(a.date));

                    // Group expenses by Date
                    final List<dynamic> listItems = [];
                    DateTime? currentDate;

                    for (final exp in sortedExpenses) {
                      final expenseDateMidnight = DateTime(
                        exp.date.year,
                        exp.date.month,
                        exp.date.day,
                      );
                      if (currentDate == null ||
                          currentDate != expenseDateMidnight) {
                        currentDate = expenseDateMidnight;
                        listItems.add(currentDate);
                      }
                      listItems.add(exp);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        summaryBar,
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.accentTeal,
                            onRefresh: () => ref
                                .read(expenseProvider.notifier)
                                .loadExpenses(),
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtils.margin,
                                0,
                                ScreenUtils.margin,
                                100,
                              ),
                              itemCount: listItems.length,
                              itemBuilder: (context, index) {
                                final item = listItems[index];

                                if (item is DateTime) {
                                  return Padding(
                                    key: ValueKey(
                                      'header_${item.millisecondsSinceEpoch}',
                                    ),
                                    padding: const EdgeInsets.only(
                                      top: 26.0,
                                      bottom: 14.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface
                                                .withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border
                                                  .withOpacity(0.85),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _getDateHeader(item).toUpperCase(),
                                            style: const TextStyle(
                                              color: AppColors.accentTeal,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Divider(
                                            color: AppColors.border.withOpacity(
                                              0.3,
                                            ),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final expense = item as Expense;

                                return Dismissible(
                                  key: ValueKey('dismissible_${expense.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    margin: EdgeInsets.only(
                                      bottom: ScreenUtils.spacingControl,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                        ScreenUtils.cardCircularRadius,
                                      ),
                                      border: Border.all(
                                        color: Colors.redAccent.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    final notifier = ref.read(
                                      expenseProvider.notifier,
                                    );
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    await notifier.deleteExpense(expense.id);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Deleted ${expense.title}",
                                        ),
                                        action: SnackBarAction(
                                          label: "Undo",
                                          textColor: AppColors.accentTeal,
                                          onPressed: () async {
                                            await notifier.addExpense(expense);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: ExpenseCard(
                                    key: ValueKey('card_${expense.id}'),
                                    expense: expense,
                                    onTap: () => context.pushNamed(
                                      'add-expense',
                                      extra: expense,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
