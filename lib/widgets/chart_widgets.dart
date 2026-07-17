import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constant/app_colors.dart';
import '../core/constant/app_constants.dart';
import '../feature/expense/domain/expense.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryPieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Aggregate category totals
    final Map<ExpenseCategory, double> totals = {};
    double grandTotal = 0;
    for (final exp in expenses) {
      totals[exp.category] = (totals[exp.category] ?? 0) + exp.amount;
      grandTotal += exp.amount;
    }

    final List<PieChartSectionData> sections = [];
    totals.forEach((category, amount) {
      final percentage = grandTotal > 0 ? (amount / grandTotal * 100).toStringAsFixed(1) : '0';
      sections.add(
        PieChartSectionData(
          color: AppConstants.getCategoryColor(category),
          value: amount,
          title: '$percentage%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: totals.keys.map((category) {
            final color = AppConstants.getCategoryColor(category);
            final name = AppConstants.getCategoryName(category);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MonthlyBarChart extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyBarChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No trend data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Group by month (last 6 months)
    final Map<int, double> monthlySums = {}; // Month (1-12) -> Sum
    final now = DateTime.now();

    for (final exp in expenses) {
      // Limit to current year for simplicity
      if (exp.date.year == now.year) {
        monthlySums[exp.date.month] = (monthlySums[exp.date.month] ?? 0) + exp.amount;
      }
    }

    final List<BarChartGroupData> barGroups = [];
    final List<int> last6Months = [];
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      last6Months.add(targetDate.month);
    }

    for (int idx = 0; idx < last6Months.length; idx++) {
      final m = last6Months[idx];
      final amount = monthlySums[m] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: amount,
              gradient: const LinearGradient(
                colors: [AppColors.accentTeal, AppColors.accentPurple],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    final List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (monthlySums.values.isNotEmpty ? (monthlySums.values.reduce((a, b) => a > b ? a : b) * 1.2) : 100.0),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int idx = value.toInt();
                  if (idx >= 0 && idx < last6Months.length) {
                    final monthNum = last6Months[idx];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        monthNames[monthNum - 1],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
