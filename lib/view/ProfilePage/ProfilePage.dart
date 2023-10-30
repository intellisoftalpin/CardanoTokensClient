import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/bloc/ProfileBloc/ProfileBloc.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/ListCoin.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/AddCoinPage/AddCoinPage.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:crypto_offline/view/ProfilePage/AboutPage.dart';
import 'package:crypto_offline/view/ProfilePage/CardanoDescriptionPage.dart';
import 'package:crypto_offline/view/ProfilePage/InputPasswordPage.dart';
import 'package:crypto_offline/view/ProfilePage/InputPasswordPage.dart'
    as input;
import 'package:crypto_offline/view/ProfilePage/ProfileTransactionsPage.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../../bloc/AuthenticateProfile/AuthProfileBloc.dart';
import '../../bloc/AuthenticateProfile/AuthProfileEvent.dart';
import '../../bloc/CloseDbBloc/CloseDbBloc.dart';
import '../../data/dbhive/HivePrefProfileRepository.dart';
import '../../data/model/CardanoModel.dart';
import '../../data/repository/ApiRepository/CardanoTokensApi.dart';
import '../utils/CaradanoTokenListTile.dart';
import '../../utils/check_create_profile_time.dart';
import '../OnBoardingPages/SecondOnBoardScreen.dart';
import 'BackupRestorePage.dart';

import 'WebBlogPage.dart';
import 'EditProfilePage.dart';
import 'SettingsPage.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/bloc/ProfileBloc/ProfileBloc.dart' as delete;

int selectedIndex = 0;
bool tokensPageLiq = true;
bool loadTokens = false;
List<Tokens> cardanoTokensGlobal = [];
double scrollPosition = 0.0;

class ProfilePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => ProfilePage());
  }

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  final CardanoTokensApi _cardanoTokensApi = CardanoTokensApi();
  SharedPreferences? preferences;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  late int walletBalanceWeight;
  List<ListCoin> listCoinDb = [];
  static List<ProfileModel> profile = [];
  List<CoinEntity> coinsList = [];
  List<double> wallet = [];
  List<double> walletAda = [];
  List<TransactionEntity> transactionEntity = [];
  String id = '';
  static String aboutUrl = "https://ctokens.io/mobile-privacy-policy";
  static String blogUrl = "https://ctokens.io/blog";
  static String privacyUrl = "";
  static bool isCreateNewPortfolio = false;
  late DateTime currentBackPressTime;
  bool _isVisible = false;
  PageController pageController = PageController(
    initialPage: selectedIndex,
  );
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: scrollPosition);

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  static String codes(BuildContext context) {
    final languageFromPhoneSettings =
        View.of(context).platformDispatcher.locale;
    var systemAppLanguage = '';
    if (languageFromPhoneSettings.languageCode.contains('ru')) {
      print("Russian");
      systemAppLanguage = 'ru';
    } else if (languageFromPhoneSettings.languageCode.contains('en')) {
      print("English");
      systemAppLanguage = 'en';
    } else {
      print("Unknown");
      systemAppLanguage = 'en';
    }
    print("SystemLocale - $systemAppLanguage");
    return systemAppLanguage;
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    initializePreference().whenComplete(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      scrollPosition = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Tokens>> _cardanoTokens() async {
    List<Tokens> tokens = [];
    if (loadTokens == false) {
      cardanoTokensGlobal = await _cardanoTokensApi.getCardanoTokens();
      tokens = cardanoTokensGlobal;
      loadTokens = true;
    } else {
      tokens = cardanoTokensGlobal;
    }
    if (tokensPageLiq) {
      tokens.sort((b, a) => a.liquidAda!.compareTo(b.liquidAda!));
    } else {
      tokens.sort((b, a) => a.capUsd!.compareTo(b.capUsd!));
    }
    print('tokens: $tokens');
    return tokens;
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void pageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('selectedIndex::: $selectedIndex');
    AppBar appBar = AppBar();
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print(
        'ProfilePage  screenHeight = $screenHeight, screenWidth = $screenWidth');
    return DoubleBack(
        message: LocaleKeys.double_back_exit.tr(),
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
                // buildWhen: (previous, current) => previous != current || previous.profile != current.profile,
                builder: (context, state) {
              switch (state.state) {
                case ProfileStatus.start:
                  print('start');
                  //  context.read<ProfileBloc>().add(CreateProfile());
                  return SplashPage();
                case ProfileStatus.loading:
                  print('loading');
                  profile = state.profile;
                  var error = (state.isErrorEmpty!)
                      ? ''
                      : LocaleKeys.incorrect_password_try_again.tr();
                  print(
                      " loading profile = $profile , isErrorEmpty = ${state.isErrorEmpty} globals.pass = ${globals.pass}");
                  return InputPasswordPage(globals.nameProfile,
                      global.idProfile, ' ', error, profile);
                case ProfileStatus.load:
                  print('load');
                  profile = state.profile;
                  print(" load profile = $profile");
                  return SplashPage();
                case ProfileStatus.loaded:
                  print('loaded');
                  saveTemporaryPass();
                  profile = state.profile;
                  listCoinDb = state.listCoin!;
                  print(
                      " loaded profile = $profile, state.profile = ${state.profile}");
                  print("listCoinDb = $listCoinDb");
                  appBar = AppBar(
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            selectedIndex == 0
                                ? globals.nameProfile
                                : LocaleKeys.cardanoTokens.tr(),
                            style: kAppBarTextStyle(context),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      selectedIndex == 0
                          ? listCoinDb.isEmpty
                              ? Visibility(
                                  child: getIconAdd(context),
                                  visible: _isVisible,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                )
                              : Visibility(
                                  visible: !_isVisible,
                                  child: getIconAdd(context),
                                )
                          : Visibility(
                              child: getIconAdd(context),
                              visible: _isVisible,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                            )
                    ],
                    leading: IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: Theme.of(context)
                            .iconTheme
                            .copyWith(size: MediumIcon)
                            .size,
                        color: Theme.of(context).focusColor,
                      ),
                      onPressed: () => {
                        scaffoldKey.currentState!.openDrawer(),
                      },
                    ),
                  );
                  wallet = state.wallet!;
                  walletAda = state.walletAda!;
                  print("ProfilePage wallet = $wallet");
                  print("ProfilePage walletAda = $walletAda");
                  globals.profiles = profile;
                  wallet = (wallet.isEmpty) ? wallet = [0.0] : wallet;
                  walletAda =
                      (walletAda.isEmpty) ? walletAda = [0.0] : walletAda;
                  //SplashPage();
                  return Scaffold(
                      key: scaffoldKey,
                      backgroundColor: Theme.of(context).primaryColor,
                      appBar: appBar,
                      body: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          onItemTapped(index);
                        },
                        children: [
                          profilePage(context, state, appBar),
                          tokensPage(context, appBar),
                        ],
                      ),
                      drawer: FutureBuilder(
                          future: getProfilesToDraw(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<ProfileModel>> snapshot) {
                            if (snapshot.hasData) {
                              return getDrawMenu(
                                  context, _packageInfo, snapshot.data!);
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                      bottomNavigationBar: SizedBox(
                          height: Platform.isIOS ? 90.0 : 65.0,
                          child: BottomNavigationBar(
                            backgroundColor: Theme.of(context).highlightColor,
                            type: BottomNavigationBarType.fixed,
                            showSelectedLabels: true,
                            showUnselectedLabels: true,
                            selectedFontSize: 10,
                            unselectedFontSize: 10,
                            items: <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Image.asset('assets/icons/bnb_wallet.png',
                                    width: 23,
                                    height: 23,
                                    color: bnbUnSelectedColor),
                                activeIcon: Image.asset(
                                    'assets/icons/bnb_wallet.png',
                                    width: 27,
                                    height: 27,
                                    color: bnbSelectedColor),
                                label: LocaleKeys.bnb_portfolio.tr(),
                              ),
                              BottomNavigationBarItem(
                                icon: Image.asset(
                                    'assets/icons/bnb_cardano.png',
                                    width: 23,
                                    height: 23,
                                    color: bnbUnSelectedColor),
                                activeIcon: Image.asset(
                                    'assets/icons/bnb_cardano.png',
                                    width: 27,
                                    height: 27,
                                    color: bnbSelectedColor),
                                label: LocaleKeys.bnb_tokens.tr(),
                              ),
                            ],
                            currentIndex: selectedIndex,
                            unselectedIconTheme: IconThemeData(
                                color: bnbUnSelectedColor, size: 23.0),
                            selectedItemColor: bnbSelectedColor,
                            onTap: (index) {
                              bottomTapped(index);
                            },
                            unselectedItemColor: bnbUnSelectedColor,
                            unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 12),
                            selectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          )));
                case ProfileStatus.update:
                  return SplashPage();
              }
            })));
  }

  Widget profilePage(BuildContext context, ProfileState state, AppBar appBar) {
    return Container(
        height: MediaQuery.of(context).size.height -
            65.0 -
            appBar.preferredSize.height -
            MediaQuery.of(context).viewPadding.top,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox(
                    height: 15.0,
                    child: Text(
                      '${LocaleKeys.last_update.tr()} ${delete.exchangeTimeGlobal}',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).focusColor,
                        fontSize: textSize13,
                      ),
                    ))),
            getWalletBalanceColumn(context),
            (state.listCoin!.isEmpty)
                ? Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCoinPage()));
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(46.0)),
                                backgroundColor:
                                    Theme.of(context).secondaryHeaderColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 23, horizontal: 23)),
                            child: new Icon(Icons.add,
                                size: MediaQuery.of(context).size.width * 0.12,
                                color: Theme.of(context).shadowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            LocaleKeys.press_add_coin.tr(),
                            style: TextStyle(
                                fontSize: textSize18,
                                color: Theme.of(context).hintColor),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: RefreshIndicator(
                        onRefresh: () {
                          return Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              context.read<ProfileBloc>().add(CreateProfile());
                              state.listCoin!;
                              scaffoldKey.currentState;
                            });
                          });
                        },
                        child: ListView.builder(
                            itemCount: state.listCoin!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return getListCoin(index, state);
                            })),
                  ),
          ],
        ));
  }

  Widget tokensPage(BuildContext context, AppBar appBar) {
    return Container(
        height: MediaQuery.of(context).size.height -
            65.0 -
            appBar.preferredSize.height -
            MediaQuery.of(context).viewPadding.top,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: 25.0,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    child: Text(
                      LocaleKeys.rank.tr(),
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).focusColor,
                        fontSize: textSize14,
                      ),
                    ),
                  ),
                  Switch(
                    value: tokensPageLiq,
                    activeColor: Theme.of(context).secondaryHeaderColor,
                    onChanged: (bool value) {
                      setState(() {
                        tokensPageLiq = value;
                      });
                    },
                  ),
                  SizedBox(
                    child: Text(
                      LocaleKeys.liquidity.tr(),
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).focusColor,
                        fontSize: textSize14,
                      ),
                    ),
                  )
                ])),
            Container(
                width: MediaQuery.of(context).size.width - 10,
                height: 25.0,
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 40) * 0.1,
                      child: Text(
                        '№',
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).focusColor,
                          fontSize: textSize14,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 40) * 0.25 +
                          30.0,
                      child: Text(
                        LocaleKeys.coin.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).focusColor,
                          fontSize: textSize14,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 40) * 0.25,
                      child: Text(
                        '${LocaleKeys.price.tr()}(₳/\$)',
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).focusColor,
                          fontSize: textSize14,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 40) * 0.4,
                      child: Text(
                        tokensPageLiq
                            ? LocaleKeys.liquidity.tr()
                            : LocaleKeys.rank.tr(),
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).focusColor,
                          fontSize: textSize14,
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(
                height: MediaQuery.of(context).size.height -
                    115.0 -
                    appBar.preferredSize.height -
                    MediaQuery.of(context).viewPadding.top,
                child: FutureBuilder<List<Tokens>>(
                  future: _cardanoTokens(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Tokens>> snapshot) {
                    if (snapshot.hasData) {
                      return (snapshot.data!.isEmpty)
                          ? Center(
                              child: Text(
                                LocaleKeys.no_internet_connection.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () {
                                return Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    loadTokens = false;
                                    _cardanoTokens();
                                  });
                                });
                              },
                              child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      child: getCardanoCoinTile(
                                          context,
                                          index + 1,
                                          snapshot.data![index],
                                          tokensPageLiq,
                                          delete.exchangeGlobal),
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CardanoDescriptionPage(
                                                        token: snapshot
                                                            .data![index],
                                                        exchangeAda: delete
                                                            .exchangeGlobal)));
                                      },
                                    );
                                  }));
                    } else {
                      return const Center(
                        child: SizedBox(
                            height: 25.0,
                            width: 25.0,
                            child: CircularProgressIndicator()),
                      );
                    }
                  },
                ))
          ],
        ));
  }

  Future<List<ProfileModel>> getProfilesToDraw() async {
    List<ProfileModel> profiles = [];
    HivePrefProfileRepository _hiveProfileRepository =
        HivePrefProfileRepositoryImpl();
    profiles = await _hiveProfileRepository.showProfile();
    return profiles;
  }

  static Widget getDrawMenu(
      BuildContext context, PackageInfo info, List<ProfileModel> profile) {
    print("profile.length = ${profile.length}");
    print("profile.isEmpty = ${profile.isEmpty}");
    String version = info.version;
    int dots = version.replaceAll(new RegExp(r'[^\\.]'), '').length;
    if (dots == 3) {
      var pos = version.lastIndexOf('.');
      version = (pos != -1) ? version.substring(0, pos) : version;
      print('VERSION:: $version');
    }
    int prefGlob = globals.passPrefer;
    return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          elevation: 16.0,
          child: ListView(
            children: <Widget>[
              Container(
                  height: 80.0,
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          height: 80.0,
                          width: 80,
                          child: CircleAvatar(
                            radius: 35.0,
                            backgroundColor: Colors.transparent,
                            child: Image(
                              image:
                                  AssetImage('assets/icons/cardano_logo.png'),
                              fit: BoxFit.cover,
                            ),
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          width:
                              MediaQuery.of(context).size.width * 0.85 - 160.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Cardano Tokens",
                                style: TextStyle(
                                  fontSize: textSize20,
                                ),
                              ),
                              SizedBox(width: 2.0),
                              Text(
                                "v. $version",
                                style: TextStyle(
                                  fontSize: textSize13,
                                ),
                              ),
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          width: 80.0,
                          height: 80.0,
                          alignment: Alignment.topCenter,
                          child: Container(
                              alignment: Alignment.center,
                              width: 45.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    width: 1.0,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  )),
                              child: InkWell(
                                  onTap: () {
                                    isCreateNewPortfolio = true;
                                    BlocProvider.of<CloseDbBloc>(context).add(
                                        UpdateProfile(
                                            idProfile: global.idProfile));
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SecondOnBoardScreen(
                                                    appBarBackArrow: IconButton(
                                                  icon: Icon(
                                                    Icons.arrow_back_ios,
                                                    size: 35.0,
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProfilePage()))
                                                  },
                                                ))),
                                        (Route<dynamic> route) => true);
                                  },
                                  child: Icon(
                                    Icons.add,
                                    size: 25.0,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .copyWith(
                                            color:
                                                Theme.of(context).shadowColor)
                                        .color,
                                  ))))
                    ],
                  )),
              Container(
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5.0),
                    itemCount: profile.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              width: 1.0,
                              color: (profile[index].id == global.idProfile &&
                                      profile[index].nameProfile ==
                                          globals.nameProfile &&
                                      profile.length > 1)
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Colors.transparent,
                            )),
                        child: InkWell(
                          onTap: () {
                            String oldId = global.idProfile;
                            String id = profile[index].id!;
                            String name = profile[index].nameProfile!;
                            if (id == global.idProfile &&
                                name == globals.nameProfile) {
                              Navigator.pop(context);
                            } else {
                              BlocProvider.of<CloseDbBloc>(context)
                                  .add(UpdateProfile(idProfile: oldId));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => InputPasswordPage(
                                      name, id, '', '', profile)));
                              print(
                                  "profile.elementAt(index) = ${profile[index].nameProfile} "
                                  " profile.elementAt(index)Id = ${profile[index].id}");
                              globals.nameProfile = name;
                              global.idProfile = id;
                              globals.passPrefer = profile[index].pref!;
                              input.passIsEmpty = false;
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  width: 30.0,
                                  child: Icon(Icons.perm_identity,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.85 -
                                        75.0,
                                child: Text(
                                  profile[index].nameProfile!,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      fontSize: textSize17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Container(
                                  width: 25.0,
                                  height: 40.0,
                                  alignment: Alignment.center,
                                  child: Container(
                                      alignment: Alignment.center,
                                      width: 25.0,
                                      height: 25.0,
                                      decoration: BoxDecoration(
                                          color: (profile[index].id ==
                                                      global.idProfile &&
                                                  profile[index].nameProfile ==
                                                      globals.nameProfile)
                                              ? Theme.of(context)
                                                  .secondaryHeaderColor
                                              : Theme.of(context).hoverColor,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                            width: 1.0,
                                            color: (profile[index].id ==
                                                        global.idProfile &&
                                                    profile[index]
                                                            .nameProfile ==
                                                        globals.nameProfile)
                                                ? Theme.of(context)
                                                    .secondaryHeaderColor
                                                : Theme.of(context).hoverColor,
                                          )),
                                      child: InkWell(
                                          onTap: () {
                                            String id = profile[index].id!;
                                            String name =
                                                profile[index].nameProfile!;
                                            if (id == global.idProfile &&
                                                name == globals.nameProfile) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfilePage()));
                                            } else {
                                              BlocProvider.of<AuthProfileBloc>(
                                                      context)
                                                  .add(LoggedOut());
                                              BlocProvider.of<CloseDbBloc>(
                                                  context)
                                                ..add(UpdateProfile(
                                                    idProfile:
                                                        global.idProfile));
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          InputPasswordPage(
                                                              globals
                                                                  .nameProfile,
                                                              global.idProfile,
                                                              '',
                                                              '',
                                                              profile)),
                                                  (Route<dynamic> route) =>
                                                      false);
                                            }
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 20.0,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .shadowColor)
                                                .color,
                                          )))),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              Divider(
                  height: 0.4,
                  color: Theme.of(context)
                      .cardTheme
                      .copyWith(color: Theme.of(context).hintColor)
                      .color),
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 40.0,
                      child: InkWell(
                        onTap: () {
                          final systemAppLanguage = codes(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                        systemAppLanguage: systemAppLanguage,
                                      )));
                        },
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                alignment: Alignment.center,
                                width: 15.0,
                                child: Icon(Icons.settings,
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.85 -
                                  35.0,
                              child: Text(
                                LocaleKeys.settings.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: textSize17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BackupRestorePage()));
                        },
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                alignment: Alignment.center,
                                width: 15.0,
                                child: Icon(Icons.refresh_rounded,
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.85 -
                                  35.0,
                              child: Text(
                                LocaleKeys.backup_restore.tr(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: textSize17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: InkWell(
                        onTap: () {
                          final url = Uri.parse("$aboutUrl");
                          print('LAUNCH_URL: $url');
                          launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                          //Navigator.push(
                          //    context,
                          //    MaterialPageRoute(
                          //        builder: (context) =>
                          //            PrivacyPolicyPage(aboutUrl)));
                        },
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                alignment: Alignment.center,
                                width: 15.0,
                                child: Icon(Icons.lock_outlined,
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.85 -
                                  35.0,
                              child: Text(
                                LocaleKeys.privacy_policy.tr(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: textSize17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: InkWell(
                        onTap: () {
                          String platform = "Unknown";
                          String image = "";
                          if (Platform.isAndroid) {
                            if (Theme.of(context).primaryColor ==
                                lBackgroundColor) {
                              image = 'assets/icons/android_lt.svg';
                            } else if (Theme.of(context).primaryColor ==
                                kBackgroundColor) {
                              image = 'assets/icons/android.svg';
                            }
                            platform = "Android";
                          } else if (Platform.isIOS) {
                            if (Theme.of(context).primaryColor ==
                                lBackgroundColor) {
                              image = 'assets/icons/ios_lt.svg';
                            } else if (Theme.of(context).primaryColor ==
                                kBackgroundColor) {
                              image = 'assets/icons/ios.svg';
                            }
                            platform = "IOS";
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutPage(
                                platform: "$platform",
                                image: image,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                alignment: Alignment.center,
                                width: 15.0,
                                child: Icon(Icons.file_present,
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.85 -
                                  35.0,
                              child: Text(
                                LocaleKeys.about.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: textSize17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WebBlogPage(url: blogUrl)));
                        },
                        child: Row(
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                alignment: Alignment.center,
                                width: 15.0,
                                child: Icon(Icons.sticky_note_2_outlined,
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.85 -
                                  35.0,
                              child: Text(
                                LocaleKeys.cardanoBlog.tr(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: textSize17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              prefGlob != 3
                  ? Divider(
                      height: 0.4,
                      color: Theme.of(context)
                          .cardTheme
                          .copyWith(color: Theme.of(context).hintColor)
                          .color)
                  : SizedBox.shrink(),
              prefGlob != 3
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color:
                                      Theme.of(context).secondaryHeaderColor)),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                            onPressed: () {
                              BlocProvider.of<CloseDbBloc>(context).add(
                                  UpdateProfile(idProfile: global.idProfile));
                              globals.passChosen = false;
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => InputPasswordPage(
                                          globals.nameProfile,
                                          global.idProfile,
                                          '',
                                          '',
                                          profile)),
                                  (Route<dynamic> route) => false);
                            },
                            child: Text(
                              LocaleKeys.lock_app_button.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).shadowColor,
                                  fontFamily: 'MyriadPro',
                                  fontSize: textSize20),
                            ),
                            /*Image(
                        width: 22.0,
                          height: 22.0,
                          image: AssetImage('assets/icons/edit.png'),
                      ),*/
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ));
  }

  Widget getIconAdd(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.add,
        size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
        color: Theme.of(context).brightness == Brightness.dark
            ? kPlusIconColor
            : lPlusIconColor,
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddCoinPage()));
      },
    );
  }

  Widget getWalletBalanceColumn(BuildContext context) {
    wallet = (wallet.isEmpty) ? wallet = [0.0] : wallet;
    walletAda = (walletAda.isEmpty) ? walletAda = [0.0] : walletAda;
    String walletUsd = '';
    String walletAdaStr = '';
    double usd = Decimal.convertPriceRoundToDouble(wallet.first);
    double ada = Decimal.convertPriceRoundToDouble(walletAda.first);

    if (usd < 0.0) {
      walletUsd =
          '-${(wallet.first * -1 > 1.0) ? Decimal.dividePrice((usd * -1).toString()) : (usd * -1).toString()}';
    } else {
      walletUsd =
          '${(wallet.first > 1.0) ? Decimal.dividePrice(usd.toString()) : usd.toString()}';
    }
    if (ada < 0.0) {
      walletAdaStr =
          '-${(walletAda.first * -1 > 1.0) ? Decimal.dividePrice((ada * -1).toString()) : (ada * -1).toString()}';
    } else {
      walletAdaStr =
          '${(walletAda.first > 1.0) ? Decimal.dividePrice(ada.toString()) : ada.toString()}';
    }

    int menuItem = this.preferences?.getInt("menuPosition") ?? 1;
    String menuText = LocaleKeys.holdings.tr();
    Color check1 = Colors.transparent;
    Color check2 = Colors.transparent;
    Color check3 = Colors.transparent;
    Color check4 = Colors.transparent;
    Color check5 = Colors.transparent;
    if (menuItem == 1) {
      check1 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.holdings.tr();
    } else if (menuItem == 2) {
      check2 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.liquidity.tr();
    } else if (menuItem == 3) {
      check3 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_up.tr();
    } else if (menuItem == 4) {
      check4 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_down.tr();
    } else if (menuItem == 5) {
      check5 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.alphabet_sort.tr();
    }
    Widget sumUsdSumAda = Container(
      width: MediaQuery.of(context).size.width - 16.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 20.0,
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 6.0),
              child: Text(
                '\$ $walletUsd',
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Theme.of(context).shadowColor,
                  fontSize: textSize24,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2 - 20.0,
            alignment: Alignment.topRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 16.0, top: 6.0, bottom: 6.0),
              child: Text(
                '₳ $walletAdaStr',
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Theme.of(context).shadowColor,
                  fontSize: textSize24,
                ),
              ),
            ),
          )
        ],
      ),
    );
    if (walletAdaStr.length > 9 || walletUsd.length > 9) {
      sumUsdSumAda = Container(
        width: MediaQuery.of(context).size.width - 16.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 20.0,
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 6.0),
                child: Text(
                  '\$ $walletUsd',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).shadowColor,
                    fontSize: textSize24,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 20.0,
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                child: Text(
                  '₳ $walletAdaStr',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).shadowColor,
                    fontSize: textSize24,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 16.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 16.0) *
                                      0.6,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Text(
                                  LocaleKeys.wallet_balance.tr(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: textSize14,
                                      color: Theme.of(context).shadowColor),
                                ),
                              )),
                          Container(
                              margin:
                                  const EdgeInsets.only(right: 8.0, top: 8.0),
                              alignment: Alignment.topRight,
                              child: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).shadowColor,
                                        width: 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Text(
                                    (delete.exchangeGlobal != 0.0)
                                        ? '1 ₳ = ${delete.exchangeGlobal.toStringAsFixed(2)}\$'
                                        : '${LocaleKeys.no_internet.tr()}',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context).shadowColor,
                                      fontSize: textSize14,
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                    sumUsdSumAda
                  ]),
            ),
            PopupMenuButton<int>(
                padding: EdgeInsets.all(0.0),
                color: Theme.of(context).unselectedWidgetColor,
                offset: Offset(10.0, 65.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          menuText,
                          style: TextStyle(
                              fontSize: textSize18,
                              color: Theme.of(context).shadowColor),
                        ),
                      ),
                      Container(
                        width: 30.0,
                        height: 64.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down_outlined,
                              color: Theme.of(context).shadowColor),
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 1);
                    });
                  }
                  if (value == 2) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 2);
                    });
                  }
                  if (value == 3) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 3);
                    });
                  }
                  if (value == 4) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 4);
                    });
                  }
                  if (value == 5) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 5);
                    });
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check1),
                            Text(LocaleKeys.holdings.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check2),
                            Text(LocaleKeys.liquidity.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 3,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check3),
                            Text(LocaleKeys.trend_up.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 4,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check4),
                            Text(LocaleKeys.trend_down.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 5,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check5),
                            Text(LocaleKeys.alphabet_sort.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                    ]),
          ],
        ),
      ),
    );
  }

  Widget getListCoin(int index, ProfileState state) {
    print(" !!! isRelevant = ${state.listCoin![index].isRelevant}");
    String arrowImage = 'assets/image/arrow_up.png';
    String warningImage = 'assets/image/warning.png';
    Color arrowColor = kInIconColor;
    Color isNotRelevantColor = lTextSecondaryColor;
    Color isRelevantColor = Theme.of(context).secondaryHeaderColor;
    int menuItem = this.preferences?.getInt("menuPosition") ?? 1;
    print('percentChange24h::: ${state.listCoin![index].percentChange24h!}');
    print('percentChange7d::: ${state.listCoin![index].percentChange7d!}');
    print('liquidAda::: ${state.listCoin![index].liquidAda}');
    if (menuItem == 1) {
      state.listCoin!.sort((a, b) => b.costUsd.compareTo(a.costUsd));
    } else if (menuItem == 2) {
      state.listCoin!.sort((b, a) => a.liquidAda!.compareTo(b.liquidAda!));
    } else if (menuItem == 3) {
      state.listCoin!
          .sort((a, b) => b.percentChange7d!.compareTo(a.percentChange7d!));
    } else if (menuItem == 4) {
      state.listCoin!
          .sort((a, b) => a.percentChange7d!.compareTo(b.percentChange7d!));
    } else if (menuItem == 5) {
      state.listCoin!
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    if (state.listCoin![index].percentChange7d! < 0) {
      arrowImage = 'assets/image/arrow_down.png';
      arrowColor = kOutIconColor;
    } else {
      arrowImage = 'assets/image/arrow_up.png';
      arrowColor = kInIconColor;
    }
    return state.listCoin![index].isRelevant == 1
        ? getCardListCoin(index, state, arrowImage, arrowColor, isRelevantColor)
        : Opacity(
            opacity: 0.6,
            child: getCardListCoin(
                index, state, warningImage, arrowColor, isNotRelevantColor));
  }

  Widget getCardListCoin(int index, ProfileState state, String arrowImage,
      Color arrowColor, Color color) {
    String qtyStr = '';
    String sumUsd = '';
    String sumAda = '';
    String priceChangeUsd = '';
    String priceChangeAda = '';
    double qty =
        Decimal.convertPriceRoundToDouble(state.listCoin![index].quantity);
    double usd =
        Decimal.convertPriceRoundToDouble(state.listCoin![index].costUsd);
    double ada =
        Decimal.convertPriceRoundToDouble(state.listCoin![index].costAda);
    double changeUsd =
        Decimal.convertPriceRoundToDouble(state.listCoin![index].price!);
    double changeAda =
        Decimal.convertPriceRoundToDouble(state.listCoin![index].adaPrice!);
    priceChangeUsd =
        '\$${(state.listCoin![index].price! > 1.0) ? Decimal.dividePrice(changeUsd.toString()) : changeUsd.toString()}';
    priceChangeAda =
        '₳${(state.listCoin![index].adaPrice! > 1.0) ? Decimal.dividePrice(changeAda.toString()) : changeAda.toString()}';

    if (qty < 0.0) {
      qtyStr =
          '-${(state.listCoin![index].quantity * -1 > 1.0) ? Decimal.dividePrice((qty * -1).toString()) : (qty * -1).toString()}';
    } else {
      qtyStr =
          '${(state.listCoin![index].quantity > 1.0) ? Decimal.dividePrice(qty.toString()) : qty.toString()}';
    }
    if (usd < 0.0) {
      sumUsd =
          '-${(state.listCoin![index].costUsd * -1 > 1.0) ? Decimal.dividePrice((usd * -1).toString()) : (usd * -1).toString()}\$';
    } else {
      sumUsd =
          '${(state.listCoin![index].costUsd > 1.0) ? Decimal.dividePrice(usd.toString()) : usd.toString()}\$';
    }
    if (ada < 0.0) {
      sumAda =
          '-${(state.listCoin![index].costAda * -1 > 1.0) ? Decimal.dividePrice((ada * -1).toString()) : (ada * -1).toString()}₳';
    } else {
      sumAda =
          '${(state.listCoin![index].costAda > 1.0) ? Decimal.dividePrice(ada.toString()) : ada.toString()}₳';
    }

    print('SUMADA_LENGTH: ${sumAda.length}');
    Widget sumUsdSumAda = Container(
      alignment: Alignment.center,
      height: 40.0,
      width: (MediaQuery.of(context).size.width - 30) / 1.65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 2.5),
            height: 20.0,
            child: Text(
              sumUsd,
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: GoogleFonts.inter(
                color: Theme.of(context).focusColor,
                fontSize: textSize17,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 2.5),
            height: 20.0,
            child: Text(
              sumAda,
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: GoogleFonts.inter(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: textSize17,
              ),
            ),
          ),
        ],
      ),
    );
    if (sumAda.length > 10 || sumUsd.length > 10) {
      sumUsdSumAda = Container(
        height: 40.0,
        width: (MediaQuery.of(context).size.width - 30) / 1.65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.0,
              child: Text(
                sumUsd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: GoogleFonts.inter(
                  color: Theme.of(context).focusColor,
                  fontSize: textSize17,
                ),
              ),
            ),
            Container(
              height: 20.0,
              child: Text(
                sumAda,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: GoogleFonts.inter(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: textSize17,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Card(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: InkWell(
        child: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 30) / 6,
              height: 100.0,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 3, left: 4),
                    child: CircleAvatar(
                      radius: 19.0,
                      backgroundColor: Colors.transparent,
                      child: /*FutureBuilder(
                          future: checkContainImage(
                              'assets/image/${state.listCoin![index].symbol.toLowerCase()}.png'),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done)
                              return snapshot.data!;
                            else
                              return Image.asset('assets/image/place_holder.png');
                          },
                        ),*/
                          CachedNetworkImage(
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        imageUrl: '${state.listCoin![index].image}',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => FutureBuilder(
                          future: checkContainImage(
                              'assets/image/${state.listCoin![index].symbol.toLowerCase()}.png'),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done)
                              return snapshot.data!;
                            else
                              return Image.asset(
                                  'assets/image/place_holder.png');
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8.0, bottom: 6.0, top: 4.0),
                    child: Text(
                      "Liq.:\n₳${NumberFormat.compactCurrency(
                        locale: 'EN',
                        decimalDigits: 2,
                        symbol: '',
                      ).format(state.listCoin![index].liquidAda)}",
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).focusColor,
                        fontSize: textSize12,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 38.0,
                    margin: EdgeInsets.only(bottom: 1.0),
                    child: SizedBox(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18.0, color: color),
                        Text(
                          "${state.listCoin![index].rank}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: ProfileCoinSmallText),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            SizedBox(width: (MediaQuery.of(context).size.width - 30) / 30),
            Container(
              width: (MediaQuery.of(context).size.width - 30) / 1.65,
              height: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 25.0,
                    margin: EdgeInsets.only(bottom: 2.5, top: 2.5),
                    child: Text(
                      '${state.listCoin![index].name}',
                      style: TextStyle(fontSize: ProfileCoinBigText),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width - 30) / 1.57,
                    margin: EdgeInsets.only(bottom: 2.5),
                    height: 22.5,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            qtyStr,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(fontSize: textSize18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sumUsdSumAda
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              width: (MediaQuery.of(context).size.width - 30) / 5.2,
              height: 95,
              child: Column(
                children: [
                  SizedBox(
                      height: 13,
                      child: Text(
                        priceChangeAda,
                        //state.coinsList![index].name,
                        style: GoogleFonts.inter(
                            fontSize: textSize10,
                            color: Theme.of(context).focusColor),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      )),
                  SizedBox(
                      height: 13,
                      child: Text(
                        priceChangeUsd,
                        //state.coinsList![index].name,
                        style: GoogleFonts.inter(
                            fontSize: textSize10,
                            color: Theme.of(context).focusColor),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      )),
                  SizedBox(height: 2.5),
                  SizedBox(
                      height: 45,
                      child: arrowImage == 'assets/image/warning.png'
                          ? Image.asset(
                              arrowImage,
                              // color: arrowColor,
                              height: 45,
                              width: (MediaQuery.of(context).size.width - 30) /
                                  16.5,
                            )
                          : Image.asset(
                              arrowImage,
                              color: arrowColor,
                              height: 45,
                              width: (MediaQuery.of(context).size.width - 30) /
                                  16.5,
                            )),
                  SizedBox(height: 2.5),
                  SizedBox(
                      height: 15,
                      child: Text(
                        "${state.listCoin![index].percentChange7d!.toStringAsFixed(2)}\% 7d",
                        //state.coinsList![index].name,
                        style: TextStyle(
                            fontSize: textSize11,
                            color: Theme.of(context).focusColor),
                      )),
                ],
              ),
              //IconButton(
              //  icon: const Icon(Icons.add),
              //  onPressed: () => {
              //    id = state.listCoin![index].coinId,
              //    print(id),
              //    Navigator.push(
              //        context,
              //        MaterialPageRoute(
              //            builder: (context) => TransactionsPage(
              //                symbol: state.listCoin![index].symbol,
              //                id: id,
              //                transactionId: -1))),
              //  },
              //),
            ),
          ],
        ),
        onLongPress: () {
          id = state.listCoin![index].coinId;
          deleteCoinAlert(context, state, id);
        },
        onTap: () => {
          id = state.listCoin![index].coinId,
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileTransactionsPage(
                        id: id,
                        name: state.listCoin![index].name,
                        symbol: state.listCoin![index].symbol,
                        image: state.listCoin![index].image,
                        isRelevant: state.listCoin![index].isRelevant,
                      ))),
        },
      ),
    );
  }

  Future<void> deleteCoinAlert(
      BuildContext context, ProfileState state, String coinId) async {
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
                LocaleKeys.deleteCoinText.tr(),
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
                          print('coinId_prof = $coinId');
                          delete.coinIdToDelete = coinId;
                          //setState(() {
                          //  cont.read<ProfileBloc>().add(CreateProfile());
                          //  state.listCoin!;
                          //  scaffoldKey.currentState;
                          //  _exchangeAda(true);
                          //});
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                              (Route<dynamic> route) => false);
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
                          Navigator.of(context).pop();
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

  saveTemporaryPass() {
    int pref = globals.passPrefer;
    if (pref == 0) {
      int? createDate =
          box.read('${globals.nameProfile + global.idProfile}create_time');
      int? enterDate =
          box.read('${globals.nameProfile + global.idProfile}enter_time');
      DateTime? profileCreateDate =
          DateTime.fromMillisecondsSinceEpoch(createDate!);
      DateTime? profileEnterDate =
          DateTime.fromMillisecondsSinceEpoch(enterDate!);
      if (createTimeCheck(profileCreateDate, profileEnterDate)) {
        box.write('${globals.nameProfile + global.idProfile}enter_time',
            DateTime.now().millisecondsSinceEpoch);
        box.write(
            '${globals.nameProfile + global.idProfile}pass', globals.pass);
        print('DONE!!!!!!!');
      }
    }
  }
}
