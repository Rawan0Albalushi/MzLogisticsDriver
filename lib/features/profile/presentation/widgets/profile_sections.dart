import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/app_button.dart';
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
    final status = user.driverProfile?.status;

    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ColoredBox(
            color: AppColors.amber,
            child: SizedBox(height: 3),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: user.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty
                            ? strings.t('profile.title')
                            : user.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.t('app.role'),
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (company != null && company!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          company!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.72),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (status != null && status.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _StatusChip(label: driverStatusLabel(strings, status)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.amber, width: 2),
      ),
      child: Text(
        initialsFor(name),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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
    final email = user.email.trim();
    final phone = user.phone?.trim() ?? '';
    final license = user.driverProfile?.licenseNumber?.trim() ?? '';
    final expiresRaw = user.driverProfile?.licenseExpiresAt;
    final expires = formatLicenseDate(expiresRaw, locale);
    final freshness = licenseFreshness(expiresRaw);

    return _ProfileCard(
      icon: Icons.badge_outlined,
      title: strings.t('profile.details'),
      child: Column(
        children: [
          _InfoTile(
            strings: strings,
            icon: Icons.mail_outline,
            label: strings.t('profile.email'),
            value: displayOrDash(strings, email),
            copyable: email.isNotEmpty,
            ltr: email.isNotEmpty,
          ),
          const Divider(height: 1),
          _InfoTile(
            strings: strings,
            icon: Icons.phone_outlined,
            label: strings.t('profile.phone'),
            value: displayOrDash(strings, phone),
            copyable: phone.isNotEmpty,
            ltr: phone.isNotEmpty,
          ),
          const Divider(height: 1),
          _InfoTile(
            strings: strings,
            icon: Icons.credit_card_outlined,
            label: strings.t('profile.license'),
            value: displayOrDash(strings, license),
            copyable: license.isNotEmpty,
            ltr: license.isNotEmpty,
          ),
          const Divider(height: 1),
          _InfoTile(
            strings: strings,
            icon: Icons.event_outlined,
            label: strings.t('profile.license_expires'),
            value: displayOrDash(strings, expires),
            badge: switch (freshness) {
              LicenseFreshness.expired => _InfoBadge(
                  label: strings.t('profile.license_expired'),
                  color: AppColors.danger,
                ),
              LicenseFreshness.soon => _InfoBadge(
                  label: strings.t('profile.license_expiring'),
                  color: AppColors.amber,
                ),
              _ => null,
            },
            valueColor: switch (freshness) {
              LicenseFreshness.expired => AppColors.danger,
              LicenseFreshness.soon => AppColors.amber,
              _ => AppColors.ink,
            },
          ),
        ],
      ),
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
    return _ProfileCard(
      icon: Icons.apartment_outlined,
      title: strings.t('profile.company'),
      child: Column(
        children: [
          _InfoTile(
            strings: strings,
            icon: Icons.business_outlined,
            label: strings.t('profile.company'),
            value: displayOrDash(strings, company),
          ),
          if (city != null && city!.trim().isNotEmpty) ...[
            const Divider(height: 1),
            _InfoTile(
              strings: strings,
              icon: Icons.place_outlined,
              label: strings.t('profile.city'),
              value: city!.trim(),
            ),
          ],
          if (phone != null && phone!.trim().isNotEmpty) ...[
            const Divider(height: 1),
            _InfoTile(
              strings: strings,
              icon: Icons.phone_outlined,
              label: strings.t('profile.phone'),
              value: phone!.trim(),
              copyable: true,
              ltr: true,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.t('profile.belongs_to'),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return _ProfileCard(
      icon: Icons.translate_outlined,
      title: strings.t('profile.language'),
      hint: strings.t('profile.language_hint'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 360;
          final arabic = _LanguageTile(
            code: 'AR',
            title: strings.t('lang.ar'),
            selected: selected == 'ar',
            onTap: () => onSelected('ar'),
          );
          final english = _LanguageTile(
            code: 'EN',
            title: strings.t('lang.en'),
            selected: selected == 'en',
            onTap: () => onSelected('en'),
          );
          if (stacked) {
            return Column(
              children: [arabic, const SizedBox(height: 10), english],
            );
          }
          return Row(
            children: [
              Expanded(child: arabic),
              const SizedBox(width: 10),
              Expanded(child: english),
            ],
          );
        },
      ),
    );
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
    return _ProfileCard(
      icon: Icons.logout,
      title: strings.t('profile.session'),
      hint: strings.t('profile.session_hint'),
      iconBackground: AppColors.danger.withValues(alpha: 0.1),
      iconColor: AppColors.danger,
      child: AppButton(
        label: strings.t('profile.logout'),
        tone: AppButtonTone.danger,
        icon: Icons.logout,
        onPressed: onLogout,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.child,
    this.hint,
    this.iconBackground,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget child;
  final Color? iconBackground;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBackground ?? AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? AppColors.navy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.navy,
                        ),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          hint!,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
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
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected
            ? AppColors.amber.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: AppSpacing.touch),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: selected ? AppColors.amber : AppColors.line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navy : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: selected
                        ? null
                        : Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      color: selected ? AppColors.white : AppColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: selected ? AppColors.amber : AppColors.line,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.strings,
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.ltr = false,
    this.badge,
    this.valueColor,
  });

  final AppStrings strings;
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final bool ltr;
  final Widget? badge;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: ltr ? TextDirection.ltr : null,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.ink,
                    height: 1.3,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 6),
                  badge!,
                ],
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: strings.t('profile.copy'),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => copyProfileValue(context, strings, value),
              icon: const Icon(
                Icons.copy_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
