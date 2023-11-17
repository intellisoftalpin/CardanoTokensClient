import 'dart:io';

import 'package:crypto_offline/bloc/BackupRestoreBloc/BackupRestoreBloc.dart';
import 'package:crypto_offline/bloc/BackupRestoreBloc/BackupRestoreEvent.dart';
import 'package:crypto_offline/bloc/BackupRestoreBloc/BackupRestoreState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:share/share.dart';
import '../../data/repository/SharedPreferences/SharedPreferencesRepository.dart';
import '../../utils/delete_list_backup.dart';
import 'ProfilePage.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

class BackupRestorePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => BackupRestorePage());
  }

  @override
  State<StatefulWidget> createState() {
    return BackupRestorePageState();
  }
}

class BackupRestorePageState extends State<BackupRestorePage> {
  bool checkAutomaticBackup = false;
  List<FileSystemEntity> listFiles = [];
  final List<String> popupMenu = [
    LocaleKeys.share.tr(),
    LocaleKeys.delete.tr()
  ];
  late SharedPreferencesRepository _preferences;
  bool openAlert = false;
  bool _select = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _preferences = SharedPreferencesRepository();
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<BackupRestoreBloc>(
              create: (context) => BackupRestoreBloc(DatabaseProvider(), ''),
            ),
          ],
          child: BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
              builder: (context, state) {
            if (state.state == BackupRestoreStatus.start) {
              context
                  .read<BackupRestoreBloc>()
                  .add(BackupListFiles(listFiles: []));
              return SplashPage();
            } else if (state.state == BackupRestoreStatus.load) {
              listFiles = state.listFiles!;
              print("listFiles_start = $listFiles");
            }
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                elevation: 0.0,
                centerTitle: true,
                title: Text(
                  LocaleKeys.backup_restore.tr(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  // style: Theme
                  //     .of(context)
                  //     .appBarTheme
                  //     .textTheme!
                  //     .headline6,
                  style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'MyriadPro'),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 35.0,
                    color: Theme.of(context).focusColor,
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProfilePage())),
                ),
                actions: [
                  SizedBox(
                    height: 35.0,
                    width: 35.0,
                  )
                ],
                backgroundColor: Theme.of(context).primaryColor,
              ),
              body: Stack(children: [
                ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Container(
                    child: OrientationBuilder(
                      builder:
                          (BuildContext context, Orientation orientation) =>
                              orientation == Orientation.portrait
                                  ? portraitOrientation(state, context)
                                  : landscapeOrientation(state, context),
                    ),
                  ),
                ),
                Visibility(
                  visible: openAlert,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: alertTransparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    topLeft: Radius.circular(20.0)),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      LocaleKeys.remember_backup.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).focusColor,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'MyriadPro',
                                          fontSize: textSize25),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 30.0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                child: Center(
                                                    child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 22.0,
                                                  width: 22.0,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              Theme.of(context)
                                                                  .shadowColor),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0))),
                                                ),
                                                Checkbox(
                                                  activeColor: Colors.white,
                                                  checkColor: Theme.of(context)
                                                      .shadowColor,
                                                  value: _select,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      _select = newValue!;
                                                    });
                                                  },
                                                )
                                              ],
                                            ))),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    LocaleKeys.remember_me.tr(),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .focusColor,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontFamily: 'MyriadPro',
                                                        fontSize: textSize15))),
                                          ],
                                        )),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              deleteBackupListAll();
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100), () {
                                                BlocProvider.of<
                                                            BackupRestoreBloc>(
                                                        context)
                                                    .add(BackupDb());
                                              });
                                              if (_select) {
                                                _preferences.setBackUp(
                                                    global.idProfile, 1);
                                              }
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                setState(() {
                                                  openAlert = false;
                                                });
                                              });
                                            },
                                            child: Container(
                                                alignment: Alignment.center,
                                                width: 125.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Text(
                                                  LocaleKeys.yes.tr(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .shadowColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'MyriadPro',
                                                      fontSize: textSize20),
                                                )),
                                          ),
                                          SizedBox(
                                            width: 50.0,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              BlocProvider.of<
                                                          BackupRestoreBloc>(
                                                      context)
                                                  .add(BackupDb());
                                              if (_select) {
                                                _preferences.setBackUp(
                                                    global.idProfile, 2);
                                              }
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100), () {
                                                setState(() {
                                                  openAlert = false;
                                                });
                                              });
                                            },
                                            child: Container(
                                                alignment: Alignment.center,
                                                width: 125.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Text(
                                                  LocaleKeys.no.tr(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .shadowColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'MyriadPro',
                                                      fontSize: textSize20),
                                                )),
                                          ),
                                        ])
                                  ])),
                        ],
                      )),
                ),
              ]),
            );
          }),
        ));
  }

  Widget portraitOrientation(BackupRestoreState state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //!!Widgets HIDE on the APP FIRST VERSION!!
        // getLabelBackup(labelTopValue: 25.0, labelBottomValue: 25.0),
        // getCheckboxBackup(widthOfTextSpace: 250.0),
        getListFiles(state),
        recoveryButtonPortrait(context),
      ],
    );
  }

  Widget landscapeOrientation(BackupRestoreState state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //!!Widgets HIDE on the APP FIRST VERSION!!
        // getLabelBackup(labelTopValue: 5.0, labelBottomValue: 5.0),
        // getCheckboxBackup(widthOfTextSpace: 450.0),
        getListFiles(state),
        recoveryButtonLandscape(context)
      ],
    );
  }

  Widget getLabelBackup(
      {required double labelTopValue, required double labelBottomValue}) {
    return Container(
      margin: EdgeInsets.only(
          left: 16, right: 16, top: labelTopValue, bottom: labelBottomValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              LocaleKeys.backup_restore.tr(),
              style: TextStyle(
                  fontSize: textSize14, color: Theme.of(context).hintColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "13.10.2021",
              style: TextStyle(fontSize: textSize20, fontFamily: 'Myriad Pro'),
            ),
          ),
        ],
      ),
    );
  }

  Widget getCheckboxBackup({required double widthOfTextSpace}) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? konBoardBGColor
          : lonBoardBGColor,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: widthOfTextSpace,
              child: Text(
                LocaleKeys.automatic_backup.tr(),
                style: kAppBarTextStyle(context).copyWith(fontSize: textSize20),
              ),
            ),
            RoundCheckBox(
                uncheckedColor: Theme.of(context).scaffoldBackgroundColor,
                checkedColor: Theme.of(context).secondaryHeaderColor,
                checkedWidget:
                    Icon(Icons.check, color: Theme.of(context).dividerColor),
                size: 28,
                onTap: (value) {
                  checkAutomaticBackup = value!;
                }),
          ],
        ),
      ),
    );
  }

  Widget getListFiles(BackupRestoreState state) {
    //final box = context.findRenderObject() as RenderBox?;
    return Expanded(
      child: ListView.builder(
          itemCount: state.listFiles!.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: ListTile(
                  title: Text(
                    //state.listFiles![index].path,
                    state.listFiles![index].path.split('/').last,
                    style: TextStyle(
                        fontSize: textSize14,
                        color: Theme.of(context).focusColor),
                  ),
                  trailing: PopupMenuButton(
                    //icon: const Icon(Icons.keyboard_arrow_down_outlined),
                    iconSize: Theme.of(context)
                        .iconTheme
                        .copyWith(size: MediumIcon)
                        .size!
                        .toDouble(),
                    //color: Theme.of(context).iconTheme.color,
                    itemBuilder: (BuildContext context) {
                      return popupMenu.map((item) {
                        return PopupMenuItem(
                          value: item,
                          child: ListTile(
                            title: Text(
                              item,
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontFamily: 'MyriadPro',
                                  fontSize: textSize24),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (String item) {
                      if (item == LocaleKeys.share.tr()) {
                        Share.shareFiles(
                          ['${listFiles[index].path}'],
                          //sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
                        );
                      } else if (item == LocaleKeys.delete.tr()) {
                        BlocProvider.of<BackupRestoreBloc>(context)
                            .add(DeleteZipFile(zipPath: listFiles[index].path));
                      }
                    },
                  )),
            );
          }),
    );
  }

  Widget recoveryButtonPortrait(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 32, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /* Padding(
            padding: const EdgeInsets.only(
                left: 32.0, right: 32.0, top: 0.0, bottom: 16.0),
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: Theme.of(context).secondaryHeaderColor)),
              color: Theme.of(context).secondaryHeaderColor,
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                onPressed: () {},
                child: Text(
                  LocaleKeys.recovery.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).shadowColor,
                      fontFamily: 'MyriadPro',
                      fontSize: MediumBodyTextSize),
                ),
              ),
            ),
          ),*/
          Material(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side:
                    BorderSide(color: Theme.of(context).secondaryHeaderColor)),
            color: Theme.of(context).secondaryHeaderColor,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              onPressed: () async {
                int backUp = await _preferences.getBackUp(global.idProfile);
                print('backUp:::: $backUp');
                if (backUp == 0 && listFiles.isNotEmpty) {
                  setState(() {
                    openAlert = true;
                  });
                } else if (backUp == 1) {
                  deleteBackupListAll();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    BlocProvider.of<BackupRestoreBloc>(context).add(BackupDb());
                  });
                } else if (backUp == 2) {
                  BlocProvider.of<BackupRestoreBloc>(context).add(BackupDb());
                } else {
                  BlocProvider.of<BackupRestoreBloc>(context).add(BackupDb());
                }
              },
              child: Text(
                LocaleKeys.backup.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).shadowColor,
                    fontFamily: 'MyriadPro',
                    fontSize: textSize20),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget recoveryButtonLandscape(BuildContext context) {
    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* Expanded(
             child: Padding(
                padding: const EdgeInsets.only(
                    left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    // minWidth: MediaQuery.of(context).size.width/4,
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    onPressed: () {},
                    child: Text(
                      LocaleKeys.recovery.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: MediumBodyTextSize),
                    ),
                  ),
                ),
              ),
            ),*/
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    onPressed: () {
                      BlocProvider.of<BackupRestoreBloc>(context)
                          .add(BackupDb());
                    },
                    child: Text(
                      LocaleKeys.backup.tr(),
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
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    onPressed: () {
                      deleteBackupList();
                    },
                    child: Text(
                      LocaleKeys.delete_all.tr(),
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
    );
  }
}
