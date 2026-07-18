import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
    final double totalSpent = expenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final String formattedTotal = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 2,
    ).format(totalSpent);

    // Budget Calculations
    const double budget = 1500.0;
    final double percentage = (totalSpent / budget).clamp(0.0, 1.0);
    final bool isOverBudget = totalSpent > budget;

    // Get recent 3 expenses
    final recentExpenses = expenses.take(3).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F1322)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accentTeal,
            onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.margin,
                ScreenUtils.margin,
                ScreenUtils.margin,
                100,
              ),
              children: [
                // Premium Styled Header
                Row(
                  children: [
                    // Profile avatar placeholder
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.accentPurple,
                            AppColors.accentTeal,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "KT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, Karan",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: ScreenUtils.fontTextSmall,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Aura Intelligence",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Shortcut add button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentTeal.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.accentTeal,
                          size: 22,
                        ),
                        onPressed: () => context.push('/add-expense'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.margin * 1.5),
                // Frosted summary card
                FrostedCard(
                  opacity: 0.12,
                  blur: 25,
                  borderRadius: ScreenUtils.kBorderRadius,
                  child: Column(
                    children: [
                      Text(
                        "TOTAL SPENDING THIS MONTH",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: ScreenUtils.fontTextTiny,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formattedTotal,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtils.fontTextTitle,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sleek Budget Progress Indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Budget Progress (${(percentage * 100).toStringAsFixed(0)}%)",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "₹${totalSpent.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: isOverBudget
                                      ? Colors.redAccent
                                      : AppColors.accentTeal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: AppColors.border.withOpacity(
                                0.4,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOverBudget
                                    ? Colors.redAccent
                                    : AppColors.accentTeal,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: AppColors.border.withOpacity(0.5)),
                      const SizedBox(height: 10),
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
                                ? "₹0.00"
                                : NumberFormat.simpleCurrency(
                                    locale: 'en_IN',
                                    decimalDigits: 0,
                                  ).format(totalSpent / expenses.length),
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
                    Text(
                      "Category Share",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtils.fontText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (expenses.isNotEmpty)
                      Text(
                        "All time",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: ScreenUtils.fontTextSmaller,
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
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtils.fontText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/expenses'),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: AppColors.accentTeal,
                          fontSize: ScreenUtils.fontTextSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                 if (recentExpenses.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(
                        ScreenUtils.kBorderRadius,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          child: Lottie.network(
                            'https://lottie.host/c5c84d72-9b24-4f24-9b5f-5573426e95bf/PzY4Dk9v5I.json',
                            errorBuilder: (context, error, stackTrace) {
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
                          "No transactions yet. Add some or scan a receipt!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentExpenses.map(
                    (exp) => ExpenseCard(
                      expense: exp,
                      onTap: () => context.push('/add-expense', extra: exp),
                    ),
                  ),
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
