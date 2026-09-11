import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_strings.dart';

enum LicenseFreshness { ok, soon, expired, unknown }

String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'D';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String displayOrDash(AppStrings strings, String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? strings.t('common.dash') : trimmed;
}

String driverStatusLabel(AppStrings strings, String? status) {
  if (status == null || status.isEmpty) {
    return strings.t('common.dash');
  }
  final key = 'profile.status.$status';
  final translated = strings.t(key);
  return translated == key ? status : translated;
}

String formatLicenseDate(String? raw, String locale) {
  if (raw == null || raw.trim().isEmpty) return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat.yMMMd(locale).format(parsed);
}

LicenseFreshness licenseFreshness(String? raw) {
  final parsed = DateTime.tryParse(raw ?? '');
  if (parsed == null) return LicenseFreshness.unknown;
  final today = DateTime.now();
  final expiry = DateTime(parsed.year, parsed.month, parsed.day);
  final now = DateTime(today.year, today.month, today.day);
  if (expiry.isBefore(now)) return LicenseFreshness.expired;
  if (expiry.difference(now).inDays <= 30) return LicenseFreshness.soon;
  return LicenseFreshness.ok;
}

Future<void> copyProfileValue(
  BuildContext context,
  AppStrings strings,
  String value,
) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(strings.t('profile.copied'))),
  );
}
