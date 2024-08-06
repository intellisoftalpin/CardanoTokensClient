import 'package:crypto_offline/bloc/TransactionDetailsBloc/TransactionDetailsState.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/ProfilePage/ProfileTransactionsPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionEvent.dart';
import '../../bloc/TransactionDetailsBloc/TransactionDetailsBloc.dart';
import '../../data/database/DbProvider.dart';
import '../../data/repository/ApiRepository/ApiRepository.dart';
import '../../generated/locale_keys.g.dart';
import '../../utils/decimal.dart';
import 'TransactionsPage.dart';

class TransactionsDetailsPage extends StatefulWidget {
  final String id;
  final int transactionId;
  final int isRelevant;
  final String name;
  final String symbol;
  final String image;
  final String? cost;
  final String? type;
  final String? details;
  final String? timestamp;
  final double? price;
  final double? priceAda;
  final double? realPrice;
  final String? trastWallet;
  final double amountOfCoins; // amount of coins from all transactions
  final double commonPrice; // sum price from all transactions

  TransactionsDetailsPage(
      {required this.id,
      required this.name,
      required this.symbol,
      required this.image,
      required this.isRelevant,
      required this.transactionId,
      required this.cost,
      required this.type,
      required this.details,
      required this.timestamp,
      required this.price,
      required this.priceAda,
      required this.realPrice,
      required this.trastWallet,
      required this.amountOfCoins,
      required this.commonPrice});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => TransactionsDetailsPage(
              id: '',
              symbol: '',
              image: '',
              name: '',
              isRelevant: 1,
              transactionId: 0,
              cost: '',
              type: '',
              details: '',
              timestamp: '',
              price: 0.0,
              priceAda: 0.0,
              realPrice: 0.0,
              trastWallet: '',
              amountOfCoins: 0.0,
              commonPrice: 0.0,
            ));
  }

  @override
  _TransactionsDetailsPageState createState() =>
      _TransactionsDetailsPageState();
}

class _TransactionsDetailsPageState extends State<TransactionsDetailsPage> {
  _TransactionsDetailsPageState();

  @override
  void initState() {
    saveOrEdit = SaveOrEdit.save;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'commonPrice: ${widget.commonPrice} amountOfCoins: ${widget.amountOfCoins}');
    double walletCoin = 0.0;
    double coinCost = 0.0;
    walletCoin = widget.commonPrice;
    coinCost = walletCoin / widget.amountOfCoins;
    String costUsd = '';
    costUsd = Decimal.convertPriceRoundToDouble(coinCost).toString();
    costUsd = Decimal.dividePrice(costUsd);
    Widget image = SizedBox.shrink();
    if (widget.type == 'In') {
      if (Theme.of(context).brightness == Brightness.dark) {
        image = Image.asset('assets/icons/inDark.png');
      } else {
        image = Image.asset('assets/icons/inLight.png');
      }
    } else {
      if (Theme.of(context).brightness == Brightness.dark) {
        image = Image.asset('assets/icons/outDark.png');
      } else {
        image = Image.asset('assets/icons/outLight.png');
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
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
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileTransactionBloc>(
            create: (context) => ProfileTransactionBloc(DatabaseProvider(),
                ApiRepository(), [], [], [], widget.id, widget.transactionId),
          ),
          BlocProvider<TransactionDetailsBloc>(
              create: (context) => TransactionDetailsBloc(
                  DatabaseProvider(), widget.id, widget.transactionId)),
        ],
        child: BlocBuilder<TransactionDetailsBloc, TransactionDetailsState>(
          builder: (BuildContext context, state) {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: BlocBuilder<TransactionDetailsBloc,
                    TransactionDetailsState>(
                  builder: (BuildContext context, state) {
                    return Text(
                      '${state.transactionDetails?.type == 'In' ? LocaleKeys.in_.tr() : LocaleKeys.out_.tr()}',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Myriad Pro',
                        color: Theme.of(context).focusColor,
                      ),
                    );
                  },
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
                    }),
                actions: [
                  SizedBox(
                    height: 35.0,
                    width: 35.0,
                  )
                ],
              ),
              body: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        image,
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              // BlocBuilder<ProfileTransactionBloc,
                              //     ProfileTransactionState>(
                              //   builder: (BuildContext context, state) {
                              //     return greyCard(state);
                              //   },
                              // ),
                              greyCard(state),
                              SizedBox(height: 10),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_1.svg',
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Theme.of(context)
                                                .secondaryHeaderColor, BlendMode.srcIn)),
                                title: Text(
                                    '${state.transactionDetails?.details == 'Buy' ? LocaleKeys.buy_tr.tr() : state.transactionDetails?.details == 'Transfer' ? LocaleKeys.transfer.tr() : state.transactionDetails?.details == 'Exchange' ? LocaleKeys.exchange.tr() : state.transactionDetails?.details == 'Mining' ? LocaleKeys.mining.tr() : state.transactionDetails?.details == 'Staking' ? LocaleKeys.staking.tr() : state.transactionDetails?.details == 'Sell' ? LocaleKeys.sell.tr() : LocaleKeys.buy_tr.tr()}',
                                    style: TextStyle(fontFamily: 'Myriad Pro')),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_2.svg',
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Theme.of(context)
                                            .secondaryHeaderColor, BlendMode.srcIn)),
                                title: state.transactionDetails != null
                                    ? Text(
                                        '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty > 0.0 ? '-' : ''}${state.transactionDetails!.qty > 1.0 ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty).toString()) : Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty).toString()}',
                                        style:
                                            TextStyle(fontFamily: 'Myriad Pro'),
                                      )
                                    : SizedBox.shrink(),
                                trailing: Text(
                                  '${widget.symbol}',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_3.svg',
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Theme.of(context)
                                            .secondaryHeaderColor, BlendMode.srcIn)),
                                title: state.transactionDetails != null
                                    ? Text(
                                        '${state.transactionDetails!.usdPrice! > 1.0 ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(state.transactionDetails!.usdPrice!).toString()) : Decimal.convertPriceRoundToDouble(state.transactionDetails!.usdPrice!).toString()}',
                                        style:
                                            TextStyle(fontFamily: 'Myriad Pro'))
                                    : SizedBox.shrink(),
                                trailing: Text(
                                  'USD',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: Container(
                                    padding: EdgeInsets.only(left: 1.0),
                                    child: SvgPicture.asset(
                                        'assets/icons/img_6.svg',
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                                ? Colors.black
                                                : Theme.of(context)
                                                .secondaryHeaderColor, BlendMode.srcIn))),
                                title: state.transactionDetails != null
                                    ? Text(
                                        '${state.transactionDetails!.adaPrice! > 1.0 ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(state.transactionDetails!.adaPrice!).toString()) : Decimal.convertPriceRoundToDouble(state.transactionDetails!.adaPrice!).toString()}',
                                        style:
                                            TextStyle(fontFamily: 'Myriad Pro'))
                                    : SizedBox.shrink(),
                                trailing: Text(
                                  'ADA',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_4.svg',
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Theme.of(context)
                                            .secondaryHeaderColor, BlendMode.srcIn)),
                                title: Text(
                                    '${state.transactionDetails?.timestamp}',
                                    style: TextStyle(fontFamily: 'Myriad Pro')),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                minVerticalPadding: 0,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              state.transactionDetails?.walletAddress != '' &&
                                      state.transactionDetails?.walletAddress !=
                                          ' '
                                  ? ListTile(
                                      leading: SvgPicture.asset(
                                          'assets/icons/img_5.svg',
                                          colorFilter: ColorFilter.mode(
                                              Theme.of(context).brightness ==
                                                  Brightness.light
                                                  ? Colors.black
                                                  : Theme.of(context)
                                                  .secondaryHeaderColor, BlendMode.srcIn)),
                                      title: Text(
                                          '${state.transactionDetails?.walletAddress}',
                                          style: TextStyle(
                                              fontFamily: 'Myriad Pro')),
                                      contentPadding: EdgeInsets.all(0),
                                      minVerticalPadding: 0,
                                      minLeadingWidth: 30,
                                      dense: true,
                                      visualDensity:
                                          VisualDensity(vertical: -3),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 4.0, 8.0, 4.0),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor)),
                                  color: Theme.of(context).secondaryHeaderColor,
                                  child: MaterialButton(
                                    minWidth: MediaQuery.of(context).size.width,
                                    padding:
                                        EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                    onPressed: () {
                                      isLastTransaction = false;
                                      BlocProvider.of<ProfileTransactionBloc>(
                                              context)
                                          .add(DeleteTransactionDetailsPage(
                                              transactionId:
                                                  widget.transactionId));
                                      Future.delayed(
                                          const Duration(milliseconds: 200),
                                          () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileTransactionsPage(
                                                        id: widget.id,
                                                        name: widget.name,
                                                        symbol: widget.symbol,
                                                        image: widget.image,
                                                        isRelevant:
                                                            widget.isRelevant)),
                                            (Route<dynamic> route) => false);
                                      });
                                    },
                                    child: Text(
                                      LocaleKeys.delete.tr(),
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 4.0, 32.0, 4.0),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor)),
                                  color: Theme.of(context).secondaryHeaderColor,
                                  child: MaterialButton(
                                    minWidth: MediaQuery.of(context).size.width,
                                    padding:
                                        EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                    onPressed: () {
                                      saveOrEdit = SaveOrEdit.edit;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionsPage(
                                                      symbol: widget.symbol,
                                                      name: widget.name,
                                                      image: widget.image,
                                                      id: widget.id,
                                                      transactionId:
                                                          widget.transactionId,
                                                      isRelevant:
                                                          widget.isRelevant,
                                                      cost: state
                                                          .transactionDetails!
                                                          .qty)));
                                    },
                                    child: Text(
                                      LocaleKeys.edit.tr(),
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
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Container greyCard(TransactionDetailsState state) {
    // String num1 = state.walletCoin is List
    //     ? Decimal.dividePrice(
    //     Decimal.convertPriceRound(state.walletCoin.first).toString())
    //     : '';
    // String num2 = state.walletCoin is List
    //     ? Decimal.dividePrice(
    //     Decimal.convertPriceRound(state.walletCoin.last).toString())
    //     : '';
    String num1 = '';
    String num2 = '';
    String num3 = '';
    if (state.transactionDetails != null) {
      num1 = state.transactionDetails!.qty > 1.0
          ? Decimal.dividePrice(
              Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty)
                  .toString())
          : Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty)
              .toString();
      num2 = ((state.transactionDetails!.qty *
                  state.transactionDetails!.usdPrice!) >
              1.0)
          ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(
                  state.transactionDetails!.qty *
                      state.transactionDetails!.usdPrice!)
              .toString())
          : Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty *
                  state.transactionDetails!.usdPrice!)
              .toString();
      num3 = ((state.transactionDetails!.qty *
                  state.transactionDetails!.adaPrice!) >
              1.0)
          ? Decimal.dividePrice(Decimal.convertPriceRoundToDouble(
                  state.transactionDetails!.qty *
                      state.transactionDetails!.adaPrice!)
              .toString())
          : Decimal.convertPriceRoundToDouble(state.transactionDetails!.qty *
                  state.transactionDetails!.adaPrice!)
              .toString();
    }
    //String currentSum = state.transactionDetails != null
    //    ? Decimal.dividePrice(Decimal.convertPriceRound(
    //            state.transactionDetails!.qty * currentPrice)
    //        .toString())
    //    : '';
    String text1 =
        '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty > 0.0 ? '-' : ''}$num1 ${widget.symbol}  /  ';
    String text2 =
        '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty > 0.0 ? '-' : ''}$num2 \$  /  ';
    String text3 =
        '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty > 0.0 ? '-' : ''}$num3 ₳';
    print('text1.length::: ${text1.length}');
    print('text2.length::: ${text2.length}');
    print('text3.length::: ${text3.length}');
    String finalText = '$text1$text2$text3';
    if (finalText.length >= 80) {
      finalText = '$text1\n$text2\n$text3';
    } else if (finalText.length >= 40 && finalText.length < 80) {
      if ((text1.length + text2.length) <= 40) {
        finalText = '$text1$text2\n$text3';
      } else {
        finalText = '$text1\n$text2\n$text3';
      }
    } else {
      finalText = '$text1$text2$text3';
    }
    return Container(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text(
            finalText,
            style: GoogleFonts.inter(
              fontSize: textSize13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.transparent),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}
