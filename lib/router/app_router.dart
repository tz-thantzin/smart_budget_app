import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/budget_entity.dart';
import '../domain/entities/category_entity.dart';
import '../domain/entities/transaction_entity.dart';
import '../presentation/screens/budget_screens.dart';
import '../presentation/screens/category_screens.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/reports_analytics_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/transaction_screens.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (_, _) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        builder: (_, state) => EditTransactionScreen(
          transaction: state.extra! as TransactionEntity,
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        builder: (_, state) => TransactionDetailScreen(
          transaction: state.extra! as TransactionEntity,
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (_, _) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (_, _) => const CategoriesManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.addEditCategory,
        builder: (_, state) =>
            AddEditCategoryScreen(category: state.extra as CategoryEntity?),
      ),
      GoRoute(
        path: AppRoutes.budgets,
        builder: (_, _) => const BudgetListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addEditBudget,
        builder: (_, state) =>
            CreateEditBudgetScreen(budget: state.extra as BudgetEntity?),
      ),
      GoRoute(
        path: AppRoutes.budgetDetail,
        builder: (_, state) =>
            BudgetDetailScreen(budget: state.extra! as BudgetEntity),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, _) => const ReportsAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
}
