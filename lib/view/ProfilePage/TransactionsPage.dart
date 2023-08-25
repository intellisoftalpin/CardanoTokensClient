import 'dart:developer';

import 'package:crypto_offline/bloc/TransactionBloc/TransactionBloc.dart';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionEvent.dart';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/data/dbhive/WalletModel.dart';
import 'package:crypto_offline/data/model/CurrentPrice.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import 'ProfileTransactionsPage.dart';

class TransactionsPage extends StatefulWidget {
  final String symbol;
  final String name;
  final String image;
  final String id;
  final int transactionId;
  final int isRelevant;
  final double cost;

  TransactionsPage(
      {required this.symbol,
      required this.name,
      required this.image,
      required this.id,
      required this.transactionId,
      required this.isRelevant,
      required this.cost});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => TransactionsPage(
            symbol: '',
            name: '',
            image: '',
            id: '',
            transactionId: -1,
            isRelevant: 1,
            cost: 0.0));
  }

  @override
  _TransactionsPageState createState() => _TransactionsPageState(
      symbol, name, image, id, transactionId, isRelevant);
}

class _TransactionsPageState extends State<TransactionsPage> {
  _TransactionsPageState(this.symbol, this.name, this.image, this.id,
      this.transactionId, this.isRelevant);

  String symbol;
  String name;
  String image;
  String id;
  int transactionId;
  int isRelevant;

  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  bool menuTypeOpened = false;
  bool menuAdvancedOpened = false;

  DateTime selectedDate = DateTime.now();
  final List<String> _txDetailsIn = [
    LocaleKeys.buy_tr.tr(),
    LocaleKeys.transfer.tr(),
    LocaleKeys.exchange.tr(),
    LocaleKeys.mining.tr(),
    LocaleKeys.staking.tr()
  ];
  final List<String> _txDetailsOut = [
    LocaleKeys.sell.tr(),
    LocaleKeys.transfer.tr(),
    LocaleKeys.exchange.tr()
  ];
  String trType = '';
  String trDetails = '';
  FocusNode costFocusNode = FocusNode();
  TextEditingController costController = TextEditingController();
  TextEditingController cTrastWallet = TextEditingController();
  TextEditingController cType = TextEditingController();
  TextEditingController cTimestamp = TextEditingController();
  String trastWallet = '';
  String txTrastWallet = '';
  String txType = '';
  String txDetails = '';
  String hitDetails = '';
  TextEditingController cDetails = TextEditingController();
  String timestamp = '';
  String details = 'Buy';
  String type = LocaleKeys.in_.tr();
  String _timestamp = '';
  double? cost = 0;
  String txCost = '';
  double _price = 0;
  double price = 0;
  String txPrice = '';
  double _priceAda = 0;
  double priceAda = 0;
  String txPriceAda = '';
  String? wallet;

  List<TransactionEntity> transactionEntity = [];
  List<TransactionEntity> transactionById = [];
  List<CurrentPrice> coinPrice = [];
  List<double> walletCoin = [];
  List<double> walletAda = [];
  List<WalletModel> listTrastWallet = [];
  var f = NumberFormat('##0.0##');

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    costFocusNode.requestFocus();
    costController.text = widget.cost == 0.0 ? '' : widget.cost.toString();
    super.initState();
  }

  @override
  void dispose() {
    cTrastWallet.dispose();
    cType.dispose();
    cDetails.dispose();
    cTimestamp.dispose();
    costFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print(" ::::::::: screenHeight :::: = $screenHeight");
    return WillPopScope(
        onWillPop: () async {
          saveOrEdit = SaveOrEdit.save;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileTransactionsPage(
                        id: widget.id,
                        name: widget.name,
                        symbol: widget.symbol,
                        image: widget.image,
                        isRelevant: widget.isRelevant,
                      )));
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => TransactionsDetailsPage(
          //           id: id,
          //           symbol: symbol,
          //           isRelevant: isRelevant,
          //           transactionId: transactionId,
          //           cost: cost,
          //           type: type,
          //           details: details,
          //           timestamp: timestamp,
          //           price: price,
          //           trastWallet: trastWallet,
          //         )));
          return true;
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TransactionBloc>(
              create: (context) => TransactionBloc(
                  DatabaseProvider(),
                  ApiRepository(),
                  HivePrefProfileRepositoryImpl(),
                  transactionById,
                  transactionEntity,
                  id,
                  walletCoin,
                  walletAda,
                  listTrastWallet,
                  transactionId),
            ),
            BlocProvider<ProfileTransactionBloc>(
              create: (context) => ProfileTransactionBloc(
                  DatabaseProvider(),
                  ApiRepository(),
                  walletCoin,
                  walletAda,
                  [],
                  id,
                  transactionId),
            ),
          ],
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.state == TransactionStatus.start) {
                context.read<TransactionBloc>().add(CoinTransaction(
                    id: id,
                    transactionId: transactionId,
                    transactionById: [],
                    walletCoin: [],
                    listTrastWallet: []));
                return SplashPage();
              } else if (state.state == TransactionStatus.get) {
                coinPrice = state.coinId!;
                price = coinPrice.first.usd!.toDouble();
                priceAda = coinPrice.first.ada!.toDouble();
                walletCoin = state.walletCoin!;
                walletAda = state.walletAda!;
                listTrastWallet = state.listTrastWallet!;
                listTrastWallet[0] = WalletModel(
                    id: "clear",
                    name: LocaleKeys.wallet_clear_field.tr(),
                    walletType: "clear",
                    blockchains: "*",
                    link: "",
                    droid: "",
                    ios: "",
                    sort: "");
                log("listTrastWallet = $listTrastWallet");
                transactionById = state.transactionById!;
                print("transactionById1 = $transactionById");
                if (transactionById.isNotEmpty) {
                  type = transactionById.first.type;
                  details = transactionById.first.details;
                  cost = transactionById.first.qty;
                  trastWallet = transactionById.first.walletAddress!;
                }
                (transactionById.isNotEmpty)
                    ? price = transactionById.first.usdPrice!
                    : price = coinPrice.first.usd!.toDouble();
                (transactionById.isNotEmpty)
                    ? priceAda = transactionById.first.adaPrice!
                    : priceAda = coinPrice.first.ada!.toDouble();
                (transactionById.isNotEmpty)
                    ? timestamp = transactionById.first.timestamp
                    : timestamp = "${selectedDate.toLocal()}".split(' ')[0];
              }
              return Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    centerTitle: true,
                    title: Text(
                      (transactionById.isNotEmpty)
                          ? LocaleKeys.edit_transaction.tr()
                          : LocaleKeys.add_transaction.tr(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize23,
                        color: Theme.of(context).focusColor,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Myriad Pro',
                      ),
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
                        onPressed: () {
                          saveOrEdit = SaveOrEdit.save;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileTransactionsPage(
                                        id: widget.id,
                                        name: widget.name,
                                        symbol: widget.symbol,
                                        image: widget.image,
                                        isRelevant: widget.isRelevant,
                                      )));
                        }),
                    actions: [
                      SizedBox(
                        height: 35.0,
                        width: 35.0,
                      )
                    ],
                  ),
                  body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Form(
                              key: _formKey,
                              child: ListView(children: <Widget>[
                                getCost(context),
                                Divider(
                                  height: 0.4,
                                  color: Theme.of(context)
                                      .cardTheme
                                      .copyWith(
                                          color: Theme.of(context).hintColor)
                                      .color,
                                ),
                                getTxcost(),
                                transactionTypeWidgets(context),
                                advancedWidgets(context),
                                getButton(context),
                              ])),
                        ),
                        //getButton(context, cost.replaceAll(",", ".")),
                      ]));
            },
          ),
        ));
  }

  Widget getCost(BuildContext context) {
    walletCoin = (walletCoin.isEmpty) ? walletCoin = [0.0, 0.0] : walletCoin;
    String walletUsd = '';
    if (walletCoin.last > 1.0) {
      walletUsd = Decimal.convertPriceRoundToDouble(walletCoin.last).toString();
      walletUsd = Decimal.dividePrice(walletUsd);
    } else {
      walletUsd = Decimal.convertPriceRoundToDouble(walletCoin.last).toString();
    }
    walletAda = (walletAda.isEmpty) ? walletAda = [0.0, 0.0] : walletAda;
    String walletAdaStr = '';
    if (walletAda.last > 1.0) {
      walletAdaStr =
          Decimal.convertPriceRoundToDouble(walletAda.last).toString();
      walletAdaStr = Decimal.dividePrice(walletAdaStr);
    } else {
      walletAdaStr =
          Decimal.convertPriceRoundToDouble(walletAda.last).toString();
    }

    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context)
              .cardTheme
              .copyWith(color: Theme.of(context).secondaryHeaderColor)
              .color,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                  child: Text(
                    '${walletCoin.first > 1.0 ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(walletCoin.first).toString()) : Decimal.convertPriceRoundToDouble(walletCoin.first).toString()} $symbol',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).shadowColor,
                      fontSize: textSize24,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 6.0),
                  child: Text(
                    '$walletUsd' + ' \$',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).shadowColor,
                      fontSize: textSize24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                  child: Text(
                    '$walletAdaStr' + ' ₳',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).shadowColor,
                      fontSize: textSize24,
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget getTxcost() {
    if (cost != 0) {
      cost = Decimal.convertPriceRoundToDouble(cost!);
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6.0, 4.0, 6.0),
              child: TextFormField(
                focusNode: costFocusNode,
                controller: costController,
                textAlignVertical: TextAlignVertical.center,
                enableInteractiveSelection: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                obscureText: false,
                decoration: kFieldNameEditProfileDecoration(context).copyWith(
                    hintText: LocaleKeys.quantity.tr(),
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                    errorStyle:
                        TextStyle(fontSize: textSize14, color: kErrorColor)),
                style: TextStyle(
                    fontFamily: 'MyriadPro',
                    color: Theme.of(context).primaryColorLight,
                    fontSize: textSize24),
                validator: (value) {
                  value = value.toString().replaceAll(",", ".");
                  if (value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.tryParse(value)! < 0) {
                    return LocaleKeys.enter_quantity.tr();
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  if (double.tryParse(value) != null) {
                    cost = double.parse(value);
                  }
                }),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
              child: Text(
                '$symbol',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: textSize20,
                    color: Theme.of(context).indicatorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionTypeWidgets(BuildContext context) {
    txType = trType == '' ? type : trType;
    if (txType == 'In' || txType == 'Входящее') {
      trType = LocaleKeys.in_.tr();
      //_tDetails = _txDetailsIn;
    } else {
      trType = LocaleKeys.out_.tr();
      //_tDetails = _txDetailsOut;
    }

    if (details == '') {}
    txDetails = trDetails == '' ? details : trDetails;
    print('details: $details');
    print('txDetails: $txDetails');
    if (txDetails == 'Buy') {
      trDetails = LocaleKeys.buy_tr.tr();
    } else if (txDetails == 'Transfer') {
      trDetails = LocaleKeys.transfer.tr();
    } else if (txDetails == 'Exchange') {
      trDetails = LocaleKeys.exchange.tr();
    } else if (txDetails == 'Mining') {
      trDetails = LocaleKeys.mining.tr();
    } else if (txDetails == 'Staking') {
      trDetails = LocaleKeys.staking.tr();
    } else if (txDetails == 'Sell') {
      trDetails = LocaleKeys.sell.tr();
    }
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              height: 30.0,
              child: Text('${LocaleKeys.transactionType.tr()}:',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      fontSize: textSize20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor)),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width - 20.0,
                height: 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width - 60.0,
                        alignment: Alignment.centerLeft,
                        child: Text('$trType => $trDetails',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: textSize18,
                                color: Theme.of(context).indicatorColor))),
                    Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: 30.0,
                        height: 30.0,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              width: 1.0,
                              color: Theme.of(context).secondaryHeaderColor,
                            )),
                        child: Builder(
                          builder: (context) {
                            var controller = ExpandableController.of(context,
                                required: true)!;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (!menuTypeOpened) {
                                    menuTypeOpened = true;
                                  } else {
                                    menuTypeOpened = false;
                                  }
                                });
                                controller.toggle();
                              },
                              child: SizedBox(
                                  height: 30.0,
                                  child: Icon(
                                    menuTypeOpened ? Icons.check : Icons.edit,
                                    size: 30.0,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .copyWith(
                                            color:
                                                Theme.of(context).shadowColor)
                                        .color,
                                  )),
                            );
                          },
                        )),
                  ],
                )),
            Expandable(
              collapsed: const SizedBox.shrink(),
              expanded: typeDetailsWidget(context),
            ),
          ],
        ),
      ),
    ));
  }

  Widget typeDetailsWidget(BuildContext context) {
    int typeType = 0;
    List<String> list = _txDetailsOut;
    if (trType == 'In' || trType == 'Входящее') {
      typeType = 1;
      list = _txDetailsIn;
    }
    print("typeType: $typeType");
    print("trType: $trType");
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
        height: typeType == 1 ? 182.0 : 122.0,
        width: MediaQuery.of(context).size.width - 20.0,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).indicatorColor),
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 30.0,
              width: MediaQuery.of(context).size.width - 20.0,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        trType = LocaleKeys.in_.tr();
                        trDetails = LocaleKeys.buy_tr.tr();
                      });
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 30.0,
                        width: MediaQuery.of(context).size.width / 2 - 21.0,
                        decoration: BoxDecoration(
                          color: inTransactionColor,
                          border: Border(
                            right: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).indicatorColor),
                            bottom: BorderSide(
                                width: 1.0,
                                color: typeType == 1
                                    ? Colors.transparent
                                    : Theme.of(context).indicatorColor),
                          ),
                        ),
                        child: Text(LocaleKeys.in_.tr(),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: textSize18,
                                color: Theme.of(context).indicatorColor))),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        trType = LocaleKeys.out_.tr();
                        trDetails = LocaleKeys.sell.tr();
                      });
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 30.0,
                        width: MediaQuery.of(context).size.width / 2 - 21.0,
                        decoration: BoxDecoration(
                          color: outTransactionColor,
                          border: Border(
                            left: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).indicatorColor),
                            bottom: BorderSide(
                                width: 1.0,
                                color: typeType == 0
                                    ? Colors.transparent
                                    : Theme.of(context).indicatorColor),
                          ),
                        ),
                        child: Text(LocaleKeys.out_.tr(),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: textSize18,
                                color: Theme.of(context).indicatorColor))),
                  ),
                ],
              ),
            ),
            Container(
                height: typeType == 1 ? 150.0 : 90.0,
                color: typeType == 1 ? inTransactionColor : outTransactionColor,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Container(
                          alignment: Alignment.center,
                          height: 30.0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                trDetails = list[index];
                              });
                            },
                            child: Text(list[index],
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).indicatorColor)),
                          ));
                    }))
          ],
        ));
  }

  Widget advancedWidgets(BuildContext context) {
    return ExpandableNotifier(
        child: ScrollOnExpand(
            child: Container(
                margin: EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(child: Builder(builder: (context) {
                      var controller =
                          ExpandableController.of(context, required: true)!;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (!menuAdvancedOpened) {
                              menuAdvancedOpened = true;
                            } else {
                              menuAdvancedOpened = false;
                            }
                          });
                          controller.toggle();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              child: Icon(
                                !menuAdvancedOpened
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                                size: 30.0,
                                color: Theme.of(context)
                                    .iconTheme
                                    .copyWith(
                                        color: Theme.of(context).indicatorColor)
                                    .color,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                LocaleKeys.advanced.tr(),
                                style: TextStyle(
                                    fontSize: textSize18,
                                    color: Theme.of(context).indicatorColor),
                              ),
                            )
                          ],
                        ),
                      );
                    })),
                    Expandable(
                      collapsed: const SizedBox.shrink(),
                      expanded: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getTxtimestamp(),
                            getCurrentPrice(),
                            getCurrentPriceAda(),
                            getTrustWallet()
                          ]),
                    )
                  ],
                ))));
  }

  Widget getTxtimestamp() {
    (_timestamp.isEmpty)
        ? cTimestamp.text = timestamp
        : cTimestamp.text = _timestamp;
    cTimestamp.selection = TextSelection.fromPosition(
        TextPosition(offset: cTimestamp.text.length));
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 1.0, 8.0, 1.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                enableInteractiveSelection: true,
                controller: cTimestamp,
                decoration: kFieldNameEditProfileDecoration(context).copyWith(
                    fillColor: Theme.of(context).cardColor,
                    errorStyle:
                        TextStyle(fontSize: textSize14, color: kErrorColor)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                    fontFamily: 'MyriadPro',
                    color: Theme.of(context).primaryColorLight,
                    fontSize: textSize24),
                validator: (value) {
                  if (DateTime.parse(value!).isAfter(DateTime.now())) {
                    return LocaleKeys.enter_correct_date.tr();
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _timestamp = value;
                  print(_timestamp);
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: Theme.of(context)
                  .iconTheme
                  .copyWith(size: MediumIcon)
                  .size!
                  .toDouble(),
              color: Theme.of(context).iconTheme.color,
              onPressed: () => {
                _selectDate(context), // Refer step 3
              },
            ),
          ),
        ]),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // Refer step 1
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColorLight,
              onPrimary: Theme.of(context).splashColor,
              surface: Theme.of(context).primaryColorDark,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? kPlusIconColor
                  : lPlusIconColor,
            ),
            dialogBackgroundColor: Theme.of(context).cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        selectedDate = picked.toLocal();
        _timestamp = "${selectedDate.toLocal()}".split(' ')[0];
        timestamp = _timestamp;
      });
  }

  Widget getCurrentPrice() {
    _price == 0.0 ? price = price : price = _price;
    price = Decimal.convertPriceRoundToDouble(price);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 4.0, 6.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              enableInteractiveSelection: true,
              initialValue: price.toString(),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              obscureText: false,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.price.tr(),
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                  errorStyle:
                      TextStyle(fontSize: textSize14, color: kErrorColor)),
              style: TextStyle(
                  fontFamily: 'MyriadPro',
                  color: Theme.of(context).primaryColorLight,
                  fontSize: textSize24),
              validator: (value) {
                value = value.toString().replaceAll(",", ".");
                if (value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.tryParse(value)! < 0) {
                  return LocaleKeys.enter_price.tr();
                }
                return null;
              },
              onChanged: (value) => setState(() {
                if (value.isEmpty) {
                  _price = 0.0;
                  txPrice = '';
                } else {
                  value = value.toString().replaceAll(",", ".");
                  print("double.tryParse(value) = ${double.tryParse(value)}");
                  if (double.tryParse(value) != null) {
                    txPrice = value;
                    print(
                        "TP value price = $value, _price = $_price, double.tryParse(value) = ${double.tryParse(value)}");
                  }
                }
                print(_price);
              }),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
            child: Text(
              '\$',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).focusColor,
                fontSize: textSize20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getCurrentPriceAda() {
    _priceAda == 0.0 ? priceAda = priceAda : priceAda = _priceAda;
    priceAda = Decimal.convertPriceRoundToDouble(priceAda);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 4.0, 6.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              enableInteractiveSelection: true,
              initialValue: priceAda.toString(),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              obscureText: false,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.price_ada.tr(),
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                  errorStyle:
                      TextStyle(fontSize: textSize14, color: kErrorColor)),
              style: TextStyle(
                  fontFamily: 'MyriadPro',
                  color: Theme.of(context).primaryColorLight,
                  fontSize: textSize24),
              validator: (value) {
                value = value.toString().replaceAll(",", ".");
                if (value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.tryParse(value)! < 0) {
                  return LocaleKeys.enter_price.tr();
                }
                return null;
              },
              onChanged: (value) => setState(() {
                if (value.isEmpty) {
                  _priceAda = 0.0;
                  txPriceAda = '';
                } else {
                  value = value.toString().replaceAll(",", ".");
                  print("double.tryParse(value) = ${double.tryParse(value)}");
                  if (double.tryParse(value) != null) {
                    txPriceAda = value;
                    print(
                        "TP value priceAda = $value, _priceAda = $_priceAda, double.tryParse(value) = ${double.tryParse(value)}");
                  }
                }
                print(_priceAda);
              }),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
            child: Text(
              '₳',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).focusColor,
                fontSize: textSize20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getTrustWallet() {
    (wallet != null)
        ? cTrastWallet.text = wallet!
        : (txTrastWallet.isEmpty)
            ? cTrastWallet.text = trastWallet
            : cTrastWallet.text = txTrastWallet;
    cTrastWallet.selection = TextSelection.fromPosition(
        TextPosition(offset: cTrastWallet.text.length));
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 1.0, 8.0, 1.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: cTrastWallet,
                obscureText: false,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp("[0-9a-zA-Zа-яА-Я .-]")),
                ],
                decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  fillColor: Theme.of(context).cardColor,
                  hintText: LocaleKeys.wallet_exchange.tr(),
                ),
                style: TextStyle(
                    fontFamily: 'MyriadPro',
                    color: Theme.of(context).primaryColorLight,
                    fontSize: textSize24),
                onChanged: (value) => wallet = value,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(1.0),
              child: PopupMenuButton(
                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                iconSize: Theme.of(context)
                    .iconTheme
                    .copyWith(size: MediumIcon)
                    .size!
                    .toDouble(),
                color: Theme.of(context).iconTheme.color,
                itemBuilder: (BuildContext context) {
                  return listTrastWallet.map((item) {
                    return PopupMenuItem(
                      value: item.name,
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: TextStyle(
                              color: Theme.of(context).shadowColor,
                              fontFamily: 'MyriadPro',
                              fontSize: textSize24),
                        ),
                      ),
                    );
                  }).toList();
                },
                onSelected: (item) {
                  setState(() {
                    txTrastWallet = item.toString();
                    if (txTrastWallet == LocaleKeys.wallet_clear_field.tr()) {
                      cTrastWallet.clear();
                      wallet = '';
                      FocusManager.instance.primaryFocus?.unfocus();
                      print('TextField cleared');
                    } else {
                      print(
                          "1 cTrastWallet.text = ${cTrastWallet.text},txTrastWallet = $txTrastWallet");
                      cTrastWallet.text = txTrastWallet;
                      wallet = txTrastWallet;
                      print(
                          "2 cTrastWallet.text = ${cTrastWallet.text},txTrastWallet = $txTrastWallet");
                    }
                  });
                },
              )),
        ]),
      ),
    );
  }

  Widget getAdvanced() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_right_outlined),
              iconSize: Theme.of(context)
                  .iconTheme
                  .copyWith(size: MediumIcon)
                  .size!
                  .toDouble(),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {},
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
            child: Text(
              'Advanced',
              style: TextStyle(
                  fontSize: textSize20,
                  color: Theme.of(context).indicatorColor),
            ),
          ),
        ),
      ]),
    );
  }

  Widget getButton(BuildContext context) {
    String cost = costController.text.replaceAll(",", ".");
    print("cTrastWallet.text::: ${cTrastWallet.text}");
    print("cost = $cost, price = $price, txPrice = $txPrice");
    (txPrice.trim().isNotEmpty) ? price = double.parse(txPrice) : price = price;
    print("price = $price, txPrice = $txPrice");
    print("cost = $cost, priceAda = $priceAda, txPrice = $txPriceAda");
    (txPriceAda.trim().isNotEmpty)
        ? priceAda = double.parse(txPriceAda)
        : priceAda = priceAda;
    print("price = $priceAda, txPrice = $txPriceAda");
    double top = 0.0;
    screenHeight > 670.0 ? top = 32.0 : top = 12.0;
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10.0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, top, 8.0, 16.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 4.0, 8.0, 4.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    onPressed: () {
                      saveOrEdit = SaveOrEdit.save;
                      isLastTransaction = false;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTransactionsPage(
                                    id: widget.id,
                                    name: widget.name,
                                    symbol: widget.symbol,
                                    image: widget.image,
                                    isRelevant: widget.isRelevant,
                                  )));
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => TransactionsDetailsPage(
                      //           id: id,
                      //           symbol: symbol,
                      //           isRelevant: isRelevant,
                      //           transactionId: transactionId,
                      //           cost: cost,
                      //           type: type,
                      //           details: details,
                      //           timestamp: timestamp,
                      //           price: price,
                      //           trastWallet: trastWallet,
                      //         )),
                      //         (Route<dynamic> route) => false);
                    },
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: textSize18),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 32.0, 4.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    onPressed: () {
                      var now = new DateTime.now();
                      var formatter = new DateFormat('hh:mm');
                      String formattedDate = formatter.format(now);
                      print("formattedDate = $formattedDate");
                      if (_formKey.currentState!.validate()) {
                        if (transactionId != -1) {
                          transactionEntity = [
                            TransactionEntity(
                                transactionId: transactionId,
                                type: trType == LocaleKeys.in_.tr()
                                    ? 'In'
                                    : 'Out',
                                details: trDetails == LocaleKeys.buy_tr.tr()
                                    ? 'Buy'
                                    : trDetails == LocaleKeys.transfer.tr()
                                        ? 'Transfer'
                                        : trDetails == LocaleKeys.exchange.tr()
                                            ? 'Exchange'
                                            : trDetails ==
                                                    LocaleKeys.mining.tr()
                                                ? 'Mining'
                                                : trDetails ==
                                                        LocaleKeys.staking.tr()
                                                    ? 'Staking'
                                                    : trType ==
                                                            LocaleKeys.out_.tr()
                                                        ? 'Sell'
                                                        : 'Buy',
                                timestamp: cTimestamp.text,
                                lastActiveTime: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                qty: double.parse(cost),
                                usdPrice: price,
                                adaPrice: priceAda,
                                coinId: id,
                                walletAddress:
                                    (cTrastWallet.text.trim().isEmpty)
                                        ? ''
                                        : cTrastWallet.text.trim())
                          ];
                        } else {
                          isLastTransaction = false;
                          transactionEntity = [
                            TransactionEntity(
                                type: trType == LocaleKeys.in_.tr()
                                    ? 'In'
                                    : 'Out',
                                details: trDetails == LocaleKeys.buy_tr.tr()
                                    ? 'Buy'
                                    : trDetails == LocaleKeys.transfer.tr()
                                        ? 'Transfer'
                                        : trDetails == LocaleKeys.exchange.tr()
                                            ? 'Exchange'
                                            : trDetails ==
                                                    LocaleKeys.mining.tr()
                                                ? 'Mining'
                                                : trDetails ==
                                                        LocaleKeys.staking.tr()
                                                    ? 'Staking'
                                                    : trType ==
                                                            LocaleKeys.out_.tr()
                                                        ? 'Sell'
                                                        : 'Buy',
                                timestamp: cTimestamp.text,
                                lastActiveTime: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                qty: double.parse(cost),
                                usdPrice: price,
                                adaPrice: priceAda,
                                coinId: id,
                                walletAddress:
                                    (cTrastWallet.text.trim().isEmpty)
                                        ? ''
                                        : cTrastWallet.text.trim())
                          ];
                        }
                        print("transactionEntity = $transactionEntity");
                        context.read<TransactionBloc>().add(
                            SaveTransaction(transaction: transactionEntity));
                        Future.delayed(Duration(milliseconds: 400), () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileTransactionsPage(
                                        id: widget.id,
                                        name: widget.name,
                                        symbol: widget.symbol,
                                        image: widget.image,
                                        isRelevant: widget.isRelevant,
                                      )),
                              (Route<dynamic> route) => false);
                        });
                      }
                    },
                    child: Text(
                      LocaleKeys.save.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: textSize18),
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
