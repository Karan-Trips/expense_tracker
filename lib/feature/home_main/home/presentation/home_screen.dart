import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/core/constant/app_colors.dart';
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
    const double budget =
        15000.0; // Increased to 15,000 for realistic monthly budget mapping
    final double percentage = (totalSpent / budget).clamp(0.0, 1.0);
    final bool isOverBudget = totalSpent > budget;

    // Get recent 3 expenses
    final recentExpenses = expenses.take(3).toList();

    // Time-based greeting
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }

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
                            "$greeting, Karan",
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
                  ],
                ),
                SizedBox(height: ScreenUtils.margin * 1.5),
                // Frosted summary card with premium cosmic linear gradient
                Container(
                  padding: EdgeInsets.all(ScreenUtils.margin),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface.withOpacity(0.75),
                        const Color(0xFF1C223A).withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      ScreenUtils.kBorderRadius,
                    ),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.65),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(0.03),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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
                      Divider(color: AppColors.border.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildMiniStat(
                                icon: Icons.receipt_long_rounded,
                                label: "Transactions",
                                value: "${expenses.length}",
                                iconColor: AppColors.accentPurple,
                              ),
                            ),
                            VerticalDivider(
                              color: AppColors.border.withOpacity(0.4),
                              thickness: 1.2,
                              indent: 2,
                              endIndent: 2,
                            ),
                            Expanded(
                              child: _buildMiniStat(
                                icon: Icons.analytics_outlined,
                                label: "Avg. Spent",
                                value: expenses.isEmpty
                                    ? "₹0"
                                    : NumberFormat.simpleCurrency(
                                        locale: 'en_IN',
                                        decimalDigits: 0,
                                      ).format(totalSpent / expenses.length),
                                iconColor: AppColors.accentTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Fintech Quick Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        title: "Smart AI Scan",
                        subtitle: "Scan receipts via Gemini",
                        icon: Icons.document_scanner_outlined,
                        iconColor: AppColors.accentPurple,
                        onTap: () => context.goNamed('scanner'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        title: "Manual Entry",
                        subtitle: "Enter details manually",
                        icon: Icons.add_card_rounded,
                        iconColor: AppColors.accentTeal,
                        onTap: () => context.pushNamed('add-expense'),
                      ),
                    ),
                  ],
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
                      onPressed: () => context.goNamed('expenses'),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
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
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentExpenses.map(
                    (exp) => ExpenseCard(
                      key: ValueKey('recent_${exp.id}'),
                      expense: exp,
                      onTap: () => context.pushNamed('add-expense', extra: exp),
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
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.85),
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
