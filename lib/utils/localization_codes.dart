import 'dart:ui' as ui;

class Util{
  static String codes () {
    final languageFromPhoneSettings = ui.window.locale.toString();
    var systemAppLanguage = '';
    if (languageFromPhoneSettings.contains('ru')){
      print("Russian");
      systemAppLanguage = 'ru';
    }else if(languageFromPhoneSettings.contains('en')){
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