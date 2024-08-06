import 'dart:io';

import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/AppAuth/LocalAuthApi.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto_offline/app.dart' as app;

import '../../utils/onBoardAlert.dart';

class SecondOnBoardScreen extends StatefulWidget {
  final Widget appBarBackArrow;

  SecondOnBoardScreen({Key? key, required this.appBarBackArrow})
      : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) =>
            SecondOnBoardScreen(appBarBackArrow: SizedBox.shrink()));
  }

  @override
  State<SecondOnBoardScreen> createState() => SecondOnBoardScreenState();

  static bool onSecondOnBoardState(bool secondOnBoardState) {
    return secondOnBoardState;
  }
}

class SecondOnBoardScreenState extends State<SecondOnBoardScreen> {
  late int _select;
  int? selectedGroup = 0;
  static bool isAuthenticateState = false;
  List<String> checks = [
    LocaleKeys.radio_first.tr(),
    LocaleKeys.radio_second.tr(),
    LocaleKeys.radio_third.tr(),
    LocaleKeys.radio_fourth.tr()
  ];

  @override
  void initState() {
    setState(() {
      _select = 0;
    });
    super.initState();
  }

  @override
  void dispose() {
    ProfilePageState.isCreateNewPortfolio = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      const SystemUiOverlayStyle systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: null,
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? konBoardBGColor
                      : lonBoardBGColor,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Stack(children: [
                    Container(
                        margin: EdgeInsets.only(top: 30.0),
                        alignment: Alignment.topCenter,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Image.asset(
                          'assets/icons/second_onboard.png',
                          alignment: Alignment.center,
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 40.0),
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.topLeft,
                        child: widget.appBarBackArrow)
                  ])),
              Container(
                child: Column(children: [
                  Stack(children: [
                    Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? konBoardBGColor
                          : lonBoardBGColor,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 25.0,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            )),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: 25.0,
                        child: Text(
                          LocaleKeys.security_intro.tr(),
                          style: TextStyle(
                            fontSize: textSize22,
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                  ]),
                  Container(
                      margin: EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
                      child: Text(LocaleKeys.onboard_second_text.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize14))),
                  Container(
                      margin: EdgeInsets.only(top: 1.0, bottom: 1.0),
                      child: Divider(
                          height: 0.4,
                          color: Theme.of(context)
                              .cardTheme
                              .copyWith(
                                  color:
                                      Theme.of(context).unselectedWidgetColor)
                              .color)),
                  Container(
                      margin: EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
                      child: Text(LocaleKeys.security_measure.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontFamily: 'MyriadPro',
                              fontWeight: FontWeight.bold,
                              fontSize: textSize18))),
                  Container(
                    height: 200.0,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: checks.length,
                        itemBuilder: (context, index) {
                          return Container(
                              height: 50.0,
                              child: Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      disabledColor: Theme.of(context)
                                          .secondaryHeaderColor),
                                  child: RadioListTile(
                                    activeColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    value: index,
                                    groupValue: selectedGroup,
                                    onChanged: (int? val) {
                                      setState(() => selectedGroup = val);
                                      _select = index;
                                      if (index == 3) {
                                        showOnBoardAlert(context);
                                      }
                                    },
                                    title: Text(checks[index],
                                        style: TextStyle(
                                          fontSize: textSize14,
                                          color: Theme.of(context).focusColor,
                                        )),
                                  )));
                        }),
                  ),
                  Container(
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/dollar_dark.png',
                            alignment: Alignment.center,
                            height: 20.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Image.asset(
                            'assets/icons/dollar_light.png',
                            alignment: Alignment.center,
                            height: 20.0,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor)),
                        color: Theme.of(context).secondaryHeaderColor,
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width / 3,
                          padding: EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                          onPressed: () {
                            ///0 - Master password and Fingerprint/FaceID (recommended)
                            ///1 - Master password only (the most secure)
                            ///2 - Fingerprint/FaceID (trade-off option)
                            ///3 - I have nothing to worry about
                            if (_select == 0) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                final isAuthenticated =
                                    await LocalAuthApi().authenticate();
                                if (await LocalAuthApi().availableBiometric() ==
                                    false) {
                                  Fluttertoast.showToast(
                                      msg: LocaleKeys.noBiometrics.tr());
                                }
                                print(
                                    " ::: isAuthenticated::: $isAuthenticated");
                                if (isAuthenticated) {
                                  isAuthenticateState = true;
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateProfilePage(
                                                  welcome: Text(
                                                    LocaleKeys.welcome.tr(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: textSize45,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor),
                                                  ),
                                                  passPrefer: 0,
                                                  passwordRemind: true,
                                                  confirmPasswordField: true,
                                                  passwordField: true,
                                                )),
                                        (Route<dynamic> route) => true);
                                  });
                                }
                              });
                            } else if (_select == 1) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => CreateProfilePage(
                                            welcome: Text(
                                              LocaleKeys.conf_pass.tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: textSize18,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                            ),
                                            passPrefer: 1,
                                            passwordRemind: true,
                                            confirmPasswordField: true,
                                            passwordField: true,
                                          )),
                                  (Route<dynamic> route) => false);
                            } else if (_select == 2) {
                              app.dismissLifecycle = true;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                final isAuthenticated =
                                    await LocalAuthApi().authenticate();
                                if (await LocalAuthApi().availableBiometric() ==
                                    false) {
                                  Fluttertoast.showToast(
                                      msg: LocaleKeys.noBiometrics.tr());
                                }
                                if (isAuthenticated) {
                                  isAuthenticateState = true;
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateProfilePage(
                                                welcome: Text(
                                                  LocaleKeys.welcome.tr(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: textSize45,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor),
                                                ),
                                                passPrefer: 2,
                                                passwordRemind: false,
                                                confirmPasswordField: false,
                                                passwordField: false,
                                              )),
                                      (Route<dynamic> route) => false);
                                }
                              });
                            } else if (_select == 3) {
                              showOnBoardAlert(context);
                            }
                          },
                          child: Text(
                            LocaleKeys.next.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).shadowColor,
                                fontFamily: 'MyriadPro',
                                fontSize: textSize20),
                          ),
                        ),
                      )),
                ]),
              )
            ],
          )),
        ));
  }
}
