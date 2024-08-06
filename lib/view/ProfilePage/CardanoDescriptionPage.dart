import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/SaveCoinBloc/SaveCoinBloc.dart';
import '../../bloc/SaveCoinBloc/SaveCoinState.dart';
import '../../data/database/DbProvider.dart';
import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../../data/model/CardanoModel.dart';
import '../../domain/entities/CoinEntity.dart';
import '../../generated/locale_keys.g.dart';
import '../../utils/decimal.dart';
import 'CardanoWebView.dart';
import 'ProfileTransactionsPage.dart';

class CardanoDescriptionPage extends StatefulWidget {
  final Tokens token;
  final double exchangeAda;

  const CardanoDescriptionPage(
      {Key? key, required this.token, required this.exchangeAda})
      : super(key: key);

  @override
  _CardanoDescriptionPageState createState() => _CardanoDescriptionPageState();
}

class _CardanoDescriptionPageState extends State<CardanoDescriptionPage> {
  @override
  Widget build(BuildContext context) {
    double mainWidth = MediaQuery.of(context).size.width - 5.0;
    Tokens token = widget.token;
    print('token.tokenLink::: ${token.tokenLink}');
    print('token.explorerLink:::: ${token.explorerLink}');
    print('token.description:::: ${token.description}');
    String description = '';
    if (token.description != null) {
      description = token.description!.replaceAll('â', '\’');
      description = description.replaceAll('â', '\"');
      description = description.replaceAll('â', '\"');
      description = description.replaceAll('Â', '');
      description = description.replaceAll('â³', '₳');
      description = description.replaceAll('â', '-');
      description = description.replaceAll('â¥', '♥');
    }
    AppBar appBar = AppBar(
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        LocaleKeys.description.tr(),
        style: kAppBarTextStyle(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage())),
      ),
    );
    CoinEntity coinEntity = CoinEntity(
        coinId: token.tokenId ?? '1',
        name: token.name ?? '1',
        symbol: token.assetName ?? '1',
        image:
            'https://ctokens.io/api/v1/tokens/images/${token.policyId}.${token.assetId}.png',
        currentPrice: token.priceUsd!,
        percentChange24h: token.priceTrend24h,
        percentChange7d: token.priceTrend7d,
        marketCap: token.capUsd != null ? token.capUsd!.toInt() : 0,
        rank: token.decimals,
        price: token.priceUsd,
        adaPrice: token.priceAda,
        liquidAda: token.liquidAda,
        isRelevant: 1);
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
        },
        child: Scaffold(
          appBar: appBar,
          backgroundColor: Theme.of(context).primaryColor,
          body: Container(
              margin: EdgeInsets.only(left: 5.0, top: 5.0),
              width: mainWidth,
              height: MediaQuery.of(context).size.height -
                  appBar.preferredSize.height -
                  MediaQuery.of(context).viewPadding.top -
                  5.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).primaryColor
                  ],
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0)),
              ),
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 10.0),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 75.0,
                                  height: 75.0,
                                  child: CircleAvatar(
                                    radius: 35.0,
                                    backgroundColor: Colors.transparent,
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      imageUrl:
                                          'https://ctokens.io/api/v1/tokens/images/${token.policyId}.${token.assetId}.png',
                                      fit: BoxFit.fitWidth,
                                      errorWidget: (context, url, error) =>
                                          FutureBuilder(
                                        future: checkContainImage(
                                            'assets/image/${token.policyId}.png'),
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
                                  width: mainWidth - 100.0,
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${token.name ?? '-'}',
                                          textAlign: TextAlign.start,
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).focusColor,
                                            fontSize: textSize20,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          description,
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context).focusColor,
                                            fontSize: textSize16,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          '${LocaleKeys.price.tr()}:',
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context).focusColor,
                                            fontSize: textSize16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          '₳ ${Decimal.convertPriceRoundToString(token.priceAda ?? 0.0)}',
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontSize: textSize17,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          '\$ ${Decimal.convertPriceRoundToString(token.priceUsd ?? 0.0)}',
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context).focusColor,
                                            fontSize: textSize17,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        SizedBox(
                                            width: mainWidth - 100.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${LocaleKeys.rank.tr()}:',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '₳ ${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.capAda ?? 0.0).round().toString())}',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '\$ ${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.capUsd ?? 0.0).round().toString())}',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        SizedBox(height: 10.0),
                                        SizedBox(
                                            width: mainWidth - 100.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${LocaleKeys.liquidity.tr()}:',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '₳ ${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.liquidAda ?? 0.0).round().toString())}',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '\$ ${Decimal.dividePrice(Decimal.convertPriceRoundToDouble((token.liquidAda ?? 0.0) * widget.exchangeAda).round().toString())}',
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontSize: textSize16,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ]),
                                )
                              ],
                            ),
                          ),
                          Container(
                              width: mainWidth - 55.0,
                              margin: EdgeInsets.only(right: 25.0, left: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ((token.assetName != null &&
                                              token.assetName != '') &&
                                          (token.policyId != null &&
                                              token.policyId != ''))
                                      ? Container(
                                          alignment: Alignment.centerLeft,
                                          width: (mainWidth - 105.0) * 0.5,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CardanoWebView(
                                                              url:
                                                                  'https://cardanoscan.io/token/${token.policyId}.${token.assetName}',
                                                              appBar: LocaleKeys
                                                                  .blockchain
                                                                  .tr(),
                                                              token: token,
                                                              exchangeAda: widget
                                                                  .exchangeAda)));
                                            },
                                            child: Image.asset(
                                                'assets/icons/token_link.png'),
                                          ))
                                      : SizedBox(
                                          width: (mainWidth - 105.0) * 0.5),
                                  (token.tokenLink != null &&
                                          token.tokenLink != '')
                                      ? Container(
                                          alignment: Alignment.centerRight,
                                          width: (mainWidth - 105.0) * 0.5,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CardanoWebView(
                                                              url: token
                                                                  .tokenLink!,
                                                              appBar: LocaleKeys
                                                                  .tokenHomepage
                                                                  .tr(),
                                                              token: token,
                                                              exchangeAda: widget
                                                                  .exchangeAda)));
                                            },
                                            child: Image.asset(
                                                'assets/icons/explorer_link.png'),
                                          ))
                                      : SizedBox(
                                          width: (mainWidth - 105.0) * 0.5),
                                ],
                              )),
                          SizedBox(height: 15.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              onPressed: () {
                                BlocListener<SaveCoinBloc, SaveCoinState>(
                                    bloc: SaveCoinBloc(
                                        DatabaseProvider(),
                                        HivePrefProfileRepositoryImpl(),
                                        coinEntity),
                                    listener: (context, state) {
                                      if (state.state == SaveCoinStatus.save) {
                                        BlocProvider.of<SaveCoinBloc>(context)
                                            .add(SaveCoin(coin: coinEntity));
                                      }
                                    });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileTransactionsPage(
                                              id: coinEntity.coinId,
                                              name: coinEntity.name,
                                              symbol: coinEntity.symbol,
                                              image:
                                                  'https://ctokens.io/api/v1/tokens/images/${token.policyId}.${token.assetId}.png',
                                              isRelevant: 1,
                                            )));
                              },
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                LocaleKeys.add.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                        color: Theme.of(context).shadowColor,
                                        fontFamily: 'MyriadPro',
                                        fontSize: textSize20),
                              ),
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ],
                      )))),
        ));
  }
}
