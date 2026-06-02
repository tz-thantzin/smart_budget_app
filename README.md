# Smart Budget App

Smart Budget is a Flutter personal finance app for tracking income and expenses, managing category-based budgets, and reviewing spending trends — with a clean bilingual (English / Myanmar) light/dark interface.

## Features

- **Dashboard** — total balance, income/expense summary, recent transactions, top spending categories, and quick-action shortcuts.
- **Transactions** — add, edit, delete, and search/filter income and expense records by title, type, or date.
- **Budgets** — create period-based budgets (daily / weekly / monthly) with optional category scoping; tracks live spending progress against the limit.
- **Budget alerts** — vibration and sound feedback when an expense pushes a budget to or beyond its alert threshold.
- **Categories** — add, edit, and delete custom income/expense categories with icon and color selection.
- **Reports & Analytics** — monthly, weekly, yearly, and daily views with an income/expense bar chart, top-5 spending categories, and a full transaction list for the period. Export to PDF via the system share sheet.
- **Settings** — visual theme selector (system / light / dark), language toggle (English / Myanmar), currency picker, and biometric login switch.
- **Security** — optional fingerprint/biometric lock on app launch via `local_auth`.

## Architecture

Clean architecture with a strict one-way dependency:

```
UI (screens/widgets)
  → ViewModel (Riverpod AsyncNotifier)
    → UseCase
      → Repository (abstract, domain/)
        → RepositoryImpl (data/)
          → DataSource (SQLite / in-memory)
```

All providers are hand-wired in `lib/di/app_providers.dart`. There is no code generation (`build_runner` is not configured).

**ViewModel helpers** — filtering, sorting, aggregation, and lookup functions that would otherwise leak into the view are exported as top-level functions from their respective viewmodel files (e.g. `filterAndSortTransactions`, `categoriesForType`, `budgetNeedingAlert`, `findCategoryById`). Screens call these helpers; they contain no business logic themselves.

### Data persistence

| Store | What it holds |
|---|---|
| `LocalDatabaseDataSource` (sqflite) | transactions, categories, budgets — schema v3 |
| `LocalMemoryDataSource` (in-memory) | wallets, savings goals (re-seeded each launch) |

### Localization

Two locales — `en` and `my` (Myanmar). Source files are `lib/l10n/app_en.arb` and `lib/l10n/app_my.arb`. Generated files are checked in; regenerate with `flutter gen-l10n` after editing `.arb` files.

## Folder Structure

```
lib/
  core/
    constants/      # AppCurrency, AppConstants, app theme
    extensions/     # BuildContext helpers (localization, theme)
    services/       # ReportPdfExportService
    utils/          # Formatters, IdGenerator
    shared_widgets/
  data/
    datasources/    # LocalDatabaseDataSource, LocalMemoryDataSource
    models/         # *Model with fromMap/toMap/fromEntity
    repositories/   # RepositoryImpl classes
  domain/
    entities/       # Pure Dart entities + enums
    repositories/   # Abstract repository contracts
    usecases/       # Single-method callable use cases
  presentation/
    screens/        # One file per feature area
    viewmodels/     # AsyncNotifier viewmodels + exported helper functions
    widgets/        # Shared UI components
  di/               # app_providers.dart — all Provider<T> wiring
  router/           # app_routes.dart constants, app_router.dart GoRouter
  l10n/             # .arb source files + generated app_localizations*.dart
```

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` / `hooks_riverpod` | State management (`AsyncNotifier`, `HookConsumerWidget`) |
| `go_router` | Declarative routing; entity params via `state.extra` |
| `sqflite` | Local SQLite persistence |
| `shared_preferences` | User settings (theme, language, currency, biometrics) |
| `flutter_screenutil` | Responsive sizing — design base 390 × 844 |
| `local_auth` | Biometric / fingerprint authentication |
| `intl` | Currency and date formatting |
| `pdf` + `share_plus` | Generate and share PDF transaction reports |
| `vibration` | Haptic feedback for budget alerts |
| `flutter_hooks` | `useState`, `useMemoized` in stateful screens |
| `google_fonts` | Typography |

## Try It

A pre-built APK is available at [`assets/apk/smart_budget_app.apk`](assets/apk/smart_budget_app.apk).

To install on an Android device:
1. Enable **Install unknown apps** in device settings.
2. Transfer the APK to your device and open it to install.

## Getting Started

```bash
flutter pub get          # install dependencies
flutter gen-l10n         # regenerate localization files (after editing .arb)
flutter run              # run on connected device or emulator
flutter analyze          # static analysis (several lints are elevated to errors)
dart format .            # format code
flutter test             # run all tests
flutter build apk        # Android release build
flutter build ipa        # iOS release build
```

## Notes

- A default `Food` expense category (id `default_food`) is seeded on fresh install.
- Currency formatting reads `decimalDigits` from the `AppCurrency` enum — adding a new currency requires an entry there. Some currencies use 0 decimal places (MMK, JPY, KRW).
- PDF export uses built-in Helvetica fonts (no network required). Currency amounts are formatted with the ISO code prefix (e.g. `THB 1,234.56`) to avoid font glyph issues with special currency symbols.

## Upcoming Features

- **Wallet / Account Management** — add, edit, and delete wallets such as cash, bank, mobile wallet, and credit card accounts; choose a wallet when recording transactions; view balances by wallet.
- **Savings Goals** — create savings targets with progress tracking, target dates, and goal summaries.
- **Tags & Receipt Images** — add searchable tags to transactions and attach receipt images for better transaction records.
