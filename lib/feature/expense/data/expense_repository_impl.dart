import '../domain/expense.dart';
import '../domain/expense_repository.dart';
import '../../../core/db/hive_helper.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  @override
  Future<List<Expense>> getExpenses() async {
    final box = HiveHelper.expensesBox;
    final list = box.values.toList();
    // Sort descending by date (most recent first)
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final box = HiveHelper.expensesBox;
    await box.put(expense.id, expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final box = HiveHelper.expensesBox;
    await box.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final box = HiveHelper.expensesBox;
    await box.delete(id);
  }
}
