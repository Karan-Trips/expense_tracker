import 'package:get_it/get_it.dart';
import '../../feature/expense/data/expense_repository_impl.dart';
import '../../feature/expense/domain/expense_repository.dart';
import '../services/gemini_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register Services
  locator.registerSingleton<GeminiService>(GeminiService());

  // Register Repositories
  locator.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());
}
