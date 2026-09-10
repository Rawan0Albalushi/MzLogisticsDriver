import 'dart:convert';

import 'package:flutter/services.dart';

class AppStrings {
  const AppStrings(this._values);

  final Map<String, String> _values;

  static Future<AppStrings> load(String languageCode) async {
    final raw = await rootBundle.loadString('assets/i18n/$languageCode.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AppStrings(
      decoded.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  String t(String key, [Map<String, String>? params]) {
    var value = _values[key] ?? key;
    if (params != null) {
      params.forEach((name, replacement) {
        value = value.replaceAll('{$name}', replacement);
      });
    }
    return value;
  }
}
