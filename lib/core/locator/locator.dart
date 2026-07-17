import 'package:get_it/get_it.dart';
import '../../feature/expense/data/expense_repository_impl.dart';
import '../../feature/expense/domain/expense_repository.dart';
import '../api/gemini_client.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register Services
  locator.registerSingleton<GeminiClient>(GeminiClient());

  // Register Repositories
  locator.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());
}
