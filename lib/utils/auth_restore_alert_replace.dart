import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../bloc/CreateProfile/CreateProfileBloc.dart';
import '../data/database/DbProvider.dart';
import '../data/dbhive/HivePrefProfileRepository.dart';
import '../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../data/dbhive/ProfileModel.dart';
import '../data/repository/ApiRepository/ApiRepository.dart';
import '../data/repository/ApiRepository/IApiRepository.dart';
import '../data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import '../generated/locale_keys.g.dart';
import '../view/ProfilePage/ProfilePage.dart';
import '../view/RestorePages/ThirdRestoreScreen.dart';
import 'constants.dart';
import 'delete_db.dart';
import 'package:crypto_offline/view/RestorePages/FirstRestoreScreen.dart'
    as recovery;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import '../../app.dart' as app;

import 'hash_pass.dart';

Future<bool> internet() async {
  IApiRepository _apiRepository = ApiRepository();
  bool internet = await _apiRepository.check();
  return internet;
}

Future<void> authRestoreAlertReplace(
    BuildContext context, bool havePass, String name, String nameId) async {
  print('NAMEE:::$name NAMEID:::$nameId');
  int pref = globals.passPrefer;
  print('PREFF:::::$pref');
  HivePrefProfileRepository _hiveProfileRepository =
      HivePrefProfileRepositoryImpl();
  List<ProfileModel> profile = [];
  SharedPrefProfileRepositoryImpl _prefProfileRepository =
      SharedPrefProfileRepositoryImpl();
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
              LocaleKeys.replace_recovery_alert.tr(),
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
                        bool connect = await internet();
                        if (connect == true) {
                          global.idProfile = recovery.dbRecoveryName!;
                          await deleteDB(name.split("_")[0]);
                          profile = await _hiveProfileRepository
                              .deleteGroupFrom(name, nameId);
                          print('PROFILES:::::::::: $profile');
                          int pref = globals.passPrefer;
                          box.remove(name + nameId);
                          await _prefProfileRepository.delProfile('lastProf');
                          if (pref == 0) {
                            box.remove('${name + nameId}create_time');
                            box.remove('${name + nameId}enter_time');
                            box.remove('${name + nameId}pass');
                          }
                          if (havePass == true) {
                            if (pref == 0 || pref == 2) {
                              //0
                              print('0_SCENARIO');
                              BlocListener<CreateProfileBloc,
                                      CreateProfileState>(
                                  bloc: CreateProfileBloc(
                                      DatabaseProvider(),
                                      HivePrefProfileRepositoryImpl(),
                                      name,
                                      global.idProfile,
                                      null,
                                      globals.pass,
                                      0,
                                      recovery.dbRecoveryName),
                                  listener: (context, state) {
                                    if (state.state ==
                                        CreateProfileStatus.start) {
                                      BlocProvider.of<CreateProfileBloc>(
                                              context)
                                          .add(SaveProfile(
                                              profile: name,
                                              idProfile: global.idProfile,
                                              pass: globals.pass,
                                              passPrefer: 0));
                                    }
                                  });
                            } else {
                              //1
                              print('1_SCENARIO');
                              BlocListener<CreateProfileBloc,
                                      CreateProfileState>(
                                  bloc: CreateProfileBloc(
                                      DatabaseProvider(),
                                      HivePrefProfileRepositoryImpl(),
                                      name,
                                      global.idProfile,
                                      null,
                                      globals.pass,
                                      1,
                                      recovery.dbRecoveryName),
                                  listener: (context, state) {
                                    if (state.state ==
                                        CreateProfileStatus.start) {
                                      BlocProvider.of<CreateProfileBloc>(
                                              context)
                                          .add(SaveProfile(
                                              profile: name,
                                              idProfile: global.idProfile,
                                              pass: globals.pass,
                                              passPrefer: 1));
                                    }
                                  });
                            }
                          } else {
                            if (pref == 0 || pref == 2) {
                              //2
                              print('2_SCENARIO');
                              BlocListener<CreateProfileBloc,
                                      CreateProfileState>(
                                  bloc: CreateProfileBloc(
                                      DatabaseProvider(),
                                      HivePrefProfileRepositoryImpl(),
                                      name,
                                      global.idProfile,
                                      null,
                                      hashPass(hashPassword).toString(),
                                      2,
                                      recovery.dbRecoveryName),
                                  listener: (context, state) {
                                    if (state.state ==
                                        CreateProfileStatus.start) {
                                      BlocProvider.of<CreateProfileBloc>(
                                              context)
                                          .add(
                                              SaveProfile(
                                                  profile: name,
                                                  idProfile: global.idProfile,
                                                  pass: hashPass(hashPassword)
                                                      .toString(),
                                                  passPrefer: 2));
                                    }
                                  });
                            } else {
                              //3
                              print('3_SCENARIO');
                              BlocListener<CreateProfileBloc,
                                      CreateProfileState>(
                                  bloc: CreateProfileBloc(
                                      DatabaseProvider(),
                                      HivePrefProfileRepositoryImpl(),
                                      name,
                                      global.idProfile,
                                      null,
                                      hashPass(hashPassword).toString(),
                                      3,
                                      recovery.dbRecoveryName),
                                  listener: (context, state) {
                                    if (state.state ==
                                        CreateProfileStatus.start) {
                                      BlocProvider.of<CreateProfileBloc>(
                                              context)
                                          .add(
                                              SaveProfile(
                                                  profile: name,
                                                  idProfile: global.idProfile,
                                                  pass: hashPass(hashPassword)
                                                      .toString(),
                                                  passPrefer: 3));
                                    }
                                  });
                            }
                          }
                          app.recoveryPath = null;
                          ReceiveSharingIntent.reset();
                          globals.nameProfile = name;
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                              (Route<dynamic> route) => false);
                        } else {
                          Fluttertoast.showToast(
                              msg: LocaleKeys.no_internet_connection.tr());
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
                      onTap: () {
                        Navigator.of(context).pop(false);
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
