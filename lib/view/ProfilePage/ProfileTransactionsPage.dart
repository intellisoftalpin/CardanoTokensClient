import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionEvent.dart';
import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/repository/ApiRepository/IApiRepository.dart';
import 'ProfilePage.dart';
import 'TransactionDetailsPage.dart';
import 'TransactionsPage.dart';

class ProfileTransactionsPage extends StatefulWidget {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final int isRelevant;

  ProfileTransactionsPage(
      {required this.id,
      required this.name,
      required this.symbol,
      required this.image,
      required this.isRelevant});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => ProfileTransactionsPage(
              id: '',
              name: '',
              symbol: '',
              image: '',
              isRelevant: 1,
            ));
  }

  @override
  _ProfileTransactionsPageState createState() =>
      _ProfileTransactionsPageState(id, name, symbol, image, isRelevant);
}

class _ProfileTransactionsPageState extends State<ProfileTransactionsPage> {
  _ProfileTransactionsPageState(
      this.id, this.name, this.symbol, this.image, this.isRelevant);

  String id;
  String name;
  String symbol;
  String image;
  int isRelevant;

  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  late GlobalKey<ScaffoldState> scaffoldKey;
  List<TransactionEntity> transactionList = [];
  List<TransactionEntity> sortTransactionList = [];
  List<double> walletCoin = [];
  List<double> walletAda = [];
  String minus = '';
  int transactionId = -1;
  var d = NumberFormat('##0.0##');
  bool _isVisible = false;

  Future<bool> internet() async {
    IApiRepository _apiRepository = ApiRepository();
    bool internet = await _apiRepository.check();
    return internet;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).primaryColor));
    scaffoldKey = new GlobalKey<ScaffoldState>();
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileTransactionBloc>(
          create: (context) => ProfileTransactionBloc(
              DatabaseProvider(),
              ApiRepository(),
              walletCoin,
              walletAda,
              transactionList,
              id,
              transactionId),
        ),
      ],
      child: BlocBuilder<ProfileTransactionBloc, ProfileTransactionState>(
        builder: (context, state) {
          if (state.state == ProfileTransactionStatus.start) {
            context.read<ProfileTransactionBloc>().add(CreateProfileTransaction(
                walletCoin: [], walletAda: [], listTransaction: [], id: id));
            return SplashPage();
          } else if (state.state == ProfileTransactionStatus.get) {
            transactionList = state.transactionList!;
            sortTransactionList = state.transactionList!;
            if (sortTransactionList.isNotEmpty) {
              sortTransactionList.sort((a, b) => DateTime.parse(b.timestamp)
                  .microsecondsSinceEpoch
                  .compareTo(
                      DateTime.parse(a.timestamp).microsecondsSinceEpoch));
            }
            walletCoin = state.walletCoin!;
            walletAda = state.walletAda!;
            print('walletCoin!!!!!::: $walletCoin');
            print('walletAda!!!!!::: $walletAda');
          }
          return WillPopScope(
            onWillPop: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  transactionList.length > 1
                      ? LocaleKeys.transactions.tr() + " $name"
                      : LocaleKeys.transaction.tr() + " $name",
                  overflow: TextOverflow.fade,
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
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage())),
                ),
              ),
              floatingActionButton: state.transactionList!.isEmpty
                  ? Visibility(
                      visible: _isVisible, child: getFloatingActionButton())
                  : Visibility(
                      visible: !_isVisible, child: getFloatingActionButton()),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getCost(),
                    Divider(
                      height: 0.4,
                      color: Theme.of(context)
                          .cardTheme
                          .copyWith(color: Theme.of(context).hintColor)
                          .color,
                    ),
                    FutureBuilder(
                      future: internet(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.hasData)
                          return (isRelevant == 0 && snapshot.data! == true)
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/image/warning.png',
                                        // color: arrowColor,
                                        height: 45,
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    30) /
                                                16.5,
                                      ),
                                      Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                top: 16.0,
                                                left: 16.0,
                                                right: 16.0,
                                                bottom: 8),
                                            child: Center(
                                              child: Text(
                                                LocaleKeys.coin_is_relevant
                                                    .tr(),
                                                style: TextStyle(
                                                  fontSize: textSize14,
                                                  color: lErrorColorLight,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              : (isRelevant == 0 && snapshot.data! == false)
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/image/warning.png',
                                            // color: arrowColor,
                                            height: 45,
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    30) /
                                                16.5,
                                          ),
                                          Expanded(
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 16.0,
                                                    left: 16.0,
                                                    right: 16.0,
                                                    bottom: 8),
                                                child: Center(
                                                  child: Text(
                                                    LocaleKeys
                                                        .coin_is_relevant_internet
                                                        .tr(),
                                                    style: TextStyle(
                                                      fontSize: textSize14,
                                                      color: lErrorColorLight,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink();
                        else
                          return SizedBox.shrink();
                      },
                    ),
                    state.transactionList!.isEmpty
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
                                              builder: (context) =>
                                                  TransactionsPage(
                                                      symbol: symbol,
                                                      name: name,
                                                      image: image,
                                                      id: id,
                                                      transactionId: -1,
                                                      isRelevant: isRelevant,
                                                      cost: 0.0)));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(46.0)),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 23, horizontal: 23)),
                                    child: new Icon(Icons.add,
                                        size: 45.0,
                                        color: Theme.of(context).shadowColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    LocaleKeys.press_add_transaction.tr(),
                                    style: TextStyle(
                                            fontSize: textSize18,
                                            color: Theme.of(context).hintColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: ListView.builder(
                                  itemCount: sortTransactionList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Dismissible(
                                      key: UniqueKey(),
                                      confirmDismiss:
                                          (DismissDirection direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          return await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0))),
                                                content: Container(
                                                    padding: EdgeInsets.only(
                                                        top: 10.0,
                                                        right: 10.0,
                                                        left: 10.0,
                                                        bottom: 5.0),
                                                    child: Text(
                                                      LocaleKeys.confirm_delete
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hoverColor,
                                                              fontFamily:
                                                                  'MyriadPro',
                                                              fontSize:
                                                                  textSize14),
                                                    )),
                                                actions: <Widget>[
                                                  Center(
                                                      child: Column(
                                                    children: [
                                                      Divider(
                                                          height: 1.0,
                                                          color:
                                                              Theme.of(context)
                                                                  .hoverColor),
                                                      SizedBox(height: 10.0),
                                                      Container(
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                              child: Container(
                                                                  width: 100.0,
                                                                  height: 25.0,
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .yes
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color:
                                                                            kInIconColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'MyriadPro',
                                                                        fontSize:
                                                                            textSize18),
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 50.0,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                              child: Container(
                                                                  width: 100.0,
                                                                  height: 25.0,
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .no
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color:
                                                                            kErrorColorLight,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'MyriadPro',
                                                                        fontSize:
                                                                            textSize18),
                                                                  )),
                                                            ),
                                                          ])),
                                                    ],
                                                  ))
                                                ],
                                              );
                                            },
                                          );
                                        } else if (direction ==
                                            DismissDirection.endToStart) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionsPage(
                                                          symbol: symbol,
                                                          name: name,
                                                          image: image,
                                                          id: id,
                                                          transactionId: state
                                                              .transactionList![
                                                                  index]
                                                              .transactionId!,
                                                          isRelevant:
                                                              isRelevant,
                                                          cost: state
                                                              .transactionList![
                                                                  index]
                                                              .qty)));
                                        }
                                        return null;
                                      },
                                      onDismissed: (direction) {
                                        BlocProvider.of<ProfileTransactionBloc>(
                                                context)
                                            .add(DeleteTransaction(
                                                transactionId: state
                                                    .transactionList![index]
                                                    .transactionId!));
                                        setState(() {});
                                      },
                                      background: Container(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: Theme.of(context)
                                                        .iconTheme
                                                        .copyWith(
                                                            size: MediumIcon)
                                                        .size,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  )),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: Theme.of(context)
                                                        .iconTheme
                                                        .copyWith(
                                                            size: MediumIcon)
                                                        .size,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  )),
                                            ],
                                          )),
                                      child: getListTransaction(
                                          index, state, context),
                                    );
                                  }),
                            ),
                          ),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget getCost() {
    walletCoin =
        (walletCoin.isEmpty) ? walletCoin = [0.0, 0.0, 0.0] : walletCoin;
    walletAda = (walletAda.isEmpty) ? walletAda = [0.0, 0.0, 0.0] : walletAda;
    String date = ' ';
    String time = ' ';
    List<String> dateTime = [];
    String wallet = '';
    String walletAdaStr = '';
    String lastActiveStr = '';
    String lastActive = '';

    double qty = Decimal.convertPriceRoundToDouble(walletCoin.first);
    String qtyStr =
        Decimal.convertPriceRoundToDouble(walletCoin.first).toString();
    if (qty < 0.0) {
      qtyStr =
          '-${walletCoin.first * -1 > 1.0 ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(walletCoin.first * -1).toString()) : Decimal.convertPriceRoundToDouble(walletCoin.first * -1).toString()}';
    } else {
      qtyStr =
          '${walletCoin.first > 1.0 ? Decimal.dividePrice(qtyStr) : qtyStr}';
    }

    if (transactionList.isNotEmpty) {
      dateTime = transactionList.last.timestamp.split(', ');
      date = dateTime.first;
      time = dateTime.last;
      lastActiveStr = transactionList.last.lastActiveTime.split(', ').last;
      DateTime dt = DateTime.parse('$lastActiveStr');
      Locale myLocale = Localizations.localeOf(context);
      lastActive = DateFormat('dd MMMM yyyy', myLocale.languageCode).format(dt);
    }
    print("date= $date, time= $time, dateTime= $dateTime");
    walletCoin =
        (walletCoin.isEmpty) ? walletCoin = [0.0, 0.0, 0.0] : walletCoin;
    walletAda = (walletAda.isEmpty) ? walletAda = [0.0, 0.0, 0.0] : walletAda;

    wallet = Decimal.convertPriceRoundToDouble(walletCoin.last).toString();
    walletAdaStr = Decimal.convertPriceRoundToDouble(walletAda.last).toString();
    if (walletCoin.last < 0.0) {
      wallet =
          '-${(walletCoin.last * -1 > 1.0) ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(walletCoin.last * -1).toString()) : Decimal.convertPriceRoundToDouble(walletCoin.last * -1).toString()}';
    } else {
      wallet =
          '${(walletCoin.last > 1.0) ? Decimal.dividePrice(wallet.toString()) : wallet.toString()}';
    }
    if (walletAda.last < 0.0) {
      walletAdaStr =
          '-${(walletAda.last * -1 > 1.0) ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(walletAda.last * -1).toString()) : Decimal.convertPriceRoundToDouble(walletAda.last * -1).toString()}';
    } else {
      walletAdaStr =
          '${(walletAda.last > 1.0) ? Decimal.dividePrice(walletAdaStr.toString()) : walletAdaStr.toString()}';
    }
    print('walletAdaStr: ${walletAdaStr.length}');
    print(
        "walletCoin PTPage = $walletCoin, !!! ${Decimal.convertPriceRoundToDouble(walletCoin.first).toString()}");
    print(
        "walletAda PTPage = $walletAda, !!! ${Decimal.convertPriceRoundToDouble(walletAda.first).toString()}");

    bool twoLines = false;
    Widget sumWallet = SizedBox.shrink();
    if (walletAdaStr.length < 17 && wallet.length < 17) {
      twoLines = false;
      sumWallet = Container(
          width: MediaQuery.of(context).size.width - 45.0,
          height: 65.0,
          child: Column(children: [
            SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10.0),
                    width: (MediaQuery.of(context).size.width - 45.0) * 0.5,
                    height: 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.balancedUsd.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: isRelevant == 1
                                ? transactionHeaderTextColor
                                : lErrorColorLight,
                            fontSize: textSize17,
                          ),
                        ),
                        Text(
                          wallet + ' \$',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).shadowColor,
                            fontSize: textSize17,
                          ),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10.0),
                    width: (MediaQuery.of(context).size.width - 45.0) * 0.5,
                    height: 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.balancedAda.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: isRelevant == 1
                                ? transactionHeaderTextColor
                                : lErrorColorLight,
                            fontSize: textSize17,
                          ),
                        ),
                        Text(
                          walletAdaStr + ' ₳',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).shadowColor,
                            fontSize: textSize17,
                          ),
                        )
                      ],
                    ))
              ],
            )
          ]));
    } else {
      twoLines = true;
      sumWallet = Container(
          width: MediaQuery.of(context).size.width - 45.0,
          height: 95.0,
          child: Column(
            children: [
              SizedBox(
                height: 5.0,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width - 45.0,
                  height: 44.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.balancedUsd.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          color: isRelevant == 1
                              ? transactionHeaderTextColor
                              : lErrorColorLight,
                          fontSize: textSize17,
                        ),
                      ),
                      Text(
                        wallet + ' \$',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).shadowColor,
                          fontSize: textSize17,
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 2.0,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width - 45.0,
                  height: 44.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.balancedAda.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          color: isRelevant == 1
                              ? transactionHeaderTextColor
                              : lErrorColorLight,
                          fontSize: textSize17,
                        ),
                      ),
                      Text(
                        walletAdaStr + ' ₳',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).shadowColor,
                          fontSize: textSize17,
                        ),
                      )
                    ],
                  ))
            ],
          ));
    }
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
            width: MediaQuery.of(context).size.width - 20.0,
            height: !twoLines ? 150.0 : 175.0,
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).secondaryHeaderColor,
                  transactionHeaderColor,
                ],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 45.0,
                  height: 60.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child: Container(
                          child: CircleAvatar(
                            radius: 19.0,
                            backgroundColor: Colors.transparent,
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              imageUrl: '$image',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  FutureBuilder(
                                future: checkContainImage(
                                    'assets/image/${symbol.toLowerCase()}.png'),
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
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width - 115.0,
                        height: 60.0,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30.0,
                              width: MediaQuery.of(context).size.width - 115.0,
                              child: Text(
                                qtyStr + ' $name',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                        fontSize: textSize22,
                                        color: Theme.of(context).shadowColor),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            if (lastActive.isNotEmpty || lastActive != '')
                              Container(
                                margin: EdgeInsets.only(left: 10.0),
                                width:
                                    MediaQuery.of(context).size.width - 105.0,
                                height: 25.0,
                                child: Text(
                                  lastActive,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                          fontSize: textSize16,
                                          color: isRelevant == 1
                                              ? transactionHeaderTextColor
                                              : lErrorColorLight),
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                sumWallet
              ],
            )
            //        Row(
            //    children: [
            //    Expanded(
            //    child: Column(
            //        crossAxisAlignment: CrossAxisAlignment.start,
            //        children: <Widget>[
            //          Padding(
            //            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            //            child: Text(
            //              qtyStr + ' $name',
            //              maxLines: 1,
            //              overflow: TextOverflow.fade,
            //              softWrap: false,
            //              style: Theme
            //                  .of(context)
            //                  .textTheme
            //                  .headline6!
            //                  .copyWith(
            //                  fontSize: textSize24,
            //                  color: Theme
            //                      .of(context)
            //                      .shadowColor),
            //            ),
            //          ),
            //          Padding(
            //            padding: const EdgeInsets.only(
            //                left: 16.0, top: 4.0, bottom: 4.0),
            //            child: Text(
            //              //'${f.format(walletCoin.last)} '
            //              wallet + ' \$',
            //              maxLines: 1,
            //              overflow: TextOverflow.fade,
            //              softWrap: false,
            //              style: GoogleFonts.inter(
            //                color: Theme
            //                    .of(context)
            //                    .shadowColor,
            //                fontSize: textSize17,
            //              ),
            //            ),
            //          ),
            //          Padding(
            //            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            //            child: Text(
            //              //'${f.format(walletCoin.last)} '
            //              walletAdaStr + ' ₳',
            //              maxLines: 1,
            //              overflow: TextOverflow.fade,
            //              softWrap: false,
            //              style: GoogleFonts.inter(
            //                color: Theme
            //                    .of(context)
            //                    .shadowColor,
            //                fontSize: textSize17,
            //              ),
            //            ),
            //          ),
            //          if (lastActive.isNotEmpty || lastActive != '')
            //            Padding(
            //              padding: const EdgeInsets.only(
            //                  left: 16.0, top: 4.0, bottom: 4.0),
            //              child: Text(
            //                lastActive,
            //                style: Theme
            //                    .of(context)
            //                    .textTheme
            //                    .headline6!
            //                    .copyWith(
            //                    fontSize: textSize18,
            //                    color: isRelevant == 1
            //                        ? Color(0x93282B30)
            //                        : lErrorColorLight),
            //              ),
            //            ),
            //        ]),
            //  ),
            //  ],
            //),
            ),
      ),
    );
  }

  Widget getListTransaction(
      int index, ProfileTransactionState state, BuildContext context) {
    Widget iconTr = Icon(Icons.height);

    ///String usdPrice = '';
    ///String adaPrice = '';
    double currentPrice = 0.0;
    double currentPriceAda = 0.0;

    ///double customCurrentPrice = 0.0;
    ///double customCurrentPriceAda = 0.0;
    double realPrice = 0.0;
    double realPriceAda = 0.0;
    bool visible = false;
    String gotUsd = '';
    String gotAda = '';
    String plus = '';
    Color priceColor = Theme.of(context).focusColor;
    print('USD:::${state.transactionList![index].usdPrice!}');
    print('ADA:::${state.transactionList![index].adaPrice!}');
    String qty =
        Decimal.convertPriceRoundToDouble(state.transactionList![index].qty)
            .toString();

    ///if (state.transactionList![index].usdPrice! < 1.0) {
    ///  usdPrice = Decimal.convertPriceRoundToDouble(
    ///          state.transactionList![index].usdPrice!)
    ///      .toString();
    ///} else {
    ///  usdPrice = Decimal.dividePrice(Decimal.convertPriceRoundToDouble(
    ///          state.transactionList![index].usdPrice!)
    ///      .toString());
    ///}
    ///if (state.transactionList![index].adaPrice! < 1.0) {
    ///  adaPrice = Decimal.convertPriceRoundToDouble(
    ///          state.transactionList![index].adaPrice!)
    ///      .toString();
    ///} else {
    ///  adaPrice = Decimal.dividePrice(Decimal.convertPriceRoundToDouble(
    ///          state.transactionList![index].adaPrice!)
    ///      .toString());
    ///}
    currentPrice = Decimal.convertPriceRoundToDouble(
        walletCoin[1] * state.transactionList![index].qty);
    currentPriceAda = Decimal.convertPriceRoundToDouble(
        walletAda[1] * state.transactionList![index].qty);
    realPrice = Decimal.convertPriceRoundToDouble(walletCoin[1]);
    realPriceAda = Decimal.convertPriceRoundToDouble(walletAda[1]);

    ///customCurrentPrice = Decimal.convertPriceRoundToDouble(
    ///    state.transactionList![index].usdPrice! *
    ///        state.transactionList![index].qty);
    ///customCurrentPriceAda = Decimal.convertPriceRoundToDouble(
    ///    state.transactionList![index].adaPrice! *
    ///        state.transactionList![index].qty);
    print(
        " currentPrice = $currentPrice, state.transactionList![index].walletAddress = ${state.transactionList![index].walletAddress}");
    print(
        " currentPrice = $currentPriceAda, state.transactionList![index].walletAddress = ${state.transactionList![index].walletAddress}");
    visible = (state.transactionList![index].walletAddress!.isEmpty ||
            state.transactionList![index].walletAddress == ' ')
        ? false
        : true;
    if (state.transactionList![index].type == 'In') {
      minus = '';
      iconTr = Image.asset(
        'assets/icons/in.png',
      );
      gotUsd = LocaleKeys.gotInUsd.tr();
      gotAda = LocaleKeys.gotInAda.tr();
      plus = '+';
      priceColor = transactionInColor;
      if (state.transactionList![index].qty == 0) {
        plus = '';
        priceColor = Theme.of(context).focusColor;
        iconTr = Icon(Icons.height);
      }
    } else if (state.transactionList![index].type == 'Out') {
      gotUsd = LocaleKeys.sentInUsd.tr();
      gotAda = LocaleKeys.sentInAda.tr();
      plus = '';
      priceColor = transactionOutColor;
      iconTr = Image.asset(
        'assets/icons/out.png',
      );
      if (state.transactionList![index].qty == 0) {
        minus = '';
        priceColor = Theme.of(context).focusColor;
        iconTr = Icon(Icons.height);
      }
      if (currentPrice == 0.0) {
        minus = '';
      } else {
        minus = '-';
      }
    } else if (state.transactionList![index].type == 'Wallet') {
      gotUsd = LocaleKeys.gotInUsd.tr();
      gotAda = LocaleKeys.gotInAda.tr();
      plus = '';
      priceColor = transactionHeaderTextColor;
      iconTr = Icon(Icons.height);
    }
    String sumUsd = '';
    String sumAda = '';
    String usd = '';
    String ada = '';

    usd = '$realPrice \$';
    ada = '$realPriceAda ₳';
    if (realPrice !=
        Decimal.convertPriceRoundToDouble(
            state.transactionList![index].usdPrice!)) {
      ///usd = '$realPrice ($usdPrice) \$';
      sumUsd =
          '$minus${(walletCoin[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPrice.toString()) : currentPrice.toString()}';

      ///        '(${customCurrentPrice > 1.0 ? Decimal.dividePrice(customCurrentPrice.toString()) : customCurrentPrice}) \$';
    } else {
      ///usd = '$usdPrice \$';
      sumUsd =
          '$minus${(walletCoin[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPrice.toString()) : currentPrice.toString()} \$';
    }
    if (realPriceAda !=
        Decimal.convertPriceRoundToDouble(
            state.transactionList![index].adaPrice!)) {
      ///ada = '$realPriceAda ($adaPrice) ₳';
      sumAda =
          '$minus${(walletAda[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPriceAda.toString()) : currentPriceAda.toString()}';

      ///        '(${customCurrentPriceAda > 1.0 ? Decimal.dividePrice(customCurrentPriceAda.toString()) : customCurrentPriceAda}) ₳';
    } else {
      ///ada = '$adaPrice ₳';
      sumAda =
          '$minus${(walletAda[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPriceAda.toString()) : currentPriceAda.toString()} ₳';
    }

    String lastActive = '';
    String lastActiveStr = '';
    lastActiveStr = state.transactionList![index].timestamp;
    DateTime dt = DateTime.parse('$lastActiveStr');
    Locale myLocale = Localizations.localeOf(context);
    lastActive = DateFormat('dd MMMM yyyy', myLocale.languageCode).format(dt);

    return Card(
      margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      child: Container(
        width: MediaQuery.of(context).size.width - 30.0,
        height: 140.0,
        padding: EdgeInsets.only(top: 10, bottom: 5),
        child: InkWell(
            onTap: () => {
                  print(
                      "state.transactionList![index].transactionId! = ${state.transactionList![index].transactionId!}"),
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransactionsDetailsPage(
                                id: id,
                                name: name,
                                symbol: symbol,
                                image: image,
                                isRelevant: isRelevant,
                                transactionId: state
                                    .transactionList![index].transactionId!,
                                cost: state.transactionList![index].qty
                                    .toString(),
                                type: state.transactionList![index].type,
                                details: state.transactionList![index].details,
                                timestamp:
                                    state.transactionList![index].timestamp,
                                price: state.transactionList![index].usdPrice!,
                                priceAda:
                                    state.transactionList![index].adaPrice!,
                                realPrice: Decimal.convertPriceRoundToDouble(
                                    walletCoin[1]),
                                trastWallet: state
                                    .transactionList![index].walletAddress!,
                                // commonPrice: currentPrice,
                                // commonPrice: walletCoin[1],
                                amountOfCoins: walletCoin.first,
                                commonPrice: walletCoin.last,
                              ))),
                },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  height: 40.0,
                  width: 40.0,
                  child: iconTr,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80.0,
                  height: 125.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 30.0,
                          child: Text(
                            '$minus${state.transactionList![index].qty > 1.0 ? Decimal.dividePrice(qty) : qty} $name',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: textSize22),
                          )),
                      SizedBox(height: 5.0),
                      SizedBox(
                          height: 20.0,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: (MediaQuery.of(context).size.width -
                                          90.0) *
                                      0.5,
                                  child: Text(
                                    lastActive,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                            fontSize: ProfileCoinSmallText,
                                            color: isRelevant == 1
                                                ? transactionHeaderTextColor
                                                : lErrorColorLight),
                                  )),
                              SizedBox(
                                width: 10.0,
                              ),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 90.0) *
                                        0.5,
                                child: Visibility(
                                  visible: visible,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Wallet: ",
                                        style: TextStyle(
                                                fontSize: ProfileCoinSmallText,
                                                color:
                                                    transactionHeaderTextColor),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${state.transactionList![index].walletAddress}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          //state.coinsList![index].name,
                                          style: TextStyle(
                                                  fontSize:
                                                      ProfileCoinSmallText,
                                                  color:
                                                      transactionHeaderTextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                      SizedBox(height: 10.0),
                      SizedBox(
                        height: 60.0,
                        width: MediaQuery.of(context).size.width - 80.0,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 60.0,
                              width:
                                  (MediaQuery.of(context).size.width - 90.0) *
                                      0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        gotUsd,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: transactionHeaderTextColor,
                                          fontSize: textSize14,
                                        ),
                                      )),
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        "$plus$sumUsd",
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: priceColor,
                                          fontSize: textSize16,
                                        ),
                                      )),
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        "$usd",
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: Theme.of(context).focusColor,
                                          fontSize: textSize16,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            SizedBox(
                              height: 60.0,
                              width:
                                  (MediaQuery.of(context).size.width - 90.0) *
                                      0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        gotAda,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: transactionHeaderTextColor,
                                          fontSize: textSize14,
                                        ),
                                      )),
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        "$plus$sumAda",
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: priceColor,
                                          fontSize: textSize16,
                                        ),
                                      )),
                                  SizedBox(
                                      height: 20.0,
                                      child: Text(
                                        "$ada",
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: GoogleFonts.inter(
                                          color: Theme.of(context).focusColor,
                                          fontSize: textSize16,
                                        ),
                                      )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget getFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
          child: FloatingActionButton(
            elevation: SettingsCardRadius,
            hoverElevation: textSize45,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: new Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionsPage(
                          symbol: symbol,
                          name: name,
                          image: image,
                          id: id,
                          transactionId: -1,
                          isRelevant: isRelevant,
                          cost: 0.0)));
            },
          ),
        ),
      ],
    );
  }
}
