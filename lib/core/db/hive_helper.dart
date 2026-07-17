import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../feature/expense/domain/expense.dart';

class HiveHelper {
  static const String expensesBoxName = 'expenses_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }

    // Open box
    await Hive.openBox<Expense>(expensesBoxName);
  }

  static Box<Expense> get expensesBox => Hive.box<Expense>(expensesBoxName);
}
