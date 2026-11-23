import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/preferences_store.dart';

import '../../../../core/network/app_failure.dart';

final class PreferencesState {
  PreferencesState({
    required this.locale,
    required Set<int> favorites,
    this.saving = false,
    this.failure,
  }) : favorites = Set.unmodifiable(favorites);
  final Locale locale;
  final Set<int> favorites;
  final bool saving;
  final AppFailure? failure;
}

final class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(this._store, {Locale initialLocale = const Locale('en')})
    : super(PreferencesState(locale: initialLocale, favorites: {}));
  final PreferencesStore _store;

  Future<void> restore() async {
    if (isClosed || state.saving) return;
    emit(
      PreferencesState(
        locale: state.locale,
        favorites: state.favorites,
        saving: true,
      ),
    );
    try {
      final locale = await _store.locale();
      final favorites = (await _store.favorites()).map(int.parse).toSet();
      if (isClosed) return;
      emit(
        PreferencesState(
          locale: ['ar', 'en'].contains(locale)
              ? Locale(locale!)
              : state.locale,
          favorites: favorites,
        ),
      );
    } on Object {
      if (!isClosed) {
        emit(
          PreferencesState(
            locale: state.locale,
            favorites: state.favorites,
            failure: const AppFailure(FailureKind.storage),
          ),
        );
      }
    }
  }

  Future<void> selectLocale(String language) async {
    if (state.saving || !['ar', 'en'].contains(language)) return;
    await _persist(locale: Locale(language), favorites: state.favorites);
  }

  Future<void> toggleFavorite(int id) async {
    if (state.saving) return;
    final favorites = {...state.favorites};
    if (!favorites.add(id)) favorites.remove(id);
    await _persist(locale: state.locale, favorites: favorites);
  }

  Future<void> _persist({
    required Locale locale,
    required Set<int> favorites,
  }) async {
    final previous = state;
    emit(PreferencesState(locale: locale, favorites: favorites, saving: true));
    try {
      // Store only real server IDs; session creations disappear on restart.
      if (locale != previous.locale) {
        await _store.setLocale(locale.languageCode);
      }
      if (favorites != previous.favorites) {
        await _store.setFavorites(
          favorites.where((id) => id > 0).map((id) => '$id').toList(),
        );
      }
      if (!isClosed) {
        emit(PreferencesState(locale: locale, favorites: favorites));
      }
    } on Object {
      if (!isClosed) {
        emit(
          PreferencesState(
            locale: previous.locale,
            favorites: previous.favorites,
            failure: const AppFailure(FailureKind.storage),
          ),
        );
      }
    }
  }
}
