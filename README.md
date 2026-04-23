# Budget Architect App

A scalable personal finance manager built with Flutter, Riverpod, go_router, and clean architecture.

## Architecture Overview

- **presentation**: screens, widgets, and Riverpod viewmodels.
- **domain**: entities, repository contracts, and use cases.
- **data**: local-first in-memory datasource, models, and repository implementations.
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

## Implemented Functional Samples

- Add income/expense transaction.
- Transaction history with search/filter/sort.
- Create and list categories.
- Create and list budgets with usage progress.
- Dashboard summary with totals, recent transactions, top spending categories, and quick actions.

## Next Steps

1. **Local DB**: replace `LocalMemoryDataSource` with Isar/Hive/SQLite datasource adapters and preserve repository interfaces.
2. **OCR receipt scan**: add `ReceiptScanService` abstraction, plug Firebase MLKit/Tesseract API, and map results into transaction drafts.
3. **Notifications**: integrate `flutter_local_notifications` and background scheduling for budget thresholds, recurring bills, and reminders.
4. **Security**: add local PIN + biometric lock with secure storage and session timeout.
5. **Cloud sync / backup**: add sync repository decorators and conflict resolution strategy.
