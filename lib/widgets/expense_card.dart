import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constant/app_colors.dart';
import '../core/constant/app_constants.dart';
import '../feature/expense/domain/expense.dart';
import 'frosted_card.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppConstants.getCategoryColor(expense.category);
    final categoryIcon = AppConstants.getCategoryIcon(expense.category);
    final formattedDate = DateFormat('MMM dd, yyyy').format(expense.date);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: ScreenUtils.spacingControl),
      child: FrostedCard(
        padding: const EdgeInsets.symmetric(
          horizontal: ScreenUtils.margin,
          vertical: ScreenUtils.spacingControl,
        ),
        borderRadius: ScreenUtils.kBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScreenUtils.kBorderRadius),
          child: Row(
            children: [
              // Icon with circular container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: categoryColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 20,
                ),
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
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: AppStyles.textSmaller,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Price / Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(expense.amount),
                    style: AppStyles.text.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (expense.description != null && expense.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.description!,
                      style: AppStyles.textSmaller.copyWith(
                        fontSize: ScreenUtils.fontTextTiny,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
