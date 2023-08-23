import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../generated/locale_keys.g.dart';
import '../view/AppAuth/LocalAuthApi.dart';
import '../view/RestorePages/ThirdRestoreScreen.dart';
import 'constants.dart';

Future<void> authRestoreAlert(BuildContext context, bool havePass) async {
  print('BOOL authRestoreAlert havePass::::: $havePass');
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
            padding: EdgeInsets.only(
                top: 10.0, right: 10.0, left: 10.0, bottom: 5.0),
            child: Text(
              LocaleKeys.bio_recovery_alert.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).hoverColor,
                  fontFamily: 'MyriadPro',
                  fontSize: textSize14),
            )),
        actions: <Widget>[
          Center(
              child: Column(
            children: [
              Divider(height: 1.0, color: Theme.of(context).hoverColor),
              SizedBox(height: 10.0),
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    InkWell(
                      onTap: () async {
                        if (havePass == true) {
                          final isAuthenticated =
                              await LocalAuthApi.authenticate();
                          print(" ::: isAuthenticated::: $isAuthenticated");
                          if (await LocalAuthApi.availableBiometric() ==
                              false) {
                            Fluttertoast.showToast(
                                msg: LocaleKeys.noBiometrics.tr());
                          }
                          if (isAuthenticated) {
                            print('BOOL authRestoreAlert havePass::::: 0');
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => ThirdRestoreScreen(
                                        welcome: Text(
                                          LocaleKeys.welcome.tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: textSize45,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                        ),
                                        passPrefer: 0)),
                                (Route<dynamic> route) => false);
                          }
                        } else {
                          final isAuthenticated =
                              await LocalAuthApi.authenticate();
                          if (await LocalAuthApi.availableBiometric() ==
                              false) {
                            Fluttertoast.showToast(
                                msg: LocaleKeys.noBiometrics.tr());
                          }
                          print(" ::: isAuthenticated::: $isAuthenticated");
                          if (isAuthenticated) {
                            print('BOOL authRestoreAlert havePass::::: 1');
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => ThirdRestoreScreen(
                                        welcome: Text(
                                          LocaleKeys.welcome.tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: textSize45,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                        ),
                                        passPrefer: 2)),
                                (Route<dynamic> route) => false);
                          }
                        }
                      },
                      child: Container(
                          width: 100.0,
                          height: 25.0,
                          child: Text(
                            LocaleKeys.yes.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kInIconColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'MyriadPro',
                                fontSize: textSize18),
                          )),
                    ),
                    SizedBox(
                      width: 50.0,
                    ),
                    InkWell(
                      onTap: () async {
                        if (havePass == true) {
                          print('BOOL authRestoreAlert havePass::::: 2');
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ThirdRestoreScreen(
                                      welcome: Text(
                                        LocaleKeys.welcome.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: textSize45,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                      ),
                                      passPrefer: 1)),
                              (Route<dynamic> route) => false);
                        } else {
                          print('BOOL authRestoreAlert havePass::::: 3');
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ThirdRestoreScreen(
                                      welcome: Text(
                                        LocaleKeys.welcome.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: textSize45,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                      ),
                                      passPrefer: 3)),
                              (Route<dynamic> route) => false);
                        }
                      },
                      child: Container(
                          width: 100.0,
                          height: 25.0,
                          child: Text(
                            LocaleKeys.no.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kErrorColorLight,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'MyriadPro',
                                fontSize: textSize18),
                          )),
                    ),
                  ])),
            ],
          ))
        ],
      );
    },
  );
}
