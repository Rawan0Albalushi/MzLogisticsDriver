import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final locale = ref.watch(localeControllerProvider).locale;
    final user = ref.watch(authControllerProvider).valueOrNull;
    final company = user?.organization?.displayName(locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(strings.t('profile.title'))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            user?.name ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            strings.t('app.role'),
            style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Row(label: strings.t('profile.email'), value: user?.email),
          _Row(label: strings.t('profile.phone'), value: user?.phone),
          _Row(label: strings.t('profile.company'), value: company),
          _Row(
            label: strings.t('profile.license'),
            value: user?.driverProfile?.licenseNumber,
          ),
          _Row(
            label: strings.t('profile.license_expires'),
            value: user?.driverProfile?.licenseExpiresAt,
          ),
          _Row(
            label: strings.t('profile.driver_status'),
            value: user?.driverProfile?.status,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.t('profile.belongs_to'),
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            strings.t('profile.language'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: strings.t('lang.ar'),
                  tone: locale.languageCode == 'ar'
                      ? AppButtonTone.navy
                      : AppButtonTone.ghost,
                  onPressed: () => _changeLanguage(ref, 'ar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: strings.t('lang.en'),
                  tone: locale.languageCode == 'en'
                      ? AppButtonTone.navy
                      : AppButtonTone.ghost,
                  onPressed: () => _changeLanguage(ref, 'en'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: strings.t('profile.logout'),
            tone: AppButtonTone.danger,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(WidgetRef ref, String code) async {
    await ref.read(localeControllerProvider.notifier).setLanguage(code);
    try {
      await ref.read(authRepositoryProvider).updateLocale(code);
    } catch (_) {
      // Language still updates locally if the API call fails.
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 2),
          Text(value?.isNotEmpty == true ? value! : '—', style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}
