import 'package:flutter/material.dart';

class ThemeModeController {
  ThemeModeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  static void changer(ThemeMode nouveauMode) {
    mode.value = nouveauMode;
  }
}
