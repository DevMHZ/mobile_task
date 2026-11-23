import 'package:mobile_task/core/network/app_failure.dart';
import 'package:mobile_task/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test(
    'locale and favorites survive reconstruction; session favorites do not',
    () async {
      final store = MemoryPreferences();
      final first = PreferencesCubit(store);
      await first.selectLocale('ar');
      await first.toggleFavorite(1);
      await first.toggleFavorite(-1);
      final restored = PreferencesCubit(store);
      await restored.restore();
      expect(restored.state.locale.languageCode, 'ar');
      expect(restored.state.favorites, {1});
      await first.close();
      await restored.close();
    },
  );
  test(
    'failed write preserves the previous selection and reports a storage error',
    () async {
      final store = MemoryPreferences()..fail = true;
      final cubit = PreferencesCubit(store);
      await cubit.selectLocale('ar');
      expect(cubit.state.locale.languageCode, 'en');
      expect(cubit.state.failure?.kind, FailureKind.storage);
      expect(cubit.state.saving, isFalse);
      await cubit.close();
    },
  );
}
