# Smart Budget App

Smart Budget is a Flutter personal finance app for tracking expenses, managing category-based budgets, and reviewing spending activity with a clean light/dark interface.

## Architecture Overview

- **presentation**: screens, widgets, and Riverpod viewmodels.
- **domain**: entities, repository contracts, and use cases.
- **data**: SQLite datasource, models, and repository implementations.
- **core**: constants, theme, formatters, and shared scaffolds.
- **router / di**: centralized app routing and dependency injection providers.

The flow is `UI -> ViewModel -> UseCase -> Repository (interface) -> RepositoryImpl -> DataSource`.

## Folder Structure

```text
lib/
  core/
    constants/
    theme/
    utils/
    shared_widgets/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    screens/
    widgets/
    viewmodels/
  di/
  router/
```

## Package Usage

- `flutter_riverpod`: app state, async loading/error/data handling.
- `riverpod_annotation`: included for scalable codegen-based provider evolution.
- `go_router`: centralized navigation and auth/splash flow routing.
- `flutter_screenutil`: responsive sizing strategy for phones/tablets.
- `google_fonts`: consistent typography in light/dark themes.
- `intl`: currency/date formatting.
- `sqflite`: local persistence for transactions, categories, and budgets.
- `vibration`: phone vibration feedback for budget alerts.

## Implemented Functional Samples

- Add income/expense transaction.
- Transaction history with search/filter/sort.
- Create, edit, list, and delete categories.
- Seed a default `Food` expense category on fresh install.
- Create, edit, list, and delete budgets with optional category assignment.
- Track category budget usage from matching expense transactions.
- Show an alert and vibrate the phone when a new expense reaches or exceeds its matching budget threshold.
- Dashboard summary with totals, recent transactions, top spending categories, and quick actions.

## Next Steps

1. **OCR receipt scan**: add `ReceiptScanService` abstraction, plug Firebase MLKit/Tesseract API, and map results into transaction drafts.
2. **Notifications**: integrate `flutter_local_notifications` and background scheduling for budget thresholds, recurring bills, and reminders.
3. **Security**: add local PIN + biometric lock with secure storage and session timeout.
4. **Cloud sync / backup**: add sync repository decorators and conflict resolution strategy.
