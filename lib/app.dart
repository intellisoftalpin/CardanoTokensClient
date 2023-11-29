import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:crypto_offline/bloc/AuthenticateProfile/AuthProfileBloc.dart';
import 'package:crypto_offline/bloc/CloseDbBloc/CloseDbBloc.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/hash_pass.dart';
import 'package:crypto_offline/utils/theme.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:crypto_offline/view/OnBoardingPages/FirstOnBoardScreen.dart';
import 'package:crypto_offline/view/OnBoardingPages/SecondOnBoardScreen.dart';
import 'package:crypto_offline/view/ProfilePage/InputPasswordPage.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:crypto_offline/view/RestorePages/FirstRestoreScreen.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sizer/sizer.dart';
import 'bloc/AuthenticateProfile/AuthProfileEvent.dart';
import 'bloc/AuthenticateProfile/AuthProfileState.dart';
import 'data/database/DbProvider.dart';
import 'data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'data/dbhive/ProfileModel.dart';
import 'data/model/ThemeModel.dart';
import 'data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

import 'generated/codegen_loader.g.dart';

String? recoveryPath;
bool isLastTransaction = false;
bool dismissLifecycle = false;

enum SaveOrEdit { edit, save }

SaveOrEdit saveOrEdit = SaveOrEdit.save;

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthProfileBloc>(
          create: (_) => AuthProfileBloc(SharedPrefProfileRepositoryImpl(),
              HivePrefProfileRepositoryImpl()),
        ),
        BlocProvider<CloseDbBloc>(
          create: (context) =>
              CloseDbBloc(DatabaseProvider(), global.idProfile),
        ),
      ],
      child: AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<AppView> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late ThemeModel themeNotifier;
  List<ProfileModel> profileExist = [];
  String lifecycleState = '';

  ///final StreamController<bool> _showLockScreenStream = StreamController();
  late StreamSubscription _showLockScreenSubs;
  List<SharedMediaFile> _sharedFiles = [];
  List<SharedMediaFile> _sharedFilesLifeCycle = [];
  MethodChannel _channelIOS =
      const MethodChannel('org.cardanotokens.app/import_zip');

  ///static const _channelAndroid = MethodChannel('cardano_tokens_client');

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  void initState() {
    print("initState = ");
    WidgetsBinding.instance.addObserver(this);
    if (dismissLifecycle == false) {
      _customAppNavigation(true);
    }

    ///if (Platform.isAndroid) {
    ///  WidgetsBinding.instance.addPostFrameCallback((_) async {
    ///    try {
    ///      recoveryPath = await _channelAndroid.invokeMethod('check');
    ///    } on PlatformException catch (e) {
    ///      print("Failed to get connect: '${e.message}'.");
    ///    }
    ///  });
    ///}
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    runApp(EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
      child: App(),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("dispose = ");
    _showLockScreenSubs.cancel();

    ///_showLockScreenStream.close();
    super.dispose();
  }

  Future<dynamic> _importZipFile(MethodCall call) async {
    switch (call.method) {
      case 'onZipImport':
        final args = call.arguments;
        final path = args["url"];
        print('IOS PATH:::$path');
        recoveryPath = File.fromUri(Uri.parse(path)).path;
        return null;
      default:
        print(
            '_importZipFile: No implemented methods with the name ${call.method}...');
        break;
    }
  }

  Future<void> getSharedPathInit() async {
    if (Platform.isAndroid) {
      await ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> value) {
        print("Shared:" + (_sharedFiles.map((f) => f.path).join(",")));
        _sharedFiles = value;
        recoveryPath = (_sharedFiles.map((f) => f.path).join(","));
        print('PATH::: $recoveryPath');
      });
    }
    if (Platform.isIOS) {
      _channelIOS.setMethodCallHandler(_importZipFile);
    }
  }

  Future<void> getSharedPath() async {
    if (Platform.isAndroid) {
      ReceiveSharingIntent.getMediaStream().listen(
          (List<SharedMediaFile> value) {
        print("Shared:" + (_sharedFilesLifeCycle.map((f) => f.path).join(",")));
        _sharedFilesLifeCycle = value;
        print('_sharedFilesLifeCycle: $_sharedFilesLifeCycle');
        recoveryPath = (_sharedFilesLifeCycle.map((f) => f.path).join(","));
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });
    }
    if (Platform.isIOS) {
      _channelIOS.setMethodCallHandler(_importZipFile);
    }
  }

  void _customAppNavigation(bool appStart) async {
    var name = ProfileModel(
        nameProfile: globals.nameProfile,
        id: global.idProfile,
        pref: globals.passPrefer);
    if (profileExist.isEmpty) profileExist.add(name);
    int? onBoard = box.read('onBoard');
    print(
        ':::SecondOnBoardScreenState.isAuthenticateState = ${SecondOnBoardScreenState.isAuthenticateState} onBoard = $onBoard'
        ' InputPasswordPageState.isAuthenticate = ${InputPasswordPageState.isAuthenticate} '
        'ProfilePageState.isCreateNewPortfolio = ${ProfilePageState.isCreateNewPortfolio}'
        ' name = ${globals.nameProfile}, nameId = ${global.idProfile} pass = ${globals.pass}');
    if (appStart == true) {
      await getSharedPathInit();
      print('appStart_true');
      print('pathForRecovery: $recoveryPath');
    } else {
      await getSharedPath();
      print('appStart_false');
      print('pathForRecovery: $recoveryPath');
    }
    if (recoveryPath != null && recoveryPath != '') {
      if (Platform.isIOS) {
        print('USE IOS BIOMETRIC');
      } else {
        _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FirstRestoreScreen()),
            (Route<dynamic> route) => false);
      }
    } else {
      if (onBoard == null) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FirstOnBoardScreen()),
            (Route<dynamic> route) => false);
      }
      /*else if (onBoard == 1) {
        _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) {
          return SecondOnBoardScreen(appBarBackArrow: SizedBox.shrink());
        }));
      } */
      else if (onBoard == 2 &&
              SecondOnBoardScreenState.isAuthenticateState &&
              !ProfilePageState.isCreateNewPortfolio &&
              (globals.pass.isEmpty || globals.pass == '') ||
          onBoard == 2 && InputPasswordPageState.isAuthenticate ||
          onBoard == 2 &&
              globals.pass.isEmpty &&
              !SecondOnBoardScreenState.isAuthenticateState ||
          onBoard == 2 &&
              globals.pass == '' &&
              !SecondOnBoardScreenState.isAuthenticateState ||
          onBoard == 2 &&
              globals.pass.isEmpty &&
              !InputPasswordPageState.isAuthenticate &&
              !ProfilePageState.isCreateNewPortfolio ||
          onBoard == 2 &&
              globals.pass == '' &&
              !InputPasswordPageState.isAuthenticate &&
              !ProfilePageState.isCreateNewPortfolio) {
        List<ProfileModel> profiles = globals.profiles;
        print('profileExist.length = ${profileExist.length}');
        if (profiles.isNotEmpty) {
          profileExist = profiles;
        }
        if (profileExist.length == 1 && globals.passPrefer == 3) {
          globals.pass = hashPass(hashPassword).toString();
          _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => false);
        } else {
          _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => InputPasswordPage(globals.nameProfile,
                      global.idProfile, '', '', profileExist)),
              (Route<dynamic> route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'APP_SYSTEM_LANGUAGE::: ${View.of(context).platformDispatcher.locale.toString()}');
    String locale = box.read('stringLocaleShPref') ?? 'language';
    print('locale = $locale');
    if (locale == 'Системный(Русский)' ||
        locale == 'System(English)' ||
        locale == 'language') {
      if (View.of(context)
          .platformDispatcher
          .locale
          .toString()
          .contains('ru')) {
        context.setLocale(Locale('ru'));
      } else {
        context.setLocale(Locale('en'));
      }
    }
    print(
        'GLOBALS NAME:::::::::::${globals.nameProfile}, GLOBALS IDNAME:::::::::::${global.idProfile}');
    return Sizer(builder: (context, orientation, deviceType) {
      return LayoutBuilder(builder: (context, constraints) {
        return ChangeNotifierProvider(
          create: (_) => ThemeModel(),
          child: Consumer<ThemeModel>(
              builder: (context, ThemeModel themeNotifier, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    systemNavigationBarColor: lSecondaryLightColor),
                child: MaterialApp(
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: (themeNotifier.isDark == 1)
                      ? basicTheme()
                      : (themeNotifier.isDark == 2)
                          ? lightTheme()
                          : (themeNotifier.isDark == 3 &&
                                  MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                              ? basicTheme()
                              : lightTheme(),
                  navigatorKey: _navigatorKey,
                  builder: (context, child) {
                    return BlocListener<AuthProfileBloc, AuthProfileState>(
                      listener: (context, state) {
                        int? onBoard = box.read('onBoard');
                        print('RECOVERY_PATH::: $recoveryPath');
                        if (recoveryPath != null && recoveryPath != '') {
                          _navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => FirstRestoreScreen()),
                              (Route<dynamic> route) => false);
                        } else {
                          print('else');
                          if (state.state == AuthProfileStatus.exist) {
                            print('AuthProfileStatus.exist');
                            context.read<AuthProfileBloc>().add(LoggedIn());
                            profileExist = state.profileExist;
                            print('prof = $profileExist');
                            globals.passChosen = false;
                            List<ProfileModel> profiles = globals.profiles;
                            if (profiles.isNotEmpty) {
                              profileExist = profiles;
                            }
                            print(
                                'profileExist.length = ${profileExist.length}');
                            if (profileExist.length == 1 &&
                                globals.passPrefer == 3) {
                              globals.pass = hashPass(hashPassword).toString();
                              _navigatorKey.currentState?.pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                return ProfilePage();
                              }));
                            } else {
                              _navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => InputPasswordPage(
                                          globals.nameProfile,
                                          global.idProfile,
                                          '',
                                          '',
                                          profileExist)),
                                  (Route<dynamic> route) => false);
                            }
                          } else if (state.state == AuthProfileStatus.noexist) {
                            print('AuthProfileStatus.noexist');
                            if (onBoard == null) {
                              _navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FirstOnBoardScreen()),
                                  (Route<dynamic> route) => false);
                            } else if (onBoard == 1) {
                              _navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => SecondOnBoardScreen(
                                          appBarBackArrow: SizedBox.shrink())),
                                  (Route<dynamic> route) => false);
                            }
                          }
                        }
                      },
                      child: child,
                    );
                  },
                  onGenerateRoute: (_) => SplashPage.route(),
                ));
          }),
        );
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
        print("HIDDEN");
        break;
      case AppLifecycleState.inactive:
        if (dismissLifecycle == false) {
          print("INACTIVE");
          BlocProvider.of<AuthProfileBloc>(context).add(LoggedOut());
          BlocProvider.of<CloseDbBloc>(this.context)
            ..add(UpdateProfile(idProfile: global.idProfile));
          int? onBoard = box.read('onBoard');
          if (onBoard == 2) {
            var name = ProfileModel(
                nameProfile: globals.nameProfile,
                id: global.idProfile,
                pref: globals.passPrefer);
            if (profileExist.isEmpty) profileExist.add(name);
            print('prof = $profileExist');
          }
        }
        break;
      case AppLifecycleState.paused:
        print("PAUSED");
        if (dismissLifecycle == false) {
          BlocProvider.of<AuthProfileBloc>(context).add(LoggedOut());
          BlocProvider.of<CloseDbBloc>(this.context)
            ..add(UpdateProfile(idProfile: global.idProfile));
          int? onBoard = box.read('onBoard');
          if (onBoard == 2) {
            var name = ProfileModel(
                nameProfile: globals.nameProfile,
                id: global.idProfile,
                pref: globals.passPrefer);
            if (profileExist.isEmpty) profileExist.add(name);
            print('prof = $profileExist');
          }
          if (Platform.isIOS) {
            _channelIOS.setMethodCallHandler(_importZipFile);
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (dismissLifecycle == false) {
          print("RESUMED");
          String locale = box.read('stringLocaleShPref') ?? 'language';
          print('locale = $locale');
          if (locale == 'Системный(Русский)' ||
              locale == 'System(English)' ||
              locale == 'language') {
            if (View.of(context)
                .platformDispatcher
                .locale
                .toString()
                .contains('ru')) {
              context.setLocale(Locale('ru'));
            } else {
              context.setLocale(Locale('en'));
            }
          }
          _customAppNavigation(false);
        }
        break;
      case AppLifecycleState.detached:
        print("DETACHED");
        break;
    }
  }
}
