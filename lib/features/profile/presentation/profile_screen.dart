import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/page_header.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_controller.dart';
import 'widgets/profile_sections.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final locale = ref.watch(localeControllerProvider).locale;
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('profile.title'),
          ),
          Expanded(
            child: user == null
                ? LoadingState(message: strings.t('state.loading'))
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(authControllerProvider.notifier).refreshMe(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        ProfileIdentityHeader(
                          strings: strings,
                          user: user,
                          company: user.organization?.displayName(
                            locale.languageCode,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ProfileDetailsCard(
                          strings: strings,
                          user: user,
                          locale: locale.languageCode,
                        ),
                        const SizedBox(height: 22),
                        ProfileCompanyCard(
                          strings: strings,
                          company: user.organization?.displayName(
                            locale.languageCode,
                          ),
                          city: user.organization?.city,
                          phone: user.organization?.phone,
                        ),
                        const SizedBox(height: 22),
                        ProfileSettingsCard(
                          strings: strings,
                          selectedLanguage: locale.languageCode,
                          onLanguageSelected: (code) =>
                              _changeLanguage(ref, code),
                          onLogout: () => _logout(context, ref, strings),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(WidgetRef ref, String code) async {
    if (ref.read(localeControllerProvider).locale.languageCode == code) {
      return;
    }
    await ref.read(localeControllerProvider.notifier).setLanguage(code);
    try {
      await ref.read(authRepositoryProvider).updateLocale(code);
    } catch (_) {
      // Language still updates locally if the API call fails.
    }
  }

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.t('profile.logout')),
          content: Text(strings.t('profile.logout_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.t('common.cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
              ),
              child: Text(strings.t('profile.logout')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
  }
}
