import 'package:flutter/widgets.dart';

import 'package:budget_app/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get localization => AppLocalizations.of(this)!;
}
