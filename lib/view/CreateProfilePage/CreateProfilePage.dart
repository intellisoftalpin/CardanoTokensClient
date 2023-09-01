import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/hash_pass.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart' as prof;

import '../../data/dbhive/ProfileModel.dart';
import '../OnBoardingPages/SecondOnBoardScreen.dart';

String nameProfile = '';
int passPrefer = 5;
String pass = '';
bool passChosen = false;
final box = GetStorage('PassPrefer');
List<ProfileModel> profiles = [];

class CreateProfilePage extends StatefulWidget {
  final Widget welcome;
  final int passPrefer;
  final bool passwordRemind;
  final bool passwordField;
  final bool confirmPasswordField;

  CreateProfilePage(
      {Key? key,
      required this.welcome,
      required this.passPrefer,
      required this.passwordRemind,
      required this.passwordField,
      required this.confirmPasswordField})
      : super(key: key);

  static Route route(BuildContext context) {
    return MaterialPageRoute<void>(
        builder: (_) => CreateProfilePage(
              welcome: Text(
                LocaleKeys.conf_pass.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: textSize18,
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              passPrefer: 1,
              passwordRemind: true,
              confirmPasswordField: true,
              passwordField: true,
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return CreateProfilePageState();
  }
}

class CreateProfilePageState extends State<CreateProfilePage> {
  late double screenWidth;
  final nameController =
      TextEditingController(text: LocaleKeys.my_portfolio.tr());
  var passController = '';
  var passConfirmController = '';
  final _formKey = GlobalKey<FormState>();
  static List<ProfileModel> profile = [];

  //late Profile profile;
  List<String> profileList = [];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    int? onBoard = box.read('onBoard');
    Widget backArrow = SizedBox.shrink();
    print('ONBOARD:: $onBoard');
    if (onBoard == 2) {
      backArrow = IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 35.0,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SecondOnBoardScreen(
                          appBarBackArrow: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 35.0,
                          color: Theme.of(context).focusColor,
                        ),
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()))
                        },
                      ))))
        },
      );
    }
    return MultiBlocProvider(
          providers: [
            BlocProvider<CreateProfileBloc>(
              create: (context) => CreateProfileBloc(DatabaseProvider(),
                  HivePrefProfileRepositoryImpl(), '', '', null, '', 0, null),
            ),
          ],
          child: WillPopScope(
            onWillPop: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondOnBoardScreen(
                          appBarBackArrow: backArrow)));
              return true;
            },
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Theme.of(context).dividerColor,
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0.0,
                  backgroundColor: Theme.of(context).dividerColor,
                  title: Text(
                    LocaleKeys.create_portfolio.tr(),
                    style: TextStyle(
                      fontSize: textSize24,
                      color: Theme.of(context).indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 35.0,
                      color: Theme.of(context).focusColor,
                    ),
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SecondOnBoardScreen(
                                  appBarBackArrow: backArrow)))
                    },
                  ),
                ),
                body: LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              profilePageLabel(),
                              namePasswordField(),
                              createButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })),
          ),
    );
  }

  void _buttonEnter() {
    nameProfile = nameController.text;
    pass = passController;
    passPrefer = widget.passPrefer;
    //box.write(nameProfile, widget.passPrefer);
    if (widget.passwordField == false) {
      pass = hashPass(hashPassword).toString();
    }
    print("nameProfile = $nameProfile, pass = $pass" +
        "_formKey.currentState = ${_formKey.currentState!.validate()}");
    if (_formKey.currentState!.validate()) {
      BlocListener<CreateProfileBloc, CreateProfileState>(
          bloc: CreateProfileBloc(
              DatabaseProvider(),
              HivePrefProfileRepositoryImpl(),
              nameProfile,
              global.idProfile,
              null,
              pass,
              widget.passPrefer,
              null),
          listener: (context, state) {
            if (state.state == CreateProfileStatus.start) {
              BlocProvider.of<CreateProfileBloc>(context).add(SaveProfile(
                  profile: nameProfile,
                  idProfile: global.idProfile,
                  pass: pass.trim(),
                  passPrefer: widget.passPrefer));
            }
          });
      box.write('onBoard', 2);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false);
    } else {
      nameProfile = '';
      pass = '';
      passConfirmController = '';
    }
  }

  Widget profilePageLabel() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.welcome,
            SizedBox(
              height: 5.0,
            ),
            Visibility(
                child: Text(
                  LocaleKeys.pass_remind.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: textSize14,
                      color: Theme.of(context).focusColor),
                ),
                visible: widget.passwordRemind),
          ],
        )),
      ),
    );
  }

  Widget namePasswordField() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: TextFormField(
              controller: nameController,
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: kFieldNameCreateProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.my_portfolio.tr(),
                  errorStyle: TextStyle(color: kErrorColor)),
              style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontSize: textSize20),
              validator: (value) {
                if (value!.isEmpty || nameController.text.isEmpty) {
                  return LocaleKeys.enter_name.tr();
                }
                return null;
              },
              //onChanged: (value) => setState(() {
              //  nameController.text = value;
              //}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: Visibility(
              child: TextFormField(
                obscureText: true,
                autofocus: true,
                //controller: passController,
                keyboardType: TextInputType.text,
                decoration: kFieldPassCreateProfileDecoration(context).copyWith(
                    hintText: LocaleKeys.main_pass.tr(),
                    errorStyle: TextStyle(color: kErrorColor)),
                style: TextStyle(
                    color: Theme.of(context).disabledColor,
                    fontFamily: 'MyriadPro',
                    fontSize: textSize20),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.enter_password.tr();
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  passController = value;
                }),
              ),
              visible: widget.passwordField,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: Visibility(
              child: TextFormField(
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: kFieldPassCreateProfileDecoration(context).copyWith(
                    hintText: LocaleKeys.confirm_password.tr(),
                    errorStyle: TextStyle(color: kErrorColor)),
                style: TextStyle(
                    color: Theme.of(context).disabledColor,
                    fontFamily: 'MyriadPro',
                    fontSize: textSize20),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.re_enter_password.tr();
                  }
                  print(passController);
                  print(passConfirmController);
                  if (passController != passConfirmController &&
                      passController.isNotEmpty) {
                    return LocaleKeys.password_not_match.tr();
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  passConfirmController = value;
                }),
              ),
              visible: widget.confirmPasswordField,
            ),
          ),
        ],
      ),
    );
  }

  Widget createButton() {
    box.write('temporaryName', nameController.text);
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor)),
                color: Theme.of(context).secondaryHeaderColor,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                  onPressed: () {
                    prof.selectedIndex = 0;
                    _buttonEnter();
                  },
                  child: Text(
                    LocaleKeys.create.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: textSize20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String description) {
    Widget gotIt = TextButton(
      child: Text(LocaleKeys.ok.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(description),
      actions: [
        gotIt,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
