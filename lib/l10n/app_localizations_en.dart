// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Budget';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get systemDefault => 'System default';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get myanmar => 'Myanmar';

  @override
  String get preferencesSaved => 'Preferences saved';

  @override
  String languageChanged(Object language) {
    return 'Language changed to $language.';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get add => 'Add';

  @override
  String get history => 'History';

  @override
  String get budgets => 'Budgets';

  @override
  String get categories => 'Categories';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get topCategories => 'Top categories';

  @override
  String get categoriesWillAppearHere => 'Categories will appear here';

  @override
  String get spendingInsight => 'Spending insight';

  @override
  String get spendingInsightMessage =>
      'Track small expenses daily to keep your budget easier to manage.';

  @override
  String get security => 'Security';

  @override
  String get fingerprintLogin => 'Fingerprint login';

  @override
  String get fingerprintLoginDescription =>
      'Require fingerprint authentication when opening the app.';

  @override
  String get fingerprintAuthReason =>
      'Authenticate to open your budget dashboard';

  @override
  String get fingerprintFailed => 'Fingerprint authentication failed';

  @override
  String get fingerprintActivated => 'Fingerprint login activated';

  @override
  String get fingerprintDeactivated => 'Fingerprint login deactivated';

  @override
  String get login => 'Login';

  @override
  String get unlockApp => 'Unlock App';

  @override
  String get disableFingerprintLogin => 'Disable fingerprint login';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryDetails => 'Category details';

  @override
  String get categoryName => 'Category name';

  @override
  String get type => 'Type';

  @override
  String get saveCategory => 'Save Category';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteCategoryQuestion => 'Delete category?';

  @override
  String get deleteCategoryMessage =>
      'This category will be removed from the category list.';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionDetails => 'Transaction details';

  @override
  String get updateDetails => 'Update details';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get categoryOptional => 'Category (optional)';

  @override
  String get noCategory => 'No category';

  @override
  String get note => 'Note';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get transactionDetail => 'Transaction Detail';

  @override
  String get date => 'Date';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get searchTransaction => 'Search transaction';

  @override
  String get expenseOnly => 'Expense only';

  @override
  String get deleteTransactionQuestion => 'Delete transaction?';

  @override
  String get deleteTransactionMessage =>
      'This transaction will be removed permanently.';

  @override
  String get budgetSetup => 'Budget setup';

  @override
  String get budgetTitle => 'Budget Title';

  @override
  String get limitAmount => 'Limit Amount';

  @override
  String get period => 'Period';

  @override
  String get deleteBudgetQuestion => 'Delete budget?';

  @override
  String get deleteBudgetMessage =>
      'This budget will be removed from the budget list.';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get saveBudget => 'Save Budget';

  @override
  String get budgetDetail => 'Budget Detail';

  @override
  String get spent => 'Spent';

  @override
  String get limit => 'Limit';

  @override
  String get budgetAlert => 'Budget alert';

  @override
  String get budgetExceeded => 'Budget exceeded';

  @override
  String budgetAlertMessage(
    Object title,
    Object usagePercent,
    Object spentAmount,
    Object limitAmount,
  ) {
    return '$title is at $usagePercent% of its budget.\nSpent $spentAmount of $limitAmount.';
  }

  @override
  String get ok => 'OK';

  @override
  String get savingsGoal => 'Savings Goal';

  @override
  String get walletAccount => 'Wallet / Account';

  @override
  String get reportsAnalytics => 'Reports / Analytics';

  @override
  String get receiptScan => 'Receipt Scan';

  @override
  String get notifications => 'Notifications';

  @override
  String get profilePreferences => 'Profile / Preferences';

  @override
  String get reports => 'Reports';

  @override
  String get expenseReport => 'Expense Report';

  @override
  String get totalSpent => 'Total spent';

  @override
  String selectedWeek(Object startDate, Object endDate) {
    return '$startDate - $endDate';
  }

  @override
  String selectedMonth(Object month) {
    return '$month';
  }

  @override
  String selectedYear(Object year) {
    return '$year';
  }

  @override
  String get chooseDate => 'Choose date';

  @override
  String get expenseOnlyReport => 'Expense totals only';

  @override
  String get noExpenseForPeriod => 'No expense for this period';

  @override
  String get periodBreakdown => 'Period breakdown';

  @override
  String get selectedDateLabel => 'Selected date';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';
}
