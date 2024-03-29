import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../generated/locale_keys.g.dart';
import '../view/CreateProfilePage/CreateProfilePage.dart';
import 'constants.dart';

Future<void> showOnBoardAlert(BuildContext context) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
            padding: EdgeInsets.only(
                top: 10.0, right: 10.0, left: 10.0, bottom: 5.0),
            child: Text(
              LocaleKeys.pass_alert_text.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).hoverColor,
                  fontFamily: 'MyriadPro',
                  fontSize: textSize14),
            )),
        actions: <Widget>[
          Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Divider(
                      height: 1.0, color: Theme.of(context).hoverColor)),
              SizedBox(height: 5.0),
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => CreateProfilePage(
                                      welcome: Text(
                                        LocaleKeys.welcome.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: textSize45,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                      ),
                                      passPrefer: 3,
                                      passwordRemind: false,
                                      confirmPasswordField: false,
                                      passwordField: false,
                                    )),
                            (Route<dynamic> route) => false);
                      },
                      child: Container(
                          width: 100.0,
                          height: 20.0,
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
                      width: 25.0,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                          width: 100.0,
                          height: 20.0,
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
              SizedBox(
                height: 10.0,
              )
            ],
          ))
        ],
      );
    },
  );
}
