import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final ValueNotifier<ExpenseCategory?> _selectedCategory = ValueNotifier<ExpenseCategory?>(null);
  final TextEditingController _searchController = TextEditingController();

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
      appBar: AppBar(
        title: const Text("Transaction History"),
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
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: AnimatedBuilder(
                  animation: _searchController,
                  builder: (context, _) {
                    final query = _searchController.text;
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: ExpenseCategory.values.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All" option
                          final isSelected = selectedCategory == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: const Text("All"),
                              selected: isSelected,
                              selectedColor: AppColors.accentTeal.withOpacity(0.2),
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.accentTeal : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                _selectedCategory.value = null;
                              },
                            ),
                          );
                        }

                        final cat = ExpenseCategory.values[index - 1];
                        final isSelected = selectedCategory == cat;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
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
              const SizedBox(height: 12),
              // History list
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_selectedCategory, _searchController]),
                  builder: (context, _) {
                    final query = _searchController.text.trim();
                    final selectedCategory = _selectedCategory.value;

                    var filteredExpenses = expenseState.expenses;

                    // Apply Category Filter
                    if (selectedCategory != null) {
                      filteredExpenses = filteredExpenses
                          .where((e) => e.categoryIndex == selectedCategory.index)
                          .toList();
                    }

                    // Apply Search Query Filter
                    if (query.isNotEmpty) {
                      filteredExpenses = filteredExpenses
                          .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    }

                    if (filteredExpenses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              "No matching transactions found",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.accentTeal,
                      onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];

                          return Dismissible(
                            key: Key(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                              ),
                              child: const Icon(Icons.delete, color: Colors.redAccent),
                            ),
                            onDismissed: (direction) async {
                              final notifier = ref.read(expenseProvider.notifier);
                              final messenger = ScaffoldMessenger.of(context);
                              await notifier.deleteExpense(expense.id);

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text("Deleted ${expense.title}"),
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
                              expense: expense,
                              onTap: () => context.push('/add-expense', extra: expense),
                            ),
                          );
                        },
                      ),
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
