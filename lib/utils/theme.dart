import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';

ThemeData basicTheme() =>
    ThemeData(
      brightness: Brightness.dark,
      primaryColor: kBackgroundColor,
      primaryColorDark: kPrimaryColor,
      primaryColorLight: kPrimaryLightColor,
      secondaryHeaderColor: kSecondaryColor,
      highlightColor: kSecondaryLightColor,
      indicatorColor: kAccentColor,
      cardColor: kCardColor,
      backgroundColor: kSettingsPageBackground,
      hintColor: kTextSecondaryColor,
      canvasColor: kSettingsCardColor,
      dividerColor: kBackgroundCreateProfile,
      hoverColor: kIconColor,
      focusColor: kAppBarIconColor,
      selectedRowColor: kPlusIconColor,
      disabledColor: kTextFieldIconColor,
      shadowColor: kButtonTextColor,
      unselectedWidgetColor: kInOutTextColor,
      toggleableActiveColor: konBoardBGColor,
      splashColor: kAboutPageAppBarColor,
      scaffoldBackgroundColor: kBackgroundDetailsProfile,
      iconTheme: IconThemeData(
        color: kSecondaryColor,
        size: 25.0,
      ),
      cardTheme: CardTheme(
        color: kCardColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: Colors.transparent,
      ),
    );

ThemeData lightTheme() =>
    ThemeData(
      brightness: Brightness.light,
      primaryColor: lBackgroundColor,
      primaryColorDark: lPrimaryColor,
      primaryColorLight: lPrimaryLightColor,
      secondaryHeaderColor: lSecondaryColor,
      highlightColor: lSecondaryLightColor,
      indicatorColor: lAccentColor,
      cardColor: lCardColor,
      backgroundColor: lSettingsPageBackground,
      hintColor: lTextSecondaryColor,
      canvasColor: lSettingsCardColor,
      dividerColor: lBackgroundCreateProfile,
      hoverColor: lIconColor,
      focusColor: lAppBarIconColor,
      selectedRowColor: lPlusIconColor,
      disabledColor: lTextFieldIconColor,
      shadowColor: lButtonTextColor,
      unselectedWidgetColor: lInOutTextColor,
      toggleableActiveColor: lonBoardBGColor,
      splashColor: lAboutPageAppBarColor,
      scaffoldBackgroundColor: lBackgroundDetailsProfile,
      iconTheme: IconThemeData(
        color: lSecondaryColor,
        size: 25.0,
      ),
      cardTheme: CardTheme(
        color: lCardColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: Colors.transparent,
      ),
    );

/*
class ThemeNitifier extends ChangeNotifier {
  final String key = "theme";
  late SharedPreferences prefs;
  late bool _darkTheme;

  ThemeNitifier() {
    _darkTheme = true;
  }
  toggelTheme(){
    _darkTheme != _darkTheme;
    notifyListeners();
  }

}*/
