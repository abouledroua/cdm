import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
    const Locale('fr')
  ];
  static String getLanguage(String code) {
    switch (code) {
      case "ar":
        return ("العربية");
      case "fr":
        return ("Français");
      case "en":
        return ("English");
      default:
        return "";
    }
  }
}
