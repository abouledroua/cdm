import 'package:cdm/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LocalProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  LocalProvider() {
    _locale = Locale('ar');
  }

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) {
      _locale = Locale('ar');
    }
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
