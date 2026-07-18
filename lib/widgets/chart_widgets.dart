import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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

    final List<_PieData> pieData = [];
    totals.forEach((category, amount) {
      final name = AppConstants.getCategoryName(category);
      final color = AppConstants.getCategoryColor(category);
      pieData.add(_PieData(name, amount, color));
    });

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "TOTAL",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: ScreenUtils.fontTextTiny,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.simpleCurrency(
                        decimalDigits: 0,
                      ).format(grandTotal),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtils.fontTextMBig,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            series: <CircularSeries>[
              DoughnutSeries<_PieData, String>(
                dataSource: pieData,
                xValueMapper: (_PieData data, _) => data.categoryName,
                yValueMapper: (_PieData data, _) => data.amount,
                pointColorMapper: (_PieData data, _) => data.color,
                innerRadius: '72%',
                radius: '90%',
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              ),
            ],
          ),
        ),
        SizedBox(height: ScreenUtils.spacingControl),
        // Legend
        Wrap(
          spacing: ScreenUtils.spacingControl,
          runSpacing: ScreenUtils.spacingStandardControl,
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: ScreenUtils.fontTextSmaller,
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

    // Calculate dynamic Y-axis maximum
    final double maxVal = monthlySums.values.isNotEmpty
        ? monthlySums.values.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double maxY = maxVal > 0 ? (maxVal * 1.25) : 100.0;

    final List<int> last6Months = [];
    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      last6Months.add(targetDate.month);
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

    final List<_BarData> barData = [];
    for (int idx = 0; idx < last6Months.length; idx++) {
      final m = last6Months[idx];
      final amount = monthlySums[m] ?? 0.0;
      final label = monthNames[m - 1];
      barData.add(_BarData(label, amount));
    }

    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: ScreenUtils.fontTextSmaller,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppColors.border.withOpacity(0.12),
            dashArray: const <double>[5, 5],
          ),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: ScreenUtils.fontTextTiny,
            fontWeight: FontWeight.bold,
          ),
          numberFormat: NumberFormat.compactSimpleCurrency(),
          maximum: maxY,
          interval: maxY / 4,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          canShowMarker: false,
          format: 'point.y',
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtils.fontTextSmaller,
          ),
          color: AppColors.surface,
          borderColor: AppColors.border,
          borderWidth: 1,
        ),
        series: <CartesianSeries<_BarData, String>>[
          ColumnSeries<_BarData, String>(
            dataSource: barData,
            xValueMapper: (_BarData data, _) => data.month,
            yValueMapper: (_BarData data, _) => data.amount,
            borderRadius: BorderRadius.circular(4),
            width: 0.45,
            gradient: const LinearGradient(
              colors: [AppColors.accentTeal, AppColors.accentPurple],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  final String categoryName;
  final double amount;
  final Color color;

  _PieData(this.categoryName, this.amount, this.color);
}

class _BarData {
  final String month;
  final double amount;

  _BarData(this.month, this.amount);
}
