import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color bnbSelectedColor = Color(0xFF000000);
Color bnbUnSelectedColor = Color(0x802D2D2D);
Color outTransactionColor = Color(0x80C34A4A);
Color inTransactionColor = Color(0x804CAF50);
Color transactionHeaderTextColor = Color(0xFF7B96B8);
Color transactionHeaderColor = Color(0xFFFBFF4D);
Color transactionInColor = Color(0xFF51A954);
Color transactionOutColor = Color(0xFFE9493F);
Color editAlertTextFieldColor = Color(0xFF9C9C9C);

//=====DARK Theme Colors:=====
Color kPrimaryColor = Color(0xFF282B30);
Color kPrimaryLightColor = Color(0xFFFFFFFF);
Color kSecondaryColor = Color(0xFFFED32C);
Color kSecondaryLightColor = Color(0xFFFCDF7C);
Color kBackgroundColor = Color(0xFF000000);
Color kAccentColor = Color(0xFFFFFFFF);
Color kSettingsCardColor = Color(0xFF353940);
Color kSettingsPageBackground = Color(0xFF20242A);
Color kBackgroundCreateProfile = Color(0xFF34383F);
Color kTextSecondaryColor = Color(0xFFC4C4C4);
Color kCardColor = Color(0xFF282B30);
Color kIconColor = Color(0xFF474747);
Color kAppBarIconColor = Color(0xFFFFFFFF);
Color kInIconColor = Color(0xFF4CAF50);
Color kOutIconColor = Color(0xFFC34A4A);
Color kPlusIconColor = Color(0xFFFED32C);
Color kTextFieldIconColor = Color(0xFFFED32C);
Color kButtonTextColor = Color(0xFF000000);
Color kInOutTextColor = Color(0xFFFFFFFF);
Color kAboutPageAppBarColor = Color(0xFF000000);
Color kBackgroundDetailsProfile = Color(0xFF34383F);
Color kErrorColor = Color(0xFF991C1C);
Color kErrorColorLight = Color(0xFFE52727);
Color kSearchTextFieldColor = Color(0xFFFED32C);
Color konBoardBGColor = Color(0xFF34383F);

//=====LIGHT Theme Colors:=====
Color lPrimaryColor = Color(0xFFE5E5E5);
Color lPrimaryLightColor = Color(0xFF20242A);
Color lSecondaryColor = Color(0xFFFED32C);
Color lSecondaryLightColor = Color(0xFFFCDF7C);
Color lBackgroundColor = Color(0xFFE5E5E5);
Color lAccentColor = Color(0xFF20242A);
Color lSettingsCardColor = Color(0xFFFFFFFF);
Color lSettingsPageBackground = Color(0xFFE5E5E5);
Color lBackgroundCreateProfile = Color(0xFFE5E5E5);
Color lTextSecondaryColor = Color(0xFFC4C4C4);
Color lCardColor = Color(0xFFFFFFFF);
Color lIconColor = Color(0xFF474747);
Color lAppBarIconColor = Color(0xFF000000);
Color lInIconColor = Color(0xFF4CAF50);
Color lOutIconColor = Color(0xFFC34A4A);
Color lPlusIconColor = Color(0xFF000000);
Color lTextFieldIconColor = Color(0xFF717479);
Color lButtonTextColor = Color(0xFF000000);
Color lInOutTextColor = Color(0xFFFFFFFF);
Color lAboutPageAppBarColor = Color(0xFFFFFFFF);
Color lBackgroundDetailsProfile = Color(0xFFFFFFFF);
Color lErrorColor = Color(0xFF991C1C);
Color lErrorColorLight = Color(0xFFE52727);
Color lSearchTextFieldColor = Color(0xFFFFFFFF);
Color lonBoardBGColor = Color(0xFFFED32C);

Color alertTransparent = Color(0x80000000);

const textSize45 = 45.0;
const textSize30 = 30.0;
const textSize25 = 25.0;
const textSize24 = 24.0;
const textSize23 = 23.0;
const textSize22 = 22.0;
const textSize21 = 21.0;
const textSize20 = 20.0;
const textSize19 = 19.0;
const textSize18 = 18.0;
const textSize17 = 17.0;
const textSize16 = 16.0;
const textSize15 = 15.0;
const textSize14 = 14.0;
const textSize13 = 13.0;
const textSize12 = 12.0;
const textSize11 = 11.0;
const textSize10 = 10.0;
const textSize9 = 9.0;
const textSize8 = 8.0;

const ProfileCoinBigText = 21.0;
const ProfileCoinMediumText = 14.0;
const ProfileCoinSmallText = 12.0;

const SettingsCardRadius = 10.0;

const MediumIcon = 35.0;
const SmallIcon = 20.0;
const hashPassword = 'EnCrypto2022!Hgqmki777%sQKMZhqPe';

InputDecoration kFieldNameEditProfileDecoration(BuildContext context) {
  InputDecoration kFieldNameEditProfileDecoration = InputDecoration(
    contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
    filled: true,
    fillColor: Theme.of(context).primaryColor,
    hintStyle: TextStyle(
      color: Color(0xFFC4C4C4),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kFieldNameEditProfileDecoration;
}

TextStyle kAppBarTextStyle(BuildContext context) {
  TextStyle kAppBarTextStyle = TextStyle(
    fontSize: textSize24,
    color: Theme.of(context).focusColor,
    fontWeight: FontWeight.w400,
    fontFamily: 'Myriad Pro',
  );
  return kAppBarTextStyle;
}

TextStyle kAppBarBackUpTextStyle(BuildContext context) {
  TextStyle kAppBarTextStyle = TextStyle(
    fontSize: textSize20,
    color: Theme.of(context).focusColor,
    fontWeight: FontWeight.w400,
    fontFamily: 'Myriad Pro',
  );
  return kAppBarTextStyle;
}

TextStyle kPrivacyAppBarTextStyle(BuildContext context) {
  TextStyle kAppBarTextStyle = TextStyle(
    fontSize: textSize18,
    color: Theme.of(context).focusColor,
    fontWeight: FontWeight.w400,
    fontFamily: 'Myriad Pro',
  );
  return kAppBarTextStyle;
}

InputDecoration kFieldPassCreateProfileDecoration(BuildContext context) {
  InputDecoration kFieldPassCreateProfileDecoration = InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    prefixIcon: Icon(
      Icons.lock_outline,
      color: Theme.of(context).disabledColor,
    ),
    hintStyle: TextStyle(
      color: Theme.of(context).disabledColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kFieldPassCreateProfileDecoration;
}

InputDecoration kFieldPassInputPassDecoration(BuildContext context) {
  InputDecoration kFieldPassCreateProfileDecoration = InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    prefixIcon: Icon(
      Icons.lock_outline,
      color: Theme.of(context).hoverColor,
    ),
    hintStyle: TextStyle(
      color: Theme.of(context).hoverColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kFieldPassCreateProfileDecoration;
}

InputDecoration kFieldNameCreateProfileDecoration(BuildContext context) {
  InputDecoration kFieldNameCreateProfileDecoration = InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    prefixIcon: Icon(
      Icons.person,
      color: Theme.of(context).disabledColor,
    ),
    hintStyle: TextStyle(
      color: Theme.of(context).disabledColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kFieldNameCreateProfileDecoration;
}

InputDecoration kTextFieldEditAlert(BuildContext context) {
  InputDecoration kTextFieldInputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0),
    hintStyle: TextStyle(
      color: Theme.of(context).secondaryHeaderColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(
          width: 2, color: editAlertTextFieldColor),
    ),
  );
  return kTextFieldInputDecoration;
}

InputDecoration kTextFieldInputDecoration(BuildContext context) {
  InputDecoration kTextFieldInputDecoration = InputDecoration(
    filled: true,
    fillColor: Theme.of(context).secondaryHeaderColor,
    contentPadding: EdgeInsets.only(bottom: 80.0, left: 20.0),
    hintStyle: TextStyle(
      color: Theme.of(context).brightness == Brightness.dark
          ? kSettingsPageBackground
          : lSettingsPageBackground,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kTextFieldInputDecoration;
}

InputDecoration kTextFieldSearchDecoration(BuildContext context) {
  InputDecoration kTextFieldInputDecoration = InputDecoration(
    filled: true,
    fillColor: Theme.of(context).cardColor,
    contentPadding: EdgeInsets.all(0.0),
    hintStyle: TextStyle(
      color: Theme.of(context).disabledColor,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kTextFieldInputDecoration;
}

InputDecoration kContainerDecoration(BuildContext context) {
  InputDecoration kContainerDecoration = InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    fillColor: Theme.of(context).secondaryHeaderColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
  );
  return kContainerDecoration;
}

Future<Widget> checkContainImage(String asset) async {
  String path = asset;
  return rootBundle.load(path).then((value) {
    return Image.memory(value.buffer.asUint8List());
  }).catchError((_) {
    return Image.asset(
      'assets/image/place_holder.png',
    );
  });
}

Future<bool> passInputVisible(int pref) async {
  bool visible = true;
  if (pref == 0) {
    visible = true;
  } else if (pref == 1) {
    visible = true;
  } else if (pref == 2) {
    visible = true;
  } else if (pref == 3) {
    visible = false;
  }
  return visible;
}
