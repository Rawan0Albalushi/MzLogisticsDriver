import 'package:intl/intl.dart';

String? formatTripDate(String? raw, String locale) {
  if (raw == null || raw.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat.yMMMEd(locale).format(parsed.toLocal());
}
