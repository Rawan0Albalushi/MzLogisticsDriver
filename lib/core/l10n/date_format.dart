import 'package:intl/intl.dart';

String? formatTripDate(String? raw, String locale) {
  if (raw == null || raw.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return latinDigits(
    DateFormat.yMMMEd(locale).add_Hm().format(parsed.toLocal()),
  );
}

String latinDigits(String value) {
  const easternArabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final easternIndex = easternArabic.indexOf(char);
    if (easternIndex >= 0) {
      buffer.write(easternIndex);
      continue;
    }
    final persianIndex = persian.indexOf(char);
    if (persianIndex >= 0) {
      buffer.write(persianIndex);
      continue;
    }
    buffer.write(char);
  }
  return buffer.toString();
}
