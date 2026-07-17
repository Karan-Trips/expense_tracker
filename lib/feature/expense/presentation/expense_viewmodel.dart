import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';
import '../../../core/locator/locator.dart';

class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? errorMessage;

  ExpenseState({
    required this.expenses,
    this.isLoading = false,
    this.errorMessage,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ExpenseViewModel extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseViewModel(this._repository) : super(ExpenseState(expenses: [])) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getExpenses();
      state = state.copyWith(expenses: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.addExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseViewModel, ExpenseState>((ref) {
  return ExpenseViewModel(locator<ExpenseRepository>());
});
