import 'package:crypto_offline/bloc/ChangeNameProfileBloc/ChangeNameProfileBloc.dart';
import 'package:crypto_offline/utils/random_string.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bloc/ChangePassProfileBloc/ChangePassProfileBloc.dart';
import '../bloc/CloseDbBloc/CloseDbBloc.dart';
import '../bloc/CreateProfile/CreateProfileBloc.dart';
import '../data/database/DbProvider.dart';
import '../data/dbhive/HivePrefProfileRepository.dart';
import '../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../data/dbhive/ProfileModel.dart';
import '../data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import '../generated/locale_keys.g.dart';
import '../view/CreateProfilePage/CreateProfilePage.dart';
import '../view/OnBoardingPages/SecondOnBoardScreen.dart';
import '../view/ProfilePage/InputPasswordPage.dart';
import '../view/ProfilePage/InputPasswordPage.dart' as input;
import '../view/ProfilePage/ProfilePage.dart';
import 'constants.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'delete_db.dart';

Future<void> showAlertChangeName(BuildContext context, int pref) async {
  final nameController = TextEditingController();
  bool error = false;
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(LocaleKeys.edit_alert_change_name.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textSize19)),
            content: TextFormField(
              keyboardType: TextInputType.text,
              controller: nameController,
              obscureText: false,
              decoration: kTextFieldEditAlert(context).copyWith(
                  errorText: error ? LocaleKeys.invalid_alert_name.tr() : null,
                  hintText: LocaleKeys.edit_alert_change_name_new.tr(),
                  hintStyle: TextStyle(
                      fontSize: textSize15,
                      color: Theme.of(context).secondaryHeaderColor),
                  errorStyle: TextStyle(color: lErrorColorLight)),
              style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontFamily: 'MyriadPro',
                  fontSize: textSize20),
              onChanged: (value) {
                setState(() {
                  error = false;
                });
              },
            ),
            actions: <Widget>[
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    SizedBox(
                      width: 100.0,
                      height: 20.0,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    InkWell(
                      onTap: () async {
                        if (nameController.text.isEmpty ||
                            nameController.text == '') {
                          setState(() {
                            error = true;
                          });
                          return;
                        } else {
                          //await copyDB(
                          //    globals.nameProfile, nameController.text.trim());
                          // await deleteDB(globals.nameProfile);
                          BlocListener<ChangeNameProfileBloc,
                                  ChangeNameProfileState>(
                              bloc: ChangeNameProfileBloc(
                                DatabaseProvider(),
                                HivePrefProfileRepositoryImpl(),
                                globals.nameProfile,
                                nameController.text.trim(),
                              ),
                              listener: (context, state) {
                                if (state.state ==
                                    ChangeNameProfileStatus.start) {
                                  BlocProvider.of<ChangeNameProfileBloc>(
                                          context)
                                      .add(ChangeNameProfile(
                                          profile: globals.nameProfile,
                                          newProfile:
                                              nameController.text.trim()));
                                }
                              });
                          globals.nameProfile = nameController.text;
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                              (Route<dynamic> route) => false);
                        }
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
                  ])),
            ],
          );
        },
      );
    },
  );
}

Future<void> showAlertChangePass(BuildContext context) async {
  final passController = TextEditingController();
  String? error;
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(LocaleKeys.edit_alert_change_pass.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textSize19)),
            content: TextFormField(
              keyboardType: TextInputType.text,
              controller: passController,
              obscureText: true,
              decoration: kTextFieldEditAlert(context).copyWith(
                  errorText: error,
                  hintText: LocaleKeys.edit_alert_change_pass_old.tr(),
                  hintStyle: TextStyle(
                      fontSize: textSize15,
                      color: Theme.of(context).secondaryHeaderColor),
                  errorStyle: TextStyle(color: lErrorColorLight)),
              style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontFamily: 'MyriadPro',
                  fontSize: textSize20),
              onChanged: (value) {
                setState(() {
                  error = null;
                });
              },
            ),
            actions: <Widget>[
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    SizedBox(
                      width: 100.0,
                      height: 20.0,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    InkWell(
                      onTap: () {
                        if (passController.text == globals.pass) {
                          Navigator.of(context).pop(false);
                          showAlertPassConfirm(context);
                        } else if (passController.text.isNotEmpty &&
                            passController.text != globals.pass) {
                          setState(() {
                            error =
                                LocaleKeys.incorrect_password_try_again.tr();
                          });
                          return;
                        } else {
                          setState(() {
                            error = LocaleKeys.enter_password.tr();
                          });
                          return;
                        }
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
                  ]))
            ],
          );
        },
      );
    },
  );
}

Future<void> showAlertPassConfirm(BuildContext context) async {
  SharedPrefProfileRepositoryImpl _prefProfileRepository =
      SharedPrefProfileRepositoryImpl();
  bool errorFirst = false;
  bool errorSecond = false;
  String errorTextFirst = '';
  String errorTextSecond = '';
  int pref = 0;
  final passController = TextEditingController();
  final passControllerConfirm = TextEditingController();
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(LocaleKeys.edit_alert_change_pass_alert_new.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textSize19)),
            content: Container(
              height: 155.0,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passController,
                    obscureText: true,
                    decoration: kTextFieldEditAlert(context).copyWith(
                        errorText: errorFirst ? errorTextFirst : null,
                        hintText: LocaleKeys.edit_alert_change_pass_new.tr(),
                        hintStyle: TextStyle(
                            fontSize: textSize15,
                            color: Theme.of(context).secondaryHeaderColor),
                        errorStyle: TextStyle(color: lErrorColorLight)),
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontFamily: 'MyriadPro',
                        fontSize: textSize20),
                    onChanged: (value) {
                      setState(() {
                        errorFirst = false;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passControllerConfirm,
                    obscureText: true,
                    decoration: kTextFieldEditAlert(context).copyWith(
                        errorText: errorSecond ? errorTextSecond : null,
                        hintText:
                            LocaleKeys.edit_alert_change_pass_new_confirm.tr(),
                        hintStyle: TextStyle(
                            fontSize: textSize15,
                            color: Theme.of(context).secondaryHeaderColor),
                        errorStyle: TextStyle(color: lErrorColorLight)),
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontFamily: 'MyriadPro',
                        fontSize: textSize20),
                    onChanged: (value) {
                      setState(() {
                        errorSecond = false;
                      });
                    },
                  ),
                ],
              )),
            ),
            actions: <Widget>[
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    SizedBox(
                      width: 100.0,
                      height: 20.0,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    InkWell(
                      onTap: () async {
                        if (passController.text == passControllerConfirm.text &&
                            passController.text != '' &&
                            passController.text.isNotEmpty &&
                            passControllerConfirm.text != '' &&
                            passControllerConfirm.text.isNotEmpty) {
                          String newPort = globals.nameProfile;
                          String oldPort = globals.nameProfile;
                          String newIdPort = RandomString.getRandomString(10);
                          String oldIdPort = global.idProfile;
                          pref = globals.passPrefer;
                          await createBloc(oldPort, oldIdPort, newIdPort,
                              passControllerConfirm.text, pref);
                          await changePassBloc(oldIdPort, oldPort, newIdPort,
                              newPort, passControllerConfirm.text);
                          HivePrefProfileRepository _hiveProfileRepository =
                              HivePrefProfileRepositoryImpl();
                          globals.pass = passControllerConfirm.text;
                          await _prefProfileRepository.saveProfile(
                              'lastProf', newPort);
                          globals.nameProfile = newPort;
                          global.idProfile = newIdPort;
                          globals.passChosen = false;
                          Fluttertoast.showToast(
                              msg: LocaleKeys.success_change_pass.tr());
                          input.deleteProf = true;
                          await Future.delayed(
                              Duration(milliseconds: 300), () {});
                          List<ProfileModel> prof =
                              await _hiveProfileRepository.showProfile();
                          print('prof_in_alert: $prof');
                          bool mounted = true;
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => InputPasswordPage(
                                        newPort, newIdPort, '', '', prof)),
                                (Route<dynamic> route) => false);
                          }
                        } else if (passController.text.isEmpty &&
                            passControllerConfirm.text.isEmpty) {
                          setState(() {
                            errorTextFirst = LocaleKeys.invalid_alert_pass.tr();
                            errorTextSecond =
                                LocaleKeys.invalid_alert_pass.tr();
                            errorFirst = true;
                            errorSecond = true;
                          });
                          return;
                        } else if (passController.text.isEmpty &&
                            passControllerConfirm.text.isNotEmpty) {
                          setState(() {
                            errorTextFirst = LocaleKeys.invalid_alert_pass.tr();
                            errorTextSecond = '';
                            errorFirst = true;
                            errorSecond = false;
                          });
                          return;
                        } else if (passController.text.isNotEmpty &&
                            passControllerConfirm.text.isEmpty) {
                          setState(() {
                            errorTextFirst = '';
                            errorTextSecond =
                                LocaleKeys.invalid_alert_pass.tr();
                            errorFirst = false;
                            errorSecond = true;
                          });
                          return;
                        } else if (passController.text !=
                            passControllerConfirm.text) {
                          setState(() {
                            errorTextSecond =
                                LocaleKeys.invalid_alert_pass_not_equals.tr();
                            errorFirst = false;
                            errorSecond = true;
                          });
                          return;
                        }
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
                  ]))
            ],
          );
        },
      );
    },
  );
}

Future<void> showAlertDelete(BuildContext context) async {
  HivePrefProfileRepository _hiveProfileRepository =
      HivePrefProfileRepositoryImpl();
  List<ProfileModel> profile = [];
  SharedPrefProfileRepositoryImpl _prefProfileRepository =
      SharedPrefProfileRepositoryImpl();
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Text(LocaleKeys.edit_delete.tr(),
          textAlign: TextAlign.center, style: TextStyle(fontSize: textSize19)),
      content: Text(
        LocaleKeys.edit_alert_delete.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'MyriadPro', fontSize: textSize14),
      ),
      actions: <Widget>[
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child:
                    Divider(height: 1.0, color: Theme.of(context).hoverColor)),
            SizedBox(height: 10.0),
            Container(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                onTap: () async {
                  await deleteDB(global.idProfile.split("_")[0]);
                  profile = await _hiveProfileRepository.deleteGroupFrom(
                      globals.nameProfile, global.idProfile);
                  print('PROFILES:::::::::: $profile');
                  int pref = globals.passPrefer;
                  box.remove(globals.nameProfile + global.idProfile);
                  await _prefProfileRepository.delProfile('lastProf');
                  if (pref == 0) {
                    box.remove(
                        '${globals.nameProfile + global.idProfile}create_time');
                    box.remove(
                        '${globals.nameProfile + global.idProfile}enter_time');
                    box.remove('${globals.nameProfile + global.idProfile}pass');
                  }
                  if (profile.isEmpty || profile == []) {
                    box.write('onBoard', 1);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => SecondOnBoardScreen(
                                appBarBackArrow: SizedBox.shrink())),
                        (Route<dynamic> route) => false);
                  } else if (profile.isNotEmpty) {
                    BlocProvider.of<CloseDbBloc>(context)
                        .add(UpdateProfile(idProfile: profile.first.id!));
                    globals.nameProfile = profile.first.nameProfile!;
                    global.idProfile = profile.first.id!;
                    globals.passChosen = false;
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => InputPasswordPage(
                                profile.first.nameProfile,
                                profile.first.id,
                                '',
                                '',
                                profile)),
                        (Route<dynamic> route) => false);
                  }
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
                  Navigator.of(context).pop(false);
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
          ],
        ))
      ],
    ),
  );
}

Future<void> createBloc(String oldPort, String oldIdPort, String newIdPort,
    String passControllerConfirm, int pref) async {
  BlocListener<CreateProfileBloc, CreateProfileState>(
      bloc: CreateProfileBloc(
          DatabaseProvider(),
          HivePrefProfileRepositoryImpl(),
          oldPort + "+true",
          oldIdPort,
          newIdPort,
          passControllerConfirm,
          pref,
          null),
      listener: (context, state) {
        if (state.state == CreateProfileStatus.start) {
          BlocProvider.of<CreateProfileBloc>(context).add(SaveProfile(
              profile: oldPort + "+true",
              idProfile: oldIdPort,
              pass: passControllerConfirm.trim(),
              passPrefer: pref));
        }
      });
}

Future<void> changePassBloc(String oldIdPort, String oldPort, String newIdPort,
    String newPort, String passControllerConfirm) async {
  BlocListener<ChangePassProfileBloc, ChangePassProfileState>(
      bloc: ChangePassProfileBloc(
          DatabaseProvider(),
          HivePrefProfileRepositoryImpl(),
          oldIdPort,
          oldPort,
          globals.pass,
          newIdPort,
          newPort,
          passControllerConfirm,
          globals.passPrefer),
      listener: (context, state) {
        if (state.state == ChangePassProfileStatus.start) {
          BlocProvider.of<ChangePassProfileBloc>(context).add(ChangePassProfile(
              profile: oldIdPort,
              nameProfile: oldPort,
              pass: globals.pass,
              newProfilePath: newIdPort,
              newNameProfile: newPort,
              newProfilePass: passControllerConfirm,
              passPref: globals.passPrefer));
        }
      });
}
