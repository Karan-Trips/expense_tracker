import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
      final percentage = grandTotal > 0
          ? (amount / grandTotal * 100).toStringAsFixed(1)
          : '0';
      sections.add(
        PieChartSectionData(
          color: AppConstants.getCategoryColor(category),
          value: amount,
          title: '$percentage%',
          radius: 35,
          showTitle: true,
          titleStyle: const TextStyle(
            fontSize: 10,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 55,
                  sectionsSpace: 3,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "TOTAL",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormat.simpleCurrency(
                      decimalDigits: 0,
                    ).format(grandTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
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
        monthlySums[exp.date.month] =
            (monthlySums[exp.date.month] ?? 0) + exp.amount;
      }
    }

    // Calculate dynamic maxY
    final double maxVal = monthlySums.values.isNotEmpty
        ? monthlySums.values.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double maxY = maxVal > 0 ? (maxVal * 1.25) : 100.0;

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

    final List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              tooltipMargin: 8,
              tooltipBorder: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
              getTooltipColor: (group) => AppColors.surface.withOpacity(0.95),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  NumberFormat.simpleCurrency(decimalDigits: 0).format(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
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
                      padding: const EdgeInsets.only(top: 8.0),
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0 || value == maxY) {
                    return const SizedBox();
                  }
                  String formatted = '';
                  if (value >= 1000) {
                    formatted = '\$${(value / 1000).toStringAsFixed(0)}K';
                  } else {
                    formatted = '\$${value.toStringAsFixed(0)}';
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      formatted,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withOpacity(0.12),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
