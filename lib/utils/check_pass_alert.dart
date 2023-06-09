import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

showLockAlert(BuildContext context, Widget page) {
  AlertDialog alert = AlertDialog(
    backgroundColor: Theme.of(context).primaryColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
    contentPadding: const EdgeInsets.only(bottom: 0.0),
    content: Center(
      heightFactor: 1.0,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).hintColor,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              Center(
                  child: Text(LocaleKeys.pass_alert_text.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize18,
                        color: Theme.of(context).focusColor,
                      ))),
              Container(
                margin: EdgeInsets.only(
                    top: 15.0, bottom: 7.5, left: 15.0, right: 15.0),
                alignment: Alignment.center,
                height: 35.0,
                width: 90.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).secondaryHeaderColor),
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => page),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(LocaleKeys.con.tr(),
                      style: TextStyle(
                        fontSize: textSize18,
                        color: Theme.of(context).shadowColor,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: 7.5, bottom: 15.0, left: 15.0, right: 15.0),
                alignment: Alignment.center,
                height: 35.0,
                width: 90.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).secondaryHeaderColor),
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(LocaleKeys.cancel.tr(),
                      style: TextStyle(
                        fontSize: textSize18,
                        color: Theme.of(context).shadowColor,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return alert;
    },
  );
}
