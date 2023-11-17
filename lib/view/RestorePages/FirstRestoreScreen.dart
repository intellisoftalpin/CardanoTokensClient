import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../app.dart';
import '../../app.dart' as recovery;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import '../../utils/hash_pass.dart';
import '../../utils/random_string.dart';
import '../../utils/recovery_size.dart';
import 'SecondRestoreScreen.dart';

String? lastProfileId = '';
String? dbRecoveryName = '';

class FirstRestoreScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => FirstRestoreScreen());
  }

  @override
  State<FirstRestoreScreen> createState() => _FirstRestoreScreenState();
}

class _FirstRestoreScreenState extends State<FirstRestoreScreen> {
  String errorText = '';

  @override
  void initState() {
    print('RECOVERY PATH:::::::: ${recovery.recoveryPath}');
    super.initState();
    globals.pass = '';
    global.idProfile = '';
  }

  Widget goodFile(BuildContext context) {
    File file = new File(recovery.recoveryPath!);
    String fileName = file.path.split('/').last;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 50.0,
          ),
          Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text('${LocaleKeys.recovery_good.tr()}\n\n$fileName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontFamily: 'MyriadPro',
                      fontSize: textSize17))),
          Container(
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 5.0),
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
                          recovery.recoveryPath = null;
                          ReceiveSharingIntent.reset();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => App()),
                              (Route<dynamic> route) => false);
                        },
                        child: Text(
                          LocaleKeys.no.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).shadowColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize20),
                        ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor)),
                      color: Theme.of(context).secondaryHeaderColor,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width / 3,
                        padding: EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                        onPressed: () async {
                          String dbName = '';
                          String dbNewName =
                              '${RandomString.getRandomString(10)}.db';
                          if (recovery.recoveryPath!.substring(
                                  recovery.recoveryPath!.length - 3) ==
                              'zip') {
                            Directory appDocDir =
                                await getApplicationDocumentsDirectory();
                            String appDocPath = appDocDir.path;
                            var appCache = await getTemporaryDirectory();
                            String appCachePath = appCache.path;
                            final inputStream =
                                InputFileStream(recovery.recoveryPath!);
                            final archive =
                                ZipDecoder().decodeBuffer(inputStream);
                            for (final file in archive) {
                              String fileName = file.name;
                              extractArchiveToDisk(archive, appCachePath);
                              print('ARCHIVE:::::$archive');
                              print('appDocPath:::::$appDocPath');
                              print('appCachePath:::::$appCachePath');
                              print('filename:::::$fileName');
                              print(
                                  'FILE_OLD_PATH:::::$appCachePath/$fileName');
                              print('FILE_NEW_PATH:::::$appDocPath/$fileName');
                              print('dbNewName:::::$dbNewName');
                              print(
                                  'fileName.substring:::::${fileName.substring(0, fileName.length - 6)}');
                              dbName = dbNewName;
                              await File('$appCachePath/$fileName')
                                  .rename('$appDocPath/$dbNewName');
                            }
                          }
                          lastProfileId = global.idProfile;
                          if (dbName.length >= 3) {
                            dbName = dbName.substring(0, dbName.length - 3);
                          }
                          dbRecoveryName = dbName;
                          global.idProfile = dbName;
                          print('dbRecoveryName::: $dbRecoveryName');
                          print('dbName::: $dbName');
                          globals.pass = hashPass(hashPassword).toString();
                          setState(() {});
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SecondRestoreScreen(error: '')),
                              (Route<dynamic> route) => true);
                        },
                        child: Text(
                          LocaleKeys.yes.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).shadowColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize20),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }

  Widget badFile(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 50.0,
          ),
          Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(errorText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontFamily: 'MyriadPro',
                      fontSize: textSize17))),
          Container(
              margin: EdgeInsets.only(top: 5.0),
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
                    recovery.recoveryPath = null;
                    ReceiveSharingIntent.reset();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => App()),
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
                ),
              )),
          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }

  bool checkFileTrue() {
    bool trueFile = false;
    File file = new File(recovery.recoveryPath!);
    String fileName = file.path.split('/').last;
    int underscoreNumber = 0;
    int archLength = 0;
    print('FILE_NAME::::::$fileName');
    print('FILE_NAME_LENGTH::::::${fileName.length}');
    print(
        'HYPHEN_NUMBER::::::${fileName.replaceAll(new RegExp(r'[^\-]'), '').length}');
    String? path = recovery.recoveryPath;
    if (path!.substring(path.length - 3) == 'zip') {
      File zip = File(recovery.recoveryPath!);
      var bytes = zip.readAsBytesSync();
      var archive = ZipDecoder().decodeBytes(bytes);
      archLength = archive.length;
      underscoreNumber = fileName.replaceAll(new RegExp(r'[^\\_]'), '').length;
      int archCountDB = 0;
      String nameWithoutZip = fileName.substring(0, fileName.length - 4);
      for (var file in archive) {
        print('ZIP COUNT FILES NUMBER::: ${archive.length}');
        print('NAME FILE IN ZIP::: ${file.name}');
        print('NAME length::: ${fileName.length}');
        print('underscoreNumber ::: $underscoreNumber');
        print('index of _ ::: ${fileName.indexOf('_')}');
        print(
            'Contains letters::: ${(nameWithoutZip.contains(new RegExp('[a-zA-Z]')))}');
        if (file.name.length > 3) {
          if (file.name.substring(file.name.length - 3) == '.db') {
            if (file.name.length > 6) {
              if (file.name.substring(file.name.length - 6) == '_ct.db') {
                archCountDB = 2;
              } else {
                archCountDB = 1;
              }
            } else {
              archCountDB = 1;
            }
          } else {
            archCountDB = 0;
          }
        } else {
          archCountDB = 0;
        }
      }
      if (underscoreNumber == 1 &&
          !(nameWithoutZip.contains(new RegExp('[a-zA-Z]'))) &&
          fileName.indexOf('_') == 1) {
        errorText = LocaleKeys.recovery_error_telegram.tr();
        trueFile = false;
      } else if (!recoverySizeSmall()) {
        errorText = LocaleKeys.recovery_error_size.tr();
        trueFile = false;
      } else if (archLength > 1) {
        errorText = LocaleKeys.recovery_error_contain.tr();
        trueFile = false;
      } else if (archCountDB == 0) {
        errorText = LocaleKeys.recovery_error_inside.tr();
        trueFile = false;
      } else if (archCountDB == 1) {
        errorText = LocaleKeys.recovery_error_inside_db.tr();
        trueFile = false;
      } else {
        trueFile = true;
      }
    }
    //else if (path.substring(path.length - 3) == '.db') {
    //  trueFile = true;
    //}
    else {
      errorText = LocaleKeys.recovery_error_format.tr();
      trueFile = false;
    }
    return trueFile;
  }

  @override
  Widget build(BuildContext context) {
    if (globals.nameProfile != '') {
      globals.nameProfile = '';
    }
    Widget body = SizedBox.shrink();
    if (checkFileTrue()) {
      body = goodFile(context);
    } else {
      body = badFile(context);
    }
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          recovery.recoveryPath = null;
          ReceiveSharingIntent.reset();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => App()),
              (Route<dynamic> route) => false);
        },
        child: Scaffold(
          appBar: null,
          body: Container(
              child: SingleChildScrollView(
                  child: Column(
            children: [
              Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? konBoardBGColor
                    : lonBoardBGColor,
                height: 50.0,
              ),
              Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? konBoardBGColor
                      : lonBoardBGColor,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 15.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
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
              body
            ],
          ))),
        ));
  }
}
