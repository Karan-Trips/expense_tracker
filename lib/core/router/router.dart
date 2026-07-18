import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/splash/presentation/splash_screen.dart';
import '../../feature/home_main/navigation/main_navigation_screen.dart';
import '../../feature/home_main/home/presentation/home_screen.dart';
import '../../feature/expense/presentation/expense_list_screen.dart';
import '../../feature/expense/presentation/add_edit_expense_screen.dart';
import '../../feature/scanner/presentation/receipt_scanner_screen.dart';
import '../../feature/insights/presentation/spending_insights_screen.dart';
import '../../feature/expense/domain/expense.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/expenses',
          name: 'expenses',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExpenseListScreen(),
          ),
        ),
        GoRoute(
          path: '/scanner',
          name: 'scanner',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReceiptScannerScreen(),
          ),
        ),
        GoRoute(
          path: '/insights',
          name: 'insights',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SpendingInsightsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/add-expense',
      name: 'add-expense',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final expense = state.extra as Expense?;
        return AddEditExpenseScreen(expense: expense);
      },
    ),
  ],
);
