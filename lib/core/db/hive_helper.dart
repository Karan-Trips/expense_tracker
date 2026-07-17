import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../feature/expense/domain/expense.dart';
import '../error/failures.dart';

class HiveHelper {
  static const String expensesBoxName = 'expenses_box';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Register Adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ExpenseAdapter());
      }

      // Open box
      await Hive.openBox<Expense>(expensesBoxName);
    } catch (e) {
      throw CacheFailure('Failed to initialize local database: ${e.toString()}');
    }
  }

  static Box<Expense> get expensesBox => Hive.box<Expense>(expensesBoxName);
}
