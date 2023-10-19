import 'package:crypto_offline/bloc/CloseDbBloc/CloseDbBloc.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/hash_pass.dart';
import 'package:crypto_offline/view/AppAuth/LocalAuthApi.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'ProfilePage.dart';

//ignore: must_be_immutable
class InputPassChangeProfPage extends StatefulWidget {
  final nameProfile;
  var teamPass;
  var error;

  InputPassChangeProfPage(this.nameProfile, this.teamPass, this.error);

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => InputPassChangeProfPage('', '', ''));
  }

  @override
  State<InputPassChangeProfPage> createState() =>
      _InputPassChangeProfPageState();
}

class _InputPassChangeProfPageState extends State<InputPassChangeProfPage> {
  bool fingerPass = false;
  int pref = 0;
  late FocusNode _focusNode;

  Stream<bool> passVisible() async* {
    bool visible = true;
    int pref = await getPassPref(global.idProfile);
    print(':::::::::::::${widget.nameProfile + global.idProfile} +  $pref');
    if (pref == 0) {
      if (fingerPass == false) {
        setState(() {
          visible = false;
        });
      } else if (fingerPass == true) {
        setState(() {
          visible = true;
        });
      }
    } else if (pref == 1) {
      setState(() {
        visible = true;
      });
    } else if (pref == 2) {
      setState(() {
        visible = false;
      });
    } else if (pref == 3) {
      setState(() {
        visible = false;
      });
    }
    yield visible;
  }

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      pref = await getPassPref(global.idProfile);
    });
    var hintTxt;
    if (widget.error.toString().isNotEmpty) {
      hintTxt = LocaleKeys.incorrect_password_try_again.tr();
    } else {
      hintTxt = LocaleKeys.password.tr();
    }
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: false,
      onKey: (event) {
        print("event = $event");
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          _pressEnterButton();
        }
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).dividerColor,
          body: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.nameProfile, //  + ' ' + nameProfile,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: textSize24,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                    Container(
                        height: 200.0,
                        child: StreamBuilder(
                          stream: passVisible(),
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasData) {
                              return Visibility(
                                  visible: snapshot.data!,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              24.0, 8.0, 24.0, 8.0),
                                          child: TextField(
                                            autofocus: true,
                                            obscureText: true,
                                            decoration:
                                                kFieldPassCreateProfileDecoration(
                                                        context)
                                                    .copyWith(
                                                        hintText: hintTxt),
                                            onChanged: (value) {
                                              widget.teamPass = value;
                                            },
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontFamily: 'MyriadPro',
                                                fontSize: textSize20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }
                            return SplashPage();
                          },
                        )),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  32.0, 8.0, 8.0, 8.0),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                color: Theme.of(context).secondaryHeaderColor,
                                child: MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 15.0),
                                  onPressed: () {
                                    if (widget.error.toString().isNotEmpty) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InputPassChangeProfPage(
                                                      widget.nameProfile,
                                                      '',
                                                      widget.error)),
                                          (Route<dynamic> route) => false);
                                    } else
                                      Navigator.of(context).pop();
                                    //SystemNavigator.pop();
                                  },
                                  child: Text(
                                    LocaleKeys.cancel.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).shadowColor,
                                        fontFamily: 'MyriadPro',
                                        fontSize: textSize20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 32.0, 8.0),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                color: Theme.of(context).secondaryHeaderColor,
                                child: MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 15.0),
                                  onPressed: () {
                                    _pressEnterButton();
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _pressEnterButton() {
    if (pref == 0) {
      if (fingerPass == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final isAuthenticated = await LocalAuthApi().authenticate();
          if (isAuthenticated) {
            setState(() {
              fingerPass = true;
            });
          }
        });
      } else if (fingerPass == true) {
        BlocProvider.of<CloseDbBloc>(context)
            .add(UpdateProfile(idProfile: global.idProfile));
        globals.nameProfile = widget.nameProfile;
        globals.pass = widget.teamPass;
        if (globals.pass.isEmpty || globals.pass == '') {
          globals.pass = hashPass(hashPassword).toString();
        }
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
            (Route<dynamic> route) => false);
      }
    } else if (pref == 1) {
      BlocProvider.of<CloseDbBloc>(context)
          .add(UpdateProfile(idProfile: global.idProfile));
      globals.nameProfile = widget.nameProfile;
      globals.pass = widget.teamPass;
      if (globals.pass.isEmpty || globals.pass == '') {
        globals.pass = hashPass(hashPassword).toString();
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false);
    } else if (pref == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isAuthenticated = await LocalAuthApi().authenticate();
        if (isAuthenticated) {
          BlocProvider.of<CloseDbBloc>(context)
              .add(UpdateProfile(idProfile: global.idProfile));
          globals.nameProfile = widget.nameProfile;
          globals.pass = hashPass(hashPassword).toString();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => false);
        }
      });
    } else if (pref == 3) {
      BlocProvider.of<CloseDbBloc>(context)
          .add(UpdateProfile(idProfile: global.idProfile));
      globals.nameProfile = widget.nameProfile;
      globals.pass = hashPass(hashPassword).toString();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false);
    }
  }
}
