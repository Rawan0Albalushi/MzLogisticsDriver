import 'package:flutter/material.dart';

class Breakpoints {
  const Breakpoints._();

  static const double compact = 760;
  static const double frameMaxWidth = 560;

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= compact;
  }
}
