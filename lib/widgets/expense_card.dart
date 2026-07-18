import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constant/app_colors.dart';
import '../core/constant/app_constants.dart';
import '../feature/expense/domain/expense.dart';
import 'frosted_card.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseCard({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppConstants.getCategoryColor(expense.category);
    final categoryIcon = AppConstants.getCategoryIcon(expense.category);
    final formattedDate = DateFormat('MMM dd, yyyy').format(expense.date);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: ScreenUtils.spacingControl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtils.kBorderRadius),
        child: Material(
          color: Colors.transparent,
          child: FrostedCard(
            padding: EdgeInsets.zero,
            borderRadius: ScreenUtils.kBorderRadius,
            child: InkWell(
              onTap: onTap,
              splashColor: categoryColor.withOpacity(0.1),
              highlightColor: categoryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(ScreenUtils.kBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(ScreenUtils.margin),
                child: Row(
                  children: [
                    // Icon with squircle container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 20),
                    ),
                    const SizedBox(width: ScreenUtils.margin),
                    // Description and Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: AppStyles.textSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: AppStyles.textSmaller.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price / Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currencyFormat.format(expense.amount),
                          style: AppStyles.text.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (expense.description != null &&
                            expense.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: Text(
                              expense.description!,
                              style: AppStyles.textSmaller.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
