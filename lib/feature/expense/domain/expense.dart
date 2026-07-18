import 'package:hive_ce/hive.dart';
import '../../../core/constant/app_constants.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int categoryIndex;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? receiptImagePath;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  // Non-persisted field to track if this came from a scanner fallback
  final bool isScanFallback;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryIndex,
    this.description,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
    this.isScanFallback = false,
  });

  ExpenseCategory get category {
    if (categoryIndex >= 0 && categoryIndex < ExpenseCategory.values.length) {
      return ExpenseCategory.values[categoryIndex];
    }
    return ExpenseCategory.others;
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    int? categoryIndex,
    String? description,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isScanFallback,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isScanFallback: isScanFallback ?? this.isScanFallback,
    );
  }
}
