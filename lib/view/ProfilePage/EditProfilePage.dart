import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/DeleteProfileBloc/DeleteProfileBloc.dart';
import '../../data/database/DbProvider.dart';
import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../../data/dbhive/ProfileModel.dart';
import '../../utils/delete_db.dart';
import '../../utils/edit_alerts.dart';
import 'InputPasswordPage.dart';
import 'ProfilePage.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;

class EditProfilePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => EditProfilePage());
  }

  @override
  State<StatefulWidget> createState() {
    return EditProfilePageState();
  }
}

class EditProfilePageState extends State<EditProfilePage> {
  bool checkAutomaticBackup = false;
  final editName = TextEditingController();
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();
  static List<ProfileModel> profile = [];
  Widget changePassWidget = SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    if (globals.passPrefer == 0 ||
        globals.passPrefer == 1) {
      changePassWidget = changePass();
    } else {
      changePassWidget = changePassUnavailable();
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProfilePage()));
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            LocaleKeys.editing.tr(),
                      // style: Theme
                      //     .of(context)
                      //     .appBarTheme
                      //     .textTheme!
                      //     .headline6,
                      style: kAppBarTextStyle(context),
                    ),
                    //actions: <Widget>[
                    //  IconButton(
                    //    icon: Icon(
                    //      Icons.check,
                    //      size: 35.0,
                    //      color: Theme.of(context).secondaryHeaderColor,
                    //    ),
                    //    onPressed: () {
                    //      // Navigator.push(context, MaterialPageRoute(builder: (
                    //      //   context) => AddCoinPage()));
                    //    },
                    //  )
                    //],
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 35.0,
                        color: Theme.of(context).focusColor,
                      ),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProfilePage())),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? kSettingsPageBackground : lSettingsPageBackground,
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: ListView(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              LocaleKeys.edit_portfolio.tr(),
                              style: TextStyle(
                                fontSize: textSize20,
                                color: Theme.of(context).indicatorColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(SettingsCardRadius),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    changeName(context),
                                    Divider(
                                        height: 0.4,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .copyWith(
                                                color:
                                                    Theme.of(context).hintColor)
                                            .color),
                                    changePassWidget,
                                    Divider(
                                        height: 0.4,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .copyWith(
                                                color:
                                                    Theme.of(context).hintColor)
                                            .color),
                                    deletePort(context),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );

  }

  Widget changeName(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
        padding: EdgeInsets.all(5.0),
        //decoration: BoxDecoration(
        //    border: Border.all(
        //      width: 1.0,
        //      color: Theme.of(context).primaryColorLight,
        //    ),
        //    borderRadius: BorderRadius.all(Radius.circular(10))),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(
                  Icons.drive_file_rename_outline,
                  size: Theme.of(context)
                      .iconTheme
                      .copyWith(size: MediumIcon)
                      .size,
                  color: Theme.of(context)
                      .iconTheme
                      .copyWith(color: Theme.of(context).secondaryHeaderColor)
                      .color,
                )),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.edit_name.tr(),
                      style:
                          TextStyle(fontSize: textSize18, fontWeight: FontWeight.bold),
                    ),
                    Text('\'${globals.nameProfile}\'',
                        style: TextStyle(
                            fontSize: textSize16, fontWeight: FontWeight.normal)),
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        if(mounted) {
          showAlertChangeName(context, globals.passPrefer);
        }
      },
    );
  }

  Widget changePass() {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
        padding: EdgeInsets.all(5.0),
        //decoration: BoxDecoration(
        //    border: Border.all(
        //      width: 1.0,
        //      color: Theme.of(context).primaryColorLight,
        //    ),
        //    borderRadius: BorderRadius.all(Radius.circular(10))),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(
                  Icons.key,
                  size: Theme.of(context)
                      .iconTheme
                      .copyWith(size: MediumIcon)
                      .size,
                  color: Theme.of(context)
                      .iconTheme
                      .copyWith(color: Theme.of(context).secondaryHeaderColor)
                      .color,
                )),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.edit_pass.tr(),
                      style:
                          TextStyle(fontSize: textSize18, fontWeight: FontWeight.bold),
                    ),
                    Text(LocaleKeys.edit_pass_add.tr(),
                        style: TextStyle(
                            fontSize: textSize16, fontWeight: FontWeight.normal)),
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        showAlertChangePass(context);
      },
    );
  }

  Widget changePassUnavailable() {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
        padding: EdgeInsets.all(5.0),
        //decoration: BoxDecoration(
        //    border: Border.all(
        //      width: 1.0,
        //      color: Theme.of(context).primaryColorLight,
        //    ),
        //    borderRadius: BorderRadius.all(Radius.circular(10))),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(
                  Icons.key_off,
                  size: Theme.of(context)
                      .iconTheme
                      .copyWith(size: MediumIcon)
                      .size,
                  color: Theme.of(context)
                      .iconTheme
                      .copyWith(color: Theme.of(context).hoverColor)
                      .color,
                )),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.edit_pass.tr(),
                      style:
                          TextStyle(fontSize: textSize18, fontWeight: FontWeight.bold),
                    ),
                    Text(LocaleKeys.edit_pass_add.tr(),
                        style: TextStyle(
                            fontSize: textSize16, fontWeight: FontWeight.normal)),
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        ///showAlertChangePass(context);
      },
    );
  }

  Widget deletePort(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
        padding: EdgeInsets.all(5.0),
        //decoration: BoxDecoration(
        //    border: Border.all(
        //      width: 1.0,
        //      color: Theme.of(context).primaryColorLight,
        //    ),
        //    borderRadius: BorderRadius.all(Radius.circular(10))),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(
                  Icons.delete_forever,
                  size: Theme.of(context)
                      .iconTheme
                      .copyWith(size: MediumIcon)
                      .size,
                  color: Theme.of(context)
                      .iconTheme
                      .copyWith(color: Theme.of(context).secondaryHeaderColor)
                      .color,
                )),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.edit_delete.tr(),
                      style:
                          TextStyle(fontSize: textSize18, fontWeight: FontWeight.bold),
                    ),
                    Text(LocaleKeys.edit_delete_add.tr(),
                        style: TextStyle(
                            fontSize: textSize16, fontWeight: FontWeight.normal)),
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        showAlertDelete(context);
      },
    );
  }

  Widget getPersonalInf() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 16.0, 2.0),
            child: Text(
              LocaleKeys.personal_information.tr(),
              style: kAppBarTextStyle(context)
                  .copyWith(fontSize: textSize20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: TextFormField(
              obscureText: false,
              controller: editName,
              decoration: kFieldNameEditProfileDecoration(context)
                  .copyWith(hintText: LocaleKeys.portfolio_name.tr()),
              validator: (value) {
                if (value!.isEmpty || editName.text.isEmpty) {
                  return LocaleKeys.enter_name.tr();
                }
                return null;
              },
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontFamily: 'Roboto',
                  fontSize: textSize14),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSecurity() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 16.0, 2.0),
            child: Text(
              LocaleKeys.security.tr(),
              style: kAppBarTextStyle(context)
                  .copyWith(fontSize: textSize20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: TextFormField(
              obscureText: false,
              controller: currentPassword,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                hintText: LocaleKeys.current_password.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return LocaleKeys.enter_password.tr();
                }
                return null;
              },
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontFamily: 'Roboto',
                  fontSize: textSize14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: Divider(
              height: 0.1,
              color: Theme.of(context).hintColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: TextFormField(
              obscureText: false,
              controller: newPassword,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.new_password.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    borderSide: BorderSide.none,
                  )),
              validator: (value) {
                if (value!.isEmpty) {
                  return LocaleKeys.enter_password.tr();
                }
                return null;
              },
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontFamily: 'Roboto',
                  fontSize: textSize14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: Divider(
              height: 0.1,
              color: Theme.of(context).hintColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: TextFormField(
              obscureText: false,
              controller: confirmNewPassword,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.new_password_again.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  )),
              validator: (value) {
                if (value!.isEmpty) {
                  return LocaleKeys.re_enter_password.tr();
                }
                if (newPassword != confirmNewPassword) {
                  return LocaleKeys.password_not_match.tr();
                }
                return null;
              },
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontFamily: 'Roboto',
                  fontSize: textSize14),
            ),
          ),
        ],
      ),
    );
  }

  Widget getEditButton() {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor)),
                color: Theme.of(context).secondaryHeaderColor,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  onPressed: () async {
                    await deleteDB(globals.nameProfile);
                    var name = ProfileModel(nameProfile: globals.nameProfile,  id: global.idProfile);
                    List<ProfileModel> profileExist = [];
                    if (profileExist.isEmpty) profileExist.add(name);
                    BlocListener<DeleteProfileBloc, DeleteProfileState>(
                        bloc: DeleteProfileBloc(
                            DatabaseProvider(),
                            HivePrefProfileRepositoryImpl(),
                            globals.nameProfile,
                            global.idProfile),
                        listener: (context, state) {
                          if (state.state == DeleteProfileStatus.start) {
                            BlocProvider.of<DeleteProfileBloc>(context).add(
                                DeleteProfile(profile: globals.nameProfile, idProfile: global.idProfile));
                          }
                        });
                    print('prof = $profileExist');
                    globals.passChosen = false;
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => InputPasswordPage(
                                globals.nameProfile, global.idProfile, '', '', profileExist)),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    LocaleKeys.delete_portfolio.tr(),
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
}
