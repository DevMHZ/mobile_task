import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../network/app_failure.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String money(double price) {
    final formatted = NumberFormat.currency(
      locale: Localizations.localeOf(this).toLanguageTag(),
      name: 'USD',
      symbol: r'US$',
      decimalDigits: 2,
    ).format(price);
    // Isolate the mixed Latin currency and number inside an RTL paragraph.
    return '\u2066$formatted\u2069';
  }

  String failureMessage(AppFailure failure) => switch (failure.kind) {
    FailureKind.offline => l10n.offlineError,
    FailureKind.timeout => l10n.timeoutError,
    FailureKind.server => l10n.serverError,
    FailureKind.storage => l10n.storageError,
    _ => l10n.responseError,
  };
}
