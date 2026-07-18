import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constant/app_colors.dart';
import '../core/constant/app_constants.dart';
import '../feature/expense/domain/expense.dart';

class ExpenseCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseCard({super.key, required this.expense, required this.onTap});

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppConstants.getCategoryColor(widget.expense.category);
    final categoryIcon = AppConstants.getCategoryIcon(widget.expense.category);
    final categoryName = AppConstants.getCategoryName(widget.expense.category);
    final formattedDate = DateFormat('MMM dd, yyyy').format(widget.expense.date);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2);

    final isAiScanned = widget.expense.receiptImagePath != null && !widget.expense.isScanFallback;
    final isOfflineScan = widget.expense.receiptImagePath != null && widget.expense.isScanFallback;

    final description = widget.expense.description ?? "";
    final hasDescription = description.isNotEmpty;
    final isLongDescription = description.length > 55;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1.0 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtils.spacingControl),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.margin,
              vertical: ScreenUtils.margin * 0.85,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon container with soft colored background and shadow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.24),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.margin),
                    // Merchant / Title and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.expense.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAiScanned) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.accentTeal.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 9,
                                        color: AppColors.accentTeal,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "AI",
                                        style: TextStyle(
                                          color: AppColors.accentTeal,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (isOfflineScan) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.orangeAccent.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        size: 9,
                                        color: Colors.orangeAccent,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "OFFLINE",
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Meta details: Category tag + Date + attachment indicator
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "•",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              if (widget.expense.receiptImagePath != null) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  "•",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.image_outlined,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Spent amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currencyFormat.format(widget.expense.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 15.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (hasDescription) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.9),
                              height: 1.4,
                            ),
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLongDescription) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? "Read Less" : "Read More",
                                    style: const TextStyle(
                                      color: AppColors.accentTeal,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 14,
                                    color: AppColors.accentTeal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
