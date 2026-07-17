import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constant/app_colors.dart';
import 'package:expense_tracker/widgets/frosted_card.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/widgets/chart_widgets.dart';
import 'package:expense_tracker/feature/expense/presentation/expense_viewmodel.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);
    final expenses = expenseState.expenses;

    // Calculations
    final double totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final String formattedTotal = NumberFormat.simpleCurrency(decimalDigits: 2).format(totalSpent);

    // Get recent 3 expenses
    final recentExpenses = expenses.take(3).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0D0D1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accentTeal,
            onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // Custom Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Aura Tracker",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    // Shortcut to add manually
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.accentTeal, size: 32),
                      onPressed: () => context.push('/add-expense'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Frosted summary card
                FrostedCard(
                  opacity: 0.12,
                  blur: 25,
                  borderRadius: 24,
                  child: Column(
                    children: [
                      const Text(
                        "TOTAL SPENDING THIS MONTH",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formattedTotal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.border.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(
                            icon: Icons.receipt_long,
                            label: "Transactions",
                            value: "${expenses.length}",
                          ),
                          _buildMiniStat(
                            icon: Icons.trending_up,
                            label: "Avg. Spent",
                            value: expenses.isEmpty
                                ? "\$0.00"
                                : NumberFormat.simpleCurrency(decimalDigits: 0)
                                    .format(totalSpent / expenses.length),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Category breakdown title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Category Share",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (expenses.isNotEmpty)
                      const Text(
                        "All time",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Donut Pie chart
                CategoryPieChart(expenses: expenses),
                const SizedBox(height: 32),
                // Recent expenses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/expenses'),
                      child: const Text(
                        "See All",
                        style: TextStyle(color: AppColors.accentTeal, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recentExpenses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        "No transactions yet. Add some or scan a receipt!",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...recentExpenses.map((exp) => ExpenseCard(
                        expense: exp,
                        onTap: () => context.push('/add-expense', extra: exp),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.accentTeal),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
