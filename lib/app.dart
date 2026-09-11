import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_controller.dart';

class MzDriverApp extends ConsumerWidget {
  const MzDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeControllerProvider);
    final auth = ref.watch(authControllerProvider);

    // Only the first session restore should replace the tree. Login loading
    // must keep MaterialApp.router mounted or the login screen is disposed.
    if (auth.isLoading && !auth.hasValue) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: localeState.locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(localeState.locale),
        home: const Scaffold(
          backgroundColor: AppColors.navy,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.amber),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: localeState.strings.t('app.name'),
      debugShowCheckedModeBanner: false,
      locale: localeState.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(localeState.locale),
      routerConfig: router,
    );
  }
}
