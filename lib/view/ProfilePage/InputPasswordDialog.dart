import 'package:crypto_offline/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';

class InputPasswordDialog extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => InputPasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.portfolio.tr() + ' $nameProfile'),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            autofocus: true,
            obscureText: true,
            decoration: new InputDecoration(
                labelText: LocaleKeys.enter_password.tr(),
                hintText: LocaleKeys.password.tr()),
            onChanged: (value) {
              globals.pass = '';
              globals.pass = value;
            },
          ))
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(LocaleKeys.cancel.tr()),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateProfilePage(
                          confirmPasswordField: true,
                          passwordField: true,
                          passwordRemind: true,
                          passPrefer: 1,
                          welcome: Text(
                            LocaleKeys.conf_pass.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                    fontSize: textSize18,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                          ),
                        )));
          },
        ),
        TextButton(
          child: Text(LocaleKeys.ok.tr()),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
      ],
    );
  }
}
