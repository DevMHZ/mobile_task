import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesStore {
  Future<String?> locale();
  Future<List<String>> favorites();
  Future<void> setLocale(String value);
  Future<void> setFavorites(List<String> values);
}

final class DevicePreferencesStore implements PreferencesStore {
  DevicePreferencesStore(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const _localeKey = 'selected_locale';
  static const _favoritesKey = 'favorite_product_ids';
  @override
  Future<String?> locale() => _preferences.getString(_localeKey);
  @override
  Future<List<String>> favorites() async =>
      await _preferences.getStringList(_favoritesKey) ?? [];
  @override
  Future<void> setLocale(String value) =>
      _preferences.setString(_localeKey, value);
  @override
  Future<void> setFavorites(List<String> values) =>
      _preferences.setStringList(_favoritesKey, values);
}
