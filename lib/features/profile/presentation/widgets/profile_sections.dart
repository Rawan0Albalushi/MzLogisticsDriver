import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/user.dart';
import '../profile_helpers.dart';

class ProfileIdentityHeader extends StatelessWidget {
  const ProfileIdentityHeader({
    super.key,
    required this.strings,
    required this.user,
    required this.company,
  });

  final AppStrings strings;
  final User user;
  final String? company;

  @override
  Widget build(BuildContext context) {
    final email = user.email.trim();
    final status = user.driverProfile?.status;
    final name = user.name.isEmpty ? strings.t('profile.title') : user.name;

    return _GroupCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
        child: Row(
          children: [
            _Avatar(name: name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(name, maxLines: 1, style: AppText.title),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        email,
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                        style: AppText.label,
                      ),
                    ),
                  ],
                  if (company != null && company!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        company!,
                        maxLines: 1,
                        style: AppText.caption,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    [
                      strings.t('app.role'),
                      if (status != null && status.isNotEmpty)
                        driverStatusLabel(strings, status),
                    ].join(' · '),
                    style: AppText.caption.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            if (email.isNotEmpty)
              IconButton(
                tooltip: strings.t('profile.copy'),
                onPressed: () => copyProfileValue(context, strings, email),
                icon: const Icon(
                  Icons.copy_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailsCard extends StatelessWidget {
  const ProfileDetailsCard({
    super.key,
    required this.strings,
    required this.user,
    required this.locale,
  });

  final AppStrings strings;
  final User user;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final phone = user.phone?.trim() ?? '';
    final license = user.driverProfile?.licenseNumber?.trim() ?? '';
    final expiresRaw = user.driverProfile?.licenseExpiresAt;
    final expires = formatLicenseDate(expiresRaw, locale);
    final freshness = licenseFreshness(expiresRaw);

    return _SettingsSection(
      title: strings.t('profile.details'),
      children: [
        _SettingRow(
          icon: Icons.phone_outlined,
          title: strings.t('profile.phone'),
          value: displayOrDash(strings, phone),
          ltr: phone.isNotEmpty,
          copyable: phone.isNotEmpty,
          onTap: phone.isEmpty
              ? null
              : () => copyProfileValue(context, strings, phone),
        ),
        _SettingRow(
          icon: Icons.badge_outlined,
          title: strings.t('profile.license'),
          value: displayOrDash(strings, license),
          ltr: license.isNotEmpty,
          copyable: license.isNotEmpty,
          onTap: license.isEmpty
              ? null
              : () => copyProfileValue(context, strings, license),
        ),
        _SettingRow(
          icon: Icons.event_outlined,
          title: strings.t('profile.license_expires'),
          value: displayOrDash(strings, expires),
          valueColor: switch (freshness) {
            LicenseFreshness.expired => AppColors.danger,
            LicenseFreshness.soon => AppColors.primary,
            _ => null,
          },
          badge: switch (freshness) {
            LicenseFreshness.expired => strings.t('profile.license_expired'),
            LicenseFreshness.soon => strings.t('profile.license_expiring'),
            _ => null,
          },
          showChevron: false,
        ),
      ],
    );
  }
}

class ProfileCompanyCard extends StatelessWidget {
  const ProfileCompanyCard({
    super.key,
    required this.strings,
    required this.company,
    required this.city,
    required this.phone,
  });

  final AppStrings strings;
  final String? company;
  final String? city;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _SettingRow(
        icon: Icons.apartment_outlined,
        title: strings.t('profile.company'),
        value: displayOrDash(strings, company),
        showChevron: false,
      ),
      if (city != null && city!.trim().isNotEmpty)
        _SettingRow(
          icon: Icons.place_outlined,
          title: strings.t('profile.city'),
          value: city!.trim(),
          showChevron: false,
        ),
      if (phone != null && phone!.trim().isNotEmpty)
        _SettingRow(
          icon: Icons.phone_outlined,
          title: strings.t('profile.phone'),
          value: phone!.trim(),
          ltr: true,
          copyable: true,
          onTap: () => copyProfileValue(context, strings, phone!.trim()),
        ),
    ];

    return _SettingsSection(
      title: strings.t('profile.company'),
      footer: strings.t('profile.belongs_to'),
      children: rows,
    );
  }
}

class ProfileLanguageCard extends StatelessWidget {
  const ProfileLanguageCard({
    super.key,
    required this.strings,
    required this.selected,
    required this.onSelected,
  });

  final AppStrings strings;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      icon: Icons.translate_outlined,
      title: strings.t('profile.language'),
      value: selected == 'ar' ? strings.t('lang.ar') : strings.t('lang.en'),
      ltr: selected == 'en',
      onTap: () => _openLanguageSheet(context),
    );
  }

  Future<void> _openLanguageSheet(BuildContext context) async {
    final next = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(strings.t('profile.language'), style: AppText.heading),
                const SizedBox(height: 6),
                Text(strings.t('profile.language_hint'), style: AppText.label),
                const SizedBox(height: 16),
                _LanguageChoice(
                  code: 'ar',
                  title: strings.t('lang.ar'),
                  selected: selected == 'ar',
                  onTap: () => Navigator.pop(context, 'ar'),
                ),
                const SizedBox(height: 10),
                _LanguageChoice(
                  code: 'en',
                  title: strings.t('lang.en'),
                  selected: selected == 'en',
                  onTap: () => Navigator.pop(context, 'en'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (next != null) onSelected(next);
  }
}

class ProfileLogoutCard extends StatelessWidget {
  const ProfileLogoutCard({
    super.key,
    required this.strings,
    required this.onLogout,
  });

  final AppStrings strings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      icon: Icons.logout_rounded,
      title: strings.t('profile.logout'),
      subtitle: strings.t('profile.session_hint'),
      iconColor: AppColors.danger,
      titleColor: AppColors.danger,
      showChevron: false,
      onTap: onLogout,
    );
  }
}

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.strings,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onLogout,
  });

  final AppStrings strings;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: strings.t('profile.settings'),
      children: [
        ProfileLanguageCard(
          strings: strings,
          selected: selectedLanguage,
          onSelected: onLanguageSelected,
        ),
        ProfileLogoutCard(strings: strings, onLogout: onLogout),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(title, style: AppText.label),
        ),
        _GroupCard(
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 68),
                    child: Divider(height: 1),
                  ),
              ],
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(footer!, style: AppText.caption),
          ),
        ],
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A120E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.badge,
    this.ltr = false,
    this.showChevron = true,
    this.copyable = false,
    this.iconColor,
    this.titleColor,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final String? badge;
  final bool ltr;
  final bool showChevron;
  final bool copyable;
  final Color? iconColor;
  final Color? titleColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        softWrap: false,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor ?? AppColors.ink,
                        ),
                      ),
                      if (hasValue) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Directionality(
                              textDirection: ltr
                                  ? TextDirection.ltr
                                  : Directionality.of(context),
                              child: Text(
                                value!,
                                maxLines: 1,
                                softWrap: false,
                                style: AppText.label.copyWith(
                                  color: valueColor ?? AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.caption),
                  ],
                  if (badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (valueColor ?? AppColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: AppText.caption.copyWith(
                          color: valueColor ?? AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.copy_outlined,
                color: AppColors.muted,
                size: 18,
              ),
            ] else if (showChevron) ...[
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsFor(name),
        style: AppText.heading.copyWith(color: AppColors.primary, height: 1),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.code,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: AppText.caption.copyWith(
                    color: selected ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.primary : AppColors.line,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
