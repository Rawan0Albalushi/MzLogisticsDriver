import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/l10n/locale_controller.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString(AppConfig.localeStorageKey) ?? 'ar';
  final strings = await AppStrings.load(languageCode);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localeControllerProvider.overrideWith(
          () => SeededLocaleController(
            LocaleState(locale: Locale(languageCode), strings: strings),
          ),
        ),
      ],
      child: const MzDriverApp(),
    ),
  );
}
