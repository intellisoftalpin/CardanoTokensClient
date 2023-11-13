import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/RestorePages/ThirdRestoreScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../app.dart';
import '../../bloc/CloseDbBloc/CloseDbBloc.dart';
import '../../bloc/ProfileBloc/ProfileBloc.dart';
import '../../data/database/DbProvider.dart';
import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../../data/dbhive/ProfileModel.dart';
import '../../data/repository/ApiRepository/ApiRepository.dart';
import '../../data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import '../../utils/auth_restore_alert_replace.dart';
import '../../utils/hash_pass.dart';
import '../AppAuth/LocalAuthApi.dart';
import '../splash/view/splash_page.dart';
import 'package:crypto_offline/app.dart' as app;
import '../../app.dart' as recovery;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/view/RestorePages/FirstRestoreScreen.dart'
    as lastProfile;
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;

class SecondRestoreScreen extends StatefulWidget {
  final String error;

  const SecondRestoreScreen({Key? key, required this.error}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => SecondRestoreScreen(error: ''));
  }

  @override
  State<SecondRestoreScreen> createState() => _SecondRestoreScreenState();
}

class _SecondRestoreScreenState extends State<SecondRestoreScreen> {
  static List<ProfileModel> profile = [];
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    app.dismissLifecycle = false;
    return WillPopScope(
        onWillPop: () async {
          recovery.recoveryPath = null;
          global.idProfile = lastProfile.lastProfileId!;
          ReceiveSharingIntent.reset();
          BlocProvider.of<CloseDbBloc>(this.context)
            ..add(UpdateProfile(idProfile: lastProfile.dbRecoveryName!));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => App()),
              (Route<dynamic> route) => false);
          return true;
        },
        child: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>(
                create: (context) => ProfileBloc(
                    DatabaseProvider(),
                    SharedPrefProfileRepositoryImpl(),
                    HivePrefProfileRepositoryImpl(),
                    ApiRepository()),
              ),
            ],
            child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
              switch (state.state) {
                case ProfileStatus.start:
                  print('start');
                  context.read<ProfileBloc>().add(CreateProfile());
                  return SplashPage();
                case ProfileStatus.loading:
                  print('loading');
                  return Scaffold(
                      backgroundColor: Theme.of(context).dividerColor,
                      appBar: null,
                      body: Container(
                          child: SingleChildScrollView(
                              child: Column(children: [
                        Container(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? konBoardBGColor
                              : lonBoardBGColor,
                          height: 50.0,
                        ),
                        Container(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? konBoardBGColor
                                    : lonBoardBGColor,
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 15.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).dividerColor,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(20.0),
                                      topRight: const Radius.circular(20.0),
                                    )),
                                child: Text(LocaleKeys.recovery.tr(),
                                    style: TextStyle(
                                        color: Theme.of(context).focusColor,
                                        fontFamily: 'MyriadPro',
                                        fontWeight: FontWeight.bold,
                                        fontSize: textSize22)))),
                        SizedBox(
                          height: 50.0,
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Text(LocaleKeys.enter_pass_recovery.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).focusColor,
                                    fontFamily: 'MyriadPro',
                                    fontSize: textSize17))),
                        SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                            child: Container(
                                margin: EdgeInsets.only(top: 40),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration:
                                      kFieldPassInputPassDecoration(context)
                                          .copyWith(
                                              hintText: (widget.error == '')
                                                  ? LocaleKeys.password.tr()
                                                  : ''),
                                  style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      fontFamily: 'MyriadPro',
                                      fontSize: textSize20),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(widget.error,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: textSize14, color: kErrorColor)),
                          ),
                        ),
                        SizedBox(
                          height: 70.0,
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              color: Theme.of(context).secondaryHeaderColor,
                              child: MaterialButton(
                                minWidth: MediaQuery.of(context).size.width / 3,
                                padding:
                                    EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                                onPressed: () {
                                  //global.idProfile = lastProfile.dbRecoveryName!;
                                  globals.pass = passwordController.text;
                                  if (passwordController.text.isEmpty) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SecondRestoreScreen(
                                                    error: LocaleKeys
                                                        .invalid_alert_pass
                                                        .tr())),
                                        (Route<dynamic> route) => true);
                                  } else {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SecondRestoreScreen(
                                                    error: LocaleKeys
                                                        .incorrect_password_try_again
                                                        .tr())),
                                        (Route<dynamic> route) => true);
                                  }
                                },
                                child: Text(
                                  LocaleKeys.ok.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).shadowColor,
                                      fontFamily: 'MyriadPro',
                                      fontSize: textSize20),
                                ),
                              ),
                            )),
                      ]))));
                case ProfileStatus.load:
                  print('load');
                  return SplashPage();
                case ProfileStatus.loaded:
                  print('loaded');
                  global.idProfile = lastProfile.lastProfileId!;
                  profile = state.profile;
                  Widget profiles = SizedBox.shrink();
                  if (profile.isEmpty) {
                    profiles = Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      child: Text(LocaleKeys.create_port_recovery.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize19)),
                    );
                  } else if (profile.isNotEmpty) {
                    profiles = Column(children: [
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(LocaleKeys.choose_port_recovery.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontFamily: 'MyriadPro',
                                  fontSize: textSize17))),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: profile.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  child: ListTile(
                                    title: new Text(
                                      profile[index].nameProfile!,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                    ),
                                    leading: new Icon(Icons.perm_identity,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                    onTap: () async {
                                      if (globals.pass ==
                                          hashPass(hashPassword).toString()) {
                                        if (mounted) {
                                          authRestoreAlertReplace(
                                              context,
                                              false,
                                              profile[index].nameProfile!,
                                              profile[index].id!);
                                        }
                                      } else {
                                        if (mounted) {
                                          authRestoreAlertReplace(
                                              context,
                                              true,
                                              profile[index].nameProfile!,
                                              profile[index].id!);
                                        }
                                      }
                                    },
                                  ));
                            }),
                      )
                    ]);
                  }
                  return Scaffold(
                      appBar: null,
                      body: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? konBoardBGColor
                                    : lonBoardBGColor,
                                height: 50.0,
                              ),
                              Container(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? konBoardBGColor
                                      : lonBoardBGColor,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(top: 15.0),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(20.0),
                                            topRight:
                                                const Radius.circular(20.0),
                                          )),
                                      child: Text(LocaleKeys.recovery.tr(),
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).focusColor,
                                              fontFamily: 'MyriadPro',
                                              fontWeight: FontWeight.bold,
                                              fontSize: textSize22)))),
                              SizedBox(
                                height: 20.0,
                              ),
                              profiles,
                              SizedBox(
                                height: 20.0,
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(top: 10.0, bottom: 10.0),
                                  child: Material(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor)),
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    child: MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width / 2,
                                      padding: EdgeInsets.fromLTRB(
                                          50.0, 8.0, 50.0, 8.0),
                                      onPressed: () {
                                        if (globals.pass ==
                                            hashPass(hashPassword).toString()) {
                                          authRestoreAlert(context, false);
                                        } else {
                                          authRestoreAlert(context, true);
                                        }
                                      },
                                      child: Text(
                                        LocaleKeys.create_new_portfolio.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).shadowColor,
                                            fontFamily: 'MyriadPro',
                                            fontSize: textSize20),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ));
                case ProfileStatus.update:
                  return SplashPage();
              }
            })));
  }

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
                          app.dismissLifecycle = true;
                          if (havePass == true) {
                            bool isAuthenticated =
                                await LocalAuthApi().authenticate();
                            print(" ::: isAuthenticated::: $isAuthenticated");
                            if (await LocalAuthApi().availableBiometric() ==
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
                            bool isAuthenticated =
                                await LocalAuthApi().authenticate();
                            if (await LocalAuthApi().availableBiometric() ==
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
}
