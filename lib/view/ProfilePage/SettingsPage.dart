import 'package:crypto_offline/bloc/ProfileBloc/ProfileBloc.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/data/model/ThemeModel.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../data/repository/SharedPreferences/SharedPreferencesRepository.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

import '../CreateProfilePage/CreateProfilePage.dart';

class SettingsPage extends StatefulWidget {
  final systemAppLanguage;

  const SettingsPage({Key? key, required this.systemAppLanguage})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late GlobalKey<ScaffoldState> _key;
  String _stringLocaleShPref = 'language';
  String backUp = '';
  late SharedPreferencesRepository _preferences;
  int backUpPref = 0;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    loadStringLocaleShPref();
    _initPackageInfo();
  }

  void getBackUpPref() async {
    _preferences = SharedPreferencesRepository();
    backUpPref = await _preferences.getBackUp(global.idProfile);
    if (backUpPref == 0) {
      backUp = LocaleKeys.backUpSet0.tr();
    } else if (backUpPref == 1) {
      backUp = LocaleKeys.backUpSet1.tr();
    } else if (backUpPref == 2) {
      backUp = LocaleKeys.backUpSet2.tr();
    }
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void loadStringLocaleShPref() async {
    setState(() {
      _stringLocaleShPref = box.read('stringLocaleShPref') ?? 'language';
    });
  }

  void setStringLocaleShPref(String language) async {
    setState(() {
      _stringLocaleShPref = language;
      box.write('stringLocaleShPref', _stringLocaleShPref);
    });
  }

  @override
  Widget build(BuildContext context) {
    getBackUpPref();
    _key = GlobalKey();
    print(' сохраненная локаль   ${context.locale.toString()}');
    Brightness deviceBrightness = MediaQuery.of(context).platformBrightness;
    print("System theme: $deviceBrightness");
    String languageIcon = 'assets/icons/language.svg';
    String themeIcon = 'assets/icons/bucket.svg';
    String themeName = LocaleKeys.dark.tr();
    Widget backUpIcon = Icon(
      Icons.delete,
      size: 25.0,
      color: Colors.black,
    );
    if (Theme.of(context).primaryColor == lBackgroundColor) {
      languageIcon = 'assets/icons/language_lt.svg';
      themeIcon = 'assets/icons/bucket_lt.svg';
      themeName = LocaleKeys.light.tr();
      backUpIcon = Icon(
        Icons.delete,
        size: 25.0,
        color: Colors.black,
      );
    } else if (Theme.of(context).primaryColor == kBackgroundColor) {
      languageIcon = 'assets/icons/language.svg';
      themeIcon = 'assets/icons/bucket.svg';
      themeName = LocaleKeys.dark.tr();
      backUpIcon = Icon(
        Icons.delete,
        size: 25.0,
        color: Colors.white,
      );
    }
    if (_stringLocaleShPref == 'Системный(Русский)' ||
        _stringLocaleShPref == 'System(English)' ||
        _stringLocaleShPref == 'language') {
      if (ui.window.locale.toString().contains('ru')) {
        _stringLocaleShPref = 'Системный(Русский)';
      } else {
        _stringLocaleShPref = 'System(English)';
      }
    }
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                  DatabaseProvider(),
                  SharedPrefProfileRepositoryImpl(),
                  HivePrefProfileRepositoryImpl(),
                  ApiRepository()),
            ),
          ],
          child:
              BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            return WillPopScope(
                onWillPop: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                  return true;
                },
                child: Scaffold(
                  key: _key,
                  appBar: AppBar(
                    elevation: 0.0,
                    centerTitle: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text(
                      LocaleKeys.settings.tr(),
                      style: kAppBarTextStyle(context),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: Theme.of(context)
                            .iconTheme
                            .copyWith(size: MediumIcon)
                            .size,
                        color: Theme.of(context).focusColor,
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage())),
                    ),
                  ),
                  drawer: ProfilePageState.getDrawMenu(context, _packageInfo),
                  backgroundColor: Theme.of(context).backgroundColor,
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: ListView(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              LocaleKeys.visual_settings.tr(),
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
                                  children: [
                                    Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    child: SvgPicture.asset(
                                                      themeIcon,
                                                    ),
                                                    height: 24.0,
                                                    width: 24.0),
                                                SizedBox(
                                                  width: 14.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys.theme.tr(),
                                                      ),
                                                      Text((themeNotifier
                                                                  .isDark ==
                                                              3)
                                                          ? '${LocaleKeys.system_th.tr()}($themeName)'
                                                          : themeName),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 80.0,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          right: 15.0),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/menu.svg',
                                                        width: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton(
                                              icon: null,
                                              offset: Offset(1, 0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 45.0,
                                              ),
                                              onSelected: (value) {
                                                if (value == 1) {
                                                  themeNotifier.isDark = 1;
                                                }
                                                if (value == 2) {
                                                  themeNotifier.isDark = 2;
                                                }
                                                if (value == 3) {
                                                  if (deviceBrightness ==
                                                      Brightness.dark) {
                                                    themeNotifier.isDark = 3;
                                                  } else if (deviceBrightness ==
                                                      Brightness.light) {
                                                    themeNotifier.isDark = 3;
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys.dark
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 2,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys.light
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 3,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .system_th
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                        ]),
                                    Divider(thickness: 0.5),
                                    Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    child: SvgPicture.asset(
                                                      languageIcon,
                                                    ),
                                                    height: 24.0,
                                                    width: 24.0),
                                                SizedBox(
                                                  width: 14.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(LocaleKeys.language
                                                          .tr()),
                                                      Text(_stringLocaleShPref),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 80.0,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          right: 15.0),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/menu.svg',
                                                        width: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton(
                                              icon: null,
                                              offset: Offset(1, 0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 45.0,
                                              ),
                                              onSelected: (value) {
                                                if (value == 1) {
                                                  setState(() {
                                                    context.setLocale(
                                                        Locale('en'));
                                                    setStringLocaleShPref(
                                                        'English');
                                                  });
                                                }
                                                if (value == 2) {
                                                  setState(() {
                                                    context.setLocale(
                                                        Locale('ru'));
                                                    setStringLocaleShPref(
                                                        'Русский');
                                                  });
                                                }
                                                if (value == 3) {
                                                  setState(() {
                                                    context.setLocale(Locale(
                                                        widget
                                                            .systemAppLanguage));
                                                    if (widget.systemAppLanguage
                                                        .toString()
                                                        .contains('ru')) {
                                                      setStringLocaleShPref(
                                                          'Системный(Русский)');
                                                    } else {
                                                      setStringLocaleShPref(
                                                          'System(English)');
                                                    }
                                                  });
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .english
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 2,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .russian
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 3,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys.system
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                        ]),
                                    Divider(thickness: 0.5),
                                    Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(child: backUpIcon),
                                                SizedBox(
                                                  width: 14.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys
                                                            .auto_del_prev_backup
                                                            .tr(),
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: textSize13,
                                                        ),
                                                      ),
                                                      Text(
                                                        '($backUp)',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: textSize13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 80.0,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          right: 15.0),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/menu.svg',
                                                        width: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton(
                                              icon: null,
                                              offset: Offset(1, 0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 45.0,
                                              ),
                                              onSelected: (value) {
                                                if (value == 1) {
                                                  setState(() {
                                                    backUp = LocaleKeys
                                                        .backUpSet0
                                                        .tr();
                                                    _preferences.setBackUp(
                                                        global.idProfile, 0);
                                                  });
                                                }
                                                if (value == 2) {
                                                  setState(() {
                                                    backUp = LocaleKeys
                                                        .backUpSet1
                                                        .tr();
                                                    _preferences.setBackUp(
                                                        global.idProfile, 1);
                                                  });
                                                }
                                                if (value == 3) {
                                                  setState(() {
                                                    backUp = LocaleKeys
                                                        .backUpSet2
                                                        .tr();
                                                    _preferences.setBackUp(
                                                        global.idProfile, 2);
                                                  });
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .backUpSet0
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 2,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .backUpSet1
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 3,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(LocaleKeys
                                                              .backUpSet2
                                                              .tr())
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          }));
    });
  }
}
