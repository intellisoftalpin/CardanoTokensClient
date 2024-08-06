import 'dart:async';
import 'dart:convert';

import 'package:crypto_offline/data/repository/SharedPreferences/ISharedPreferencesRepository.dart';
import 'package:crypto_offline/data/repository/SharedPreferences/SharedPreferencesRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {

  final Locale locale;
  late ISharedPreferencesRepository _sharedPrefRepository;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static late  Map<String, String> localizedStrings;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {

    String jsonString =
      await rootBundle.loadString('lib/assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    _sharedPrefRepository = SharedPreferencesRepository();
    _sharedPrefRepository.setLocalizedStrings(localizedStrings);

    return true;
  }

  String? translate(String key) {
    return localizedStrings[key];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

}