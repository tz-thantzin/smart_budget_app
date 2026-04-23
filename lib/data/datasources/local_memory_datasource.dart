import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/entities/wallet_account_entity.dart';

class LocalMemoryDataSource {
  LocalMemoryDataSource() {
    final now = DateTime.now();
    wallets = [
      const WalletAccountEntity(
        id: 'w1',
        name: 'Cash Wallet',
        type: WalletType.cash,
        currencyCode: 'USD',
        balance: 1200,
      ),
      const WalletAccountEntity(
        id: 'w2',
        name: 'Main Bank',
        type: WalletType.bank,
        currencyCode: 'USD',
        balance: 3400,
      ),
    ];

    budgets = [
      BudgetEntity(
        id: 'b1',
        title: 'Monthly Essentials',
        amountLimit: 900,
        categoryId: null,
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        spentAmount: 420,
        alertThresholdPercent: 0.8,
        rolloverEnabled: true,
      ),
    ];

    savingsGoals = [
      SavingsGoalEntity(
        id: 's1',
        title: 'Emergency Fund',
        targetAmount: 10000,
        currentAmount: 3800,
        targetDate: DateTime(now.year + 1, now.month),
      ),
    ];
  }

  late List<BudgetEntity> budgets;
  late List<WalletAccountEntity> wallets;
  late List<SavingsGoalEntity> savingsGoals;
}
