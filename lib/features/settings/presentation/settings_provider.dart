import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const _key = 'user_locale';

  LocaleNotifier() : super(const Locale('am')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_key);
    if (langCode != null) {
      state = Locale(langCode);
    }
  }

  Future<void> setLocale(String langCode) async {
    state = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, langCode);
  }

  void toggle() {
    if (state.languageCode == 'am') {
      setLocale('en');
    } else {
      setLocale('am');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final isAmharicProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'am';
});

enum ViewMode { grid, list }

class ViewModeNotifier extends StateNotifier<ViewMode> {
  ViewModeNotifier() : super(ViewMode.grid);

  void toggle() {
    state = state == ViewMode.grid ? ViewMode.list : ViewMode.grid;
  }

  void setMode(ViewMode mode) {
    state = mode;
  }
}

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>((ref) {
  return ViewModeNotifier();
});

class DataSaverNotifier extends StateNotifier<bool> {
  DataSaverNotifier() : super(false);

  void toggle() {
    state = !state;
  }
}

final dataSaverProvider = StateNotifierProvider<DataSaverNotifier, bool>((ref) {
  return DataSaverNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggle(String itemId) {
    if (state.contains(itemId)) {
      state = {...state}..remove(itemId);
    } else {
      state = {...state, itemId};
    }
  }

  bool isFavorite(String itemId) => state.contains(itemId);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
