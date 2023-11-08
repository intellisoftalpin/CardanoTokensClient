import 'dart:async';
import 'dart:io' show Platform;

import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/hash_pass.dart';
import 'package:crypto_offline/view/AppAuth/LocalAuthApi.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/app.dart' as app;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../data/dbhive/HivePrefProfileRepository.dart';
import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../../utils/check_create_profile_time.dart';
import 'ProfilePage.dart';

bool passIsEmpty = false;
bool deleteProf = false;

//ignore: must_be_immutable
class InputPasswordPage extends StatefulWidget {
  var nameProfile;
  var idProfile;
  var teamName;
  var error;
  final List<ProfileModel> profileExists;

  InputPasswordPage(this.nameProfile, this.idProfile, this.teamName, this.error,
      this.profileExists);

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => InputPasswordPage('', '', '', '', []));
  }

  @override
  State<InputPasswordPage> createState() => InputPasswordPageState();
}

class InputPasswordPageState extends State<InputPasswordPage> {
  List<ProfileModel> profileExist = [];
  String _name = '';
  String _nameId = '';
  bool fingerPass = false;
  static bool isAuthenticate = false;
  int prefGlob = 5;
  DateTime? profileCreateDate;
  DateTime? profileEnterDate;
  int? createDate;
  int? enterDate;
  Widget passRemember = SizedBox.shrink();
  bool buttonVisible = true;
  bool onSelect = false;
  bool keyBoardOpened = false;
  Widget backArrow = SizedBox.shrink();
  bool? deviceIPAD;
  var hintTxt = '';
  var errorTxt = '';
  String textError = '';

  //bool passChosen = false;

  late StreamController<String> passwordStreamController;

  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordControllerAuth = new TextEditingController();

  void getProfilesAfterChangePass() async {
    deleteProf = false;
    profileExist = widget.profileExists;
    setState(() {});
  }

  void getProfiles() async {
    HivePrefProfileRepository _hiveProfileRepository =
        HivePrefProfileRepositoryImpl();
    profileExist = await _hiveProfileRepository.showProfile();
    print('getProfiles() async');
    print('profileExist async: $profileExist');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (deleteProf == true) {
      getProfilesAfterChangePass();
    } else {
      getProfiles();
    }
    textError = widget.error;
    passwordStreamController = StreamController<String>.broadcast();
    passwordController.addListener(() {
      passwordStreamController.sink.add(passwordController.text.trim());
    });
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        deviceIPAD = await isIpad();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    passwordStreamController.close();
  }

  bool passVisible() {
    bool visible = true;

    if (_name == '' || _name.isEmpty) {
      _name = widget.nameProfile;
      _nameId = widget.idProfile;
    }

    if (widget.nameProfile.isEmpty || widget.nameProfile == '') {
      _name = globals.nameProfile;
      _nameId = global.idProfile;
    }

    if (globals.nameProfile.isEmpty ||
        globals.nameProfile == '' && profileExist.isNotEmpty) {
      _name = profileExist.first.nameProfile!;
      _nameId = profileExist.first.id!;
    }

    if (onSelect) {
      _name = globals.nameProfile;
      _nameId = global.idProfile;
      errorTxt = '';
      onSelect = false;
    }
    print(
        "passVisible _name = $_name, _nameId = $_nameId onSelect = $onSelect");
    if (prefGlob == 0) {
      createDate = box.read('${_name + _nameId}create_time');
      enterDate = box.read('${_name + _nameId}enter_time');
      DateTime now = DateTime.now();
      int createTime = now.millisecondsSinceEpoch;
      profileCreateDate =
          DateTime.fromMillisecondsSinceEpoch(createDate ?? createTime);
      profileEnterDate =
          DateTime.fromMillisecondsSinceEpoch(enterDate ?? createTime);
      print('TIIIIMEEEE::::::: $profileCreateDate;   $profileEnterDate');
      print(
          'PROFILE CHECK::::::${createTimeCheck(profileCreateDate!, profileEnterDate!)}');
      print('::::::!!!! _nameId = $_nameId');
    }
    switch (prefGlob) {
      case 0:
        if (createTimeCheck(profileCreateDate!, profileEnterDate!)) {
          box.remove('${_name + _nameId}pass');
          if (fingerPass == false) {
            visible = false;
          } else if (fingerPass == true) {
            passRemember = SizedBox.shrink();
            visible = true;
          }
        } else if (!createTimeCheck(profileCreateDate!, profileEnterDate!)) {
          visible = false;
        }
        break;
      case 1:
        visible = true;
        break;
      case 2:
        visible = false;
        break;
      case 3:
        visible = false;
        break;
    }
    return visible;
  }

  Widget chooseAuth() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Divider(
              height: 0.4,
              color: Theme.of(context)
                  .cardTheme
                  .copyWith(color: Theme.of(context).focusColor)
                  .color),
          SizedBox(height: 30.0),
          Text(
            LocaleKeys.auth_with.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: textSize25),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 40.0, bottom: 5.0),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(
                        children: [
                          Container(
                              height: 90.0,
                              width: 90.0,
                              child: RawMaterialButton(
                                onPressed: () async {
                                  final isAuthenticated =
                                      await LocalAuthApi().authenticate();
                                  if (await LocalAuthApi()
                                          .availableBiometric() ==
                                      false) {
                                    Fluttertoast.showToast(
                                        msg: LocaleKeys.noBiometrics.tr());
                                  }
                                  if (isAuthenticated) {
                                    globals.nameProfile = _name;
                                    global.idProfile = _nameId;
                                    print('!!!$_name!!! $_nameId');
                                    //globals.pass = widget.teamName;
                                    globals.pass =
                                        box.read('${_name + _nameId}pass');
                                    print(
                                        "!!!NAME:::::${globals.nameProfile}!!!PASS:::::${globals.pass}!!!");
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfilePage()),
                                        (Route<dynamic> route) => false);
                                  }
                                },
                                fillColor:
                                    Theme.of(context).secondaryHeaderColor,
                                shape: CircleBorder(),
                                child: Icon(
                                  Icons.fingerprint,
                                  size: Theme.of(context)
                                      .iconTheme
                                      .copyWith(size: 65.0)
                                      .size,
                                  color: Theme.of(context).shadowColor,
                                ),
                              )),
                          Container(
                            height: 50.0,
                            margin: EdgeInsets.only(top: 10.0),
                            alignment: Alignment.center,
                            child: Text(
                              LocaleKeys.auth_biometric.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: textSize18),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      final isAuthenticated =
                          await LocalAuthApi().authenticate();
                      if (await LocalAuthApi().availableBiometric() == false) {
                        Fluttertoast.showToast(
                            msg: LocaleKeys.noBiometrics.tr());
                      }
                      if (isAuthenticated) {
                        isAuthenticate = true;
                        globals.nameProfile = _name;
                        print('!!!$_name!!!');
                        //globals.pass = widget.teamName;
                        globals.pass = box.read('${_name}pass');
                        print(
                            "!!!NAME:::::${globals.nameProfile}!!!PASS:::::${globals.pass}!!!");
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                            (Route<dynamic> route) => false);
                      }
                    },
                  ),
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 40.0, bottom: 5.0),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(
                        children: [
                          Container(
                              height: 90.0,
                              width: 90.0,
                              child: RawMaterialButton(
                                onPressed: () {
                                  setState(() {
                                    globals.passChosen = true;
                                    backArrow = IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        size: 35.0,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      onPressed: () => {
                                        setState(() {
                                          textError = '';
                                          errorTxt = '';
                                          globals.passChosen = false;
                                          backArrow = SizedBox.shrink();
                                        })
                                      },
                                    );
                                  });
                                },
                                fillColor:
                                    Theme.of(context).secondaryHeaderColor,
                                shape: CircleBorder(),
                                child: Icon(
                                  Icons.lock_outline,
                                  size: Theme.of(context)
                                      .iconTheme
                                      .copyWith(size: 55.0)
                                      .size,
                                  color: Theme.of(context).shadowColor,
                                ),
                              )),
                          Container(
                            height: 50.0,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10.0),
                            child: Text(
                              LocaleKeys.auth_pass.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: textSize18),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        textError = '';
                        globals.passChosen = true;
                        backArrow = IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 35.0,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          onPressed: () => {
                            setState(() {
                              textError = '';
                              errorTxt = '';
                              globals.passChosen = false;
                              backArrow = SizedBox.shrink();
                            })
                          },
                        );
                      });
                    },
                  )
                ],
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    app.dismissLifecycle = false;
    print('ERROR::::: ${textError.toString()}');
    print('TIME:::::: $profileCreateDate');
    print('KEY_BOARD OPENED:::::: ${MediaQuery.of(context).viewInsets.bottom}');
    print('SCREEN_HEIGHT:::::: ${MediaQuery.of(context).size.height}');
    print('SCREEN_WIDTH:::::: ${MediaQuery.of(context).size.width}');
    if (MediaQuery.of(context).viewInsets.bottom != 0.0 &&
        MediaQuery.of(context).size.height < 700) {
      keyBoardOpened = true;
    } else {
      keyBoardOpened = false;
    }
    Widget chooseFingerOrPass = Container(
      height: !keyBoardOpened ? 200.0 : 100.0,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/input_pass.svg',
        alignment: Alignment.center,
      ),
    );
    if (_name == '' || _name.isEmpty) {
      _name = widget.nameProfile;
      _nameId = widget.idProfile;
    }

    if (widget.nameProfile.isEmpty || widget.nameProfile == '') {
      _name = globals.nameProfile;
      _nameId = global.idProfile;
    }

    if (globals.nameProfile.isEmpty ||
        globals.nameProfile == '' && profileExist.isNotEmpty) {
      _name = profileExist.first.nameProfile!;
      _nameId = profileExist.first.id!;
    }

    if (onSelect) {
      _name = globals.nameProfile;
      _nameId = global.idProfile;
      errorTxt = '';
      //onSelect = false;
    }

    print('profileExist: $profileExist');
    if (prefGlob == 5) {
      if (profileExist.length == 1) {
        print('1');
        setState(() {
          prefGlob = profileExist.first.pref!;
        });
      } else {
        print('2');
        print('_nameId: $_nameId');
        for (var data in profileExist) {
          print('data.id in list: ${data.id}');
          if (data.id == _nameId) {
            print('data.id: ${data.id}');
            print('data.pref: ${data.pref}');
            setState(() {
              prefGlob = data.pref!;
            });
          }
        }
      }
    }

    if (globals.pass.isEmpty || globals.pass == '') {
      errorTxt = '';
      textError = '';
    }

    if (textError != '') {
      errorTxt = LocaleKeys.incorrect_password_try_again.tr();
    } else {
      hintTxt = LocaleKeys.password.tr();
    }

    if (passIsEmpty) {
      errorTxt = LocaleKeys.password_is_empty.tr();
    }

    print(
        "!!!! _name!!!! = $_name, nameProfile = $nameProfile _nameId = $_nameId, passIsEmpty = $passIsEmpty");
    print("!!!!pref!!!! = $prefGlob");
    int pref = prefGlob;
    if (pref == 0) {
      createDate = box.read('${_name + _nameId}create_time');
      enterDate = box.read('${_name + _nameId}enter_time');
      profileCreateDate = DateTime.fromMillisecondsSinceEpoch(createDate!);
      profileEnterDate = DateTime.fromMillisecondsSinceEpoch(enterDate!);
      print('DATE:::::${_name + _nameId}enter_time');
    }
    if (pref == 0 &&
        fingerPass == false &&
        createTimeCheck(profileCreateDate!, profileEnterDate!)) {
      buttonVisible = true;
      passRemember = errorTxt == ''
          ? Container(
              margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              child: Text(
                LocaleKeys.check_remember_pass.tr(),
                style: TextStyle(
                    fontSize: textSize18, fontWeight: FontWeight.bold),
              ))
          : Container(
              margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              child: Text(
                errorTxt,
                style: TextStyle(
                    fontSize: textSize18, fontWeight: FontWeight.bold),
              ));
    }
    if (pref == 0 && !createTimeCheck(profileCreateDate!, profileEnterDate!)) {
      chooseFingerOrPass = chooseAuth();
      print('AUTH_WIDGET');
      buttonVisible = false;
    }
    if (pref == 3) {
      chooseFingerOrPass = Container(
        height: !keyBoardOpened ? 200.0 : 100.0,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/input_pass.svg',
          alignment: Alignment.center,
        ),
      );
    }
    if (pref == 0 &&
        !createTimeCheck(profileCreateDate!, profileEnterDate!) &&
        globals.passChosen) {
      buttonVisible = false;
      backArrow = IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 35.0,
          color: Theme.of(context).secondaryHeaderColor,
        ),
        onPressed: () => {
          setState(() {
            textError = '';
            errorTxt = '';
            globals.passChosen = false;
            backArrow = SizedBox.shrink();
          })
        },
      );
      chooseFingerOrPass = Container(
          height: 500,
          child: Column(
            children: [
              Container(
                height: !keyBoardOpened ? 200.0 : 100.0,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/input_pass.svg',
                  alignment: Alignment.center,
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                        child: StreamBuilder(
                            stream: passwordStreamController.stream,
                            builder: (context, snapshot) {
                              return TextField(
                                onSubmitted: (value) {
                                  if (passwordController.text.isEmpty ||
                                      passwordController.text == '') {
                                    passIsEmpty = true;
                                  } else {
                                    passIsEmpty = false;
                                  }
                                  _getPressEnterButton();
                                  textError = '';
                                },
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                controller: passwordControllerAuth,
                                obscureText: true,
                                decoration:
                                    kFieldPassInputPassDecoration(context)
                                        .copyWith(hintText: hintTxt),
                                onChanged: (value) async {
                                  widget.teamName = value;
                                  textError = '';
                                },
                                style: TextStyle(
                                    color: Theme.of(context).disabledColor,
                                    fontFamily: 'MyriadPro',
                                    fontSize: textSize20),
                              );
                            }),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Text(
                            (pref == 0 &&
                                    createTimeCheck(
                                        profileCreateDate!, profileEnterDate!))
                                ? ''
                                : errorTxt,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: textSize14, color: kErrorColor)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40.0,
                margin: EdgeInsets.only(
                    top: (deviceIPAD != null && deviceIPAD == true)
                        ? 90.0
                        : (MediaQuery.of(context).viewInsets.bottom != 0.0)
                            ? 5.0
                            : 90.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                  child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor)),
                      color: Theme.of(context).secondaryHeaderColor,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: () async {
                          textError = '';
                          globals.passChosen = true;
                          globals.nameProfile = _name;
                          global.idProfile = _nameId;
                          //globals.pass = widget.teamName;
                          globals.pass = passwordControllerAuth.text;
                          if (passwordControllerAuth.text.isEmpty ||
                              passwordControllerAuth.text == '') {
                            passIsEmpty = true;
                          } else {
                            passIsEmpty = false;
                          }
                          print(
                              "!!!NAME:::::${globals.nameProfile}!!!PASS:::::${globals.pass}!!!");
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                              (Route<dynamic> route) => false);
                        },
                        child: Text(
                          LocaleKeys.ok.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).shadowColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize20),
                        ),
                      )),
                ),
              ),
            ],
          ));
    }
    Widget passWidget = Visibility(
        visible: passVisible(),
        child: Container(
          child: Column(children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                      child: StreamBuilder(
                          stream: passwordStreamController.stream,
                          builder: (context, snapshot) {
                            return Container(
                                margin: EdgeInsets.only(
                                    top: !keyBoardOpened ? 40 : 10),
                                child: TextField(
                                  onSubmitted: (value) {
                                    if (passwordController.text.isEmpty ||
                                        passwordController.text == '') {
                                      passIsEmpty = true;
                                    } else {
                                      passIsEmpty = false;
                                    }
                                    _getPressEnterButton();
                                    textError = '';
                                  },
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration:
                                      kFieldPassInputPassDecoration(context)
                                          .copyWith(hintText: hintTxt),
                                  onChanged: (value) async {
                                    widget.teamName = value;
                                    textError = '';
                                  },
                                  style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      fontFamily: 'MyriadPro',
                                      fontSize: textSize20),
                                ));
                          }),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Text(
                          (pref == 0 &&
                                  createTimeCheck(
                                      profileCreateDate!, profileEnterDate!))
                              ? ''
                              : errorTxt,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: textSize14, color: kErrorColor)),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ));
    return Scaffold(
      backgroundColor: Theme.of(context).dividerColor,
      body: WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return true;
          },
          child: SingleChildScrollView(
              child: Container(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Stack(children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: !keyBoardOpened ? 50 : 20),
                    height: 110,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(32.0, 2.0, 32.0, 2.0),
                            child: Column(
                              children: [
                                Text(
                                  LocaleKeys.portfolio.tr(),
                                  // + ' ' + _name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: textSize17,
                                      color: Theme.of(context).focusColor),
                                  key: UniqueKey(),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('  '),
                                    Flexible(
                                      child: Text(
                                        _name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: textSize22,
                                            color: Theme.of(context).focusColor,
                                            fontWeight: FontWeight.bold),
                                        key: UniqueKey(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PopupMenuButton<ProfileModel>(
                                        offset: const Offset(0, 0),
                                        icon: Icon(Icons.arrow_drop_down,
                                            color:
                                                Theme.of(context).focusColor),
                                        itemBuilder: (context) {
                                          return profileExist.map((item) {
                                            return PopupMenuItem<ProfileModel>(
                                              value: item,
                                              child: ListTile(
                                                title: Text(
                                                  item.nameProfile!,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .focusColor,
                                                      fontSize: textSize24),
                                                ),
                                              ),
                                            );
                                          }).toList();
                                        },
                                        onSelected: (item) {
                                          passwordController.clear();
                                          passwordControllerAuth.clear();
                                          setState(() {
                                            globals.passChosen = false;
                                            onSelect = true;
                                            _name = item.nameProfile!;
                                            _nameId = item.id!;
                                            nameProfile = _name;
                                            globals.nameProfile = _name;
                                            global.idProfile = _nameId;
                                            globals.pass = '';
                                            passIsEmpty = false;
                                            int pref = item.pref!;
                                            prefGlob = item.pref!;
                                            print(
                                                "press pref = $pref,  _name = $_name , _nameId = $_nameId onSelect = $onSelect,"
                                                "globals.nameProfile = ${globals.nameProfile}, global.idProfile = ${global.idProfile}");
                                            passRemember = SizedBox.shrink();
                                            if (pref != 0) {
                                              buttonVisible = true;
                                              chooseFingerOrPass = Container(
                                                height: !keyBoardOpened
                                                    ? 200.0
                                                    : 100.0,
                                                alignment: Alignment.center,
                                                child: SvgPicture.asset(
                                                  'assets/icons/input_pass.svg',
                                                  alignment: Alignment.center,
                                                ),
                                              );
                                              backArrow = SizedBox.shrink();
                                            }
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                  Container(
                    height: 110.0,
                    margin: EdgeInsets.only(
                        top: !keyBoardOpened ? 40.0 : 10.0, left: 10.0),
                    alignment: Alignment.topLeft,
                    child: backArrow,
                  )
                ]),
                chooseFingerOrPass,
                passRemember,
                passWidget,
                Visibility(
                  visible: buttonVisible,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: (deviceIPAD != null && deviceIPAD == true)
                            ? 100.0
                            : (MediaQuery.of(context).viewInsets.bottom != 0.0)
                                ? 5.0
                                : 100.0),
                    height: 40.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                      child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color:
                                      Theme.of(context).secondaryHeaderColor)),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {
                              if (passwordController.text.isEmpty ||
                                  passwordController.text == '') {
                                passIsEmpty = true;
                              } else {
                                passIsEmpty = false;
                              }
                              _getPressEnterButton();
                              textError = '';
                            },
                            child: Text(
                              LocaleKeys.ok.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).shadowColor,
                                  fontFamily: 'MyriadPro',
                                  fontSize: textSize20),
                            ),
                          )),
                    ),
                  ),
                )
              ],
            ),
          ))),
    );
  }

  Future<bool> isIpad() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    String? name = info.name;
    if (name != null && name.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }

  void _getPressEnterButton() {
    print('prefGlob: $prefGlob');
    if (prefGlob == 0) {
      if (createTimeCheck(profileCreateDate!, profileEnterDate!)) {
        if (fingerPass == false) {
          setState(() {
            fingerPass = true;
            passRemember = SizedBox.shrink();
          });
        } else if (fingerPass == true) {
          globals.nameProfile = _name;
          global.idProfile = _nameId;
          globals.passPrefer = prefGlob;
          //globals.pass = widget.teamName;
          globals.pass = passwordController.text;
          passwordController.text = '';
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => false);
        }
      } else if (!createTimeCheck(profileCreateDate!, profileEnterDate!)) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final isAuthenticated = await LocalAuthApi().authenticate();
          if (await LocalAuthApi().availableBiometric() == false) {
            Fluttertoast.showToast(msg: LocaleKeys.noBiometrics.tr());
          }
          if (isAuthenticated) {
            globals.nameProfile = _name;
            global.idProfile = _nameId;
            globals.passPrefer = prefGlob;
            //globals.pass = widget.teamName;
            globals.pass = box.read('${_name + _nameId}pass');
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
                (Route<dynamic> route) => false);
          }
        });
      }
    } else if (prefGlob == 1) {
      globals.nameProfile = _name;
      global.idProfile = _nameId;
      globals.passPrefer = prefGlob;
      //globals.pass = widget.teamName;
      globals.pass = passwordController.text;
      passwordController.text = '';
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false);
    } else if (prefGlob == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isAuthenticated = await LocalAuthApi().authenticate();
        if (await LocalAuthApi().availableBiometric() == false) {
          Fluttertoast.showToast(msg: LocaleKeys.noBiometrics.tr());
        }
        if (isAuthenticated) {
          globals.nameProfile = _name;
          global.idProfile = _nameId;
          globals.passPrefer = prefGlob;
          globals.pass = hashPass(hashPassword).toString();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => false);
        }
      });
    } else if (prefGlob == 3) {
      globals.nameProfile = _name;
      global.idProfile = _nameId;
      globals.passPrefer = prefGlob;
      globals.pass = hashPass(hashPassword).toString();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false);
    }
    box.remove('temporaryName');
  }
}
