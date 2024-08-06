import 'package:flutter/material.dart';

class Util{
  static String codes(BuildContext context) {
    final languageFromPhoneSettings = View.of(context).platformDispatcher.locale;
    var systemAppLanguage = '';
    if (languageFromPhoneSettings.languageCode.contains('ru')){
      print("Russian");
      systemAppLanguage = 'ru';
    }else if(languageFromPhoneSettings.languageCode.contains('en')){
      print("English");
      systemAppLanguage = 'en';
    }else{
      print("Unknown");
      systemAppLanguage = 'en';
    }
    print("SystemLocale - $systemAppLanguage");
    return systemAppLanguage;
  }
}