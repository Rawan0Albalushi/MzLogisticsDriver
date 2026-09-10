import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'app_strings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.');
});

final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleState>(LocaleController.new);

final stringsProvider = Provider<AppStrings>((ref) {
  return ref.watch(localeControllerProvider).strings;
});

class LocaleState {
  const LocaleState({
    required this.locale,
    required this.strings,
  });

  final Locale locale;
  final AppStrings strings;
}

class LocaleController extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    throw UnimplementedError('LocaleController must be seeded from main.');
  }

  Future<void> setLanguage(String code) async {
    final strings = await AppStrings.load(code);
    await ref.read(sharedPreferencesProvider).setString(
          AppConfig.localeStorageKey,
          code,
        );
    state = LocaleState(locale: Locale(code), strings: strings);
  }
}

class SeededLocaleController extends LocaleController {
  SeededLocaleController(this._initial);

  final LocaleState _initial;

  @override
  LocaleState build() => _initial;
}
