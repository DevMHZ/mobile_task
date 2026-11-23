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

  /// Localised label for an internal property-type key (see
  /// `Product.propertyType`). Keys stay in English for filtering; only
  /// the displayed label is translated.
  String propertyTypeLabel(String key) => switch (key) {
    'Apartments' => l10n.apartments,
    'Townhomes' => l10n.townhomes,
    'Homes' => l10n.homes,
    'Condos' => l10n.condos,
    'Duplexes' => l10n.duplexes,
    'Studios' => l10n.studios,
    _ => key,
  };

  String failureMessage(AppFailure failure) => switch (failure.kind) {
    FailureKind.offline => l10n.offlineError,
    FailureKind.timeout => l10n.timeoutError,
    FailureKind.server => l10n.serverError,
    FailureKind.storage => l10n.storageError,
    _ => l10n.responseError,
  };
}
