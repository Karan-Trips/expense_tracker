import '../domain/expense.dart';
import '../domain/expense_repository.dart';
import '../../../core/services/db_service.dart';
import '../../../core/error/failures.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  @override
  Future<List<Expense>> getExpenses() async {
    try {
      final box = DbService.expensesBox;
      final list = box.values.toList();
      // Sort descending by date (most recent first)
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      throw CacheFailure('Failed to load expenses from database: ${e.toString()}');
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      final box = DbService.expensesBox;
      await box.put(expense.id, expense);
    } catch (e) {
      throw CacheFailure('Failed to add expense to database: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final box = DbService.expensesBox;
      await box.put(expense.id, expense);
    } catch (e) {
      throw CacheFailure('Failed to update expense in database: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      final box = DbService.expensesBox;
      await box.delete(id);
    } catch (e) {
      throw CacheFailure('Failed to delete expense from database: ${e.toString()}');
    }
  }
}
