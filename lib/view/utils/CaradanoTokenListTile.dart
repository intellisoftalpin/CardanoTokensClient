import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/data/model/CardanoModel.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

Widget getCardanoCoinTile(BuildContext context, int index, Tokens token,
    bool tokensPageLiq, double adaExchange) {
  String capLiqUsd = '';
  String capLiqAda = '';
  if (tokensPageLiq) {
    capLiqUsd =
        '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble((token.liquidAda ?? 0.0) * adaExchange).round().toString())} \$';
    capLiqAda =
        '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.liquidAda ?? 0.0).round().toString())} ₳';
  } else {
    capLiqUsd =
        '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.capUsd ?? 0.0).round().toString())} \$';
    capLiqAda =
        '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.capAda ?? 0.0).round().toString())} ₳';
  }
  return Card(
    margin: EdgeInsets.only(left: 5, right: 5, bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width - 40) * 0.1,
          height: 55.0,
          child: Text(
            index.toString(),
            maxLines: 1,
            style: GoogleFonts.inter(
              color: Theme.of(context).focusColor,
              fontSize: textSize13,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Container(
            width: 30.0,
            height: 30.0,
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.transparent,
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl:
                    'https://ctokens.io/api/v1/tokens/images/${token.policyId}.${token.assetId}.png',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => FutureBuilder(
                  future:
                      checkContainImage('assets/image/${token.policyId}.png'),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return snapshot.data!;
                    else
                      return Image.asset('assets/image/place_holder.png');
                  },
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 3.0),
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width - 40) * 0.25,
          child: Text(
            '${token.name ?? '-'}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: GoogleFonts.inter(
              color: Theme.of(context).focusColor,
              fontSize: textSize12,
            ),
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 40) * 0.25,
          height: 55.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  '${Decimal.convertPriceRoundToDouble(token.priceAda ?? 0.0)} ₳',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${Decimal.convertPriceRoundToDouble(token.priceUsd ?? 0.0)} \$',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).focusColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 40) * 0.4,
          height: 65.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  capLiqAda,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
              Container(
                child: Text(
                  capLiqUsd,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).focusColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget getCardanoCoinTileLiq(BuildContext context, int index, Tokens token) {
  return Card(
    margin: EdgeInsets.only(left: 5, right: 5, bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width - 40) * 0.1,
          height: 55.0,
          child: Text(
            index.toString(),
            maxLines: 1,
            style: GoogleFonts.inter(
              color: Theme.of(context).focusColor,
              fontSize: textSize13,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Container(
            width: 30.0,
            height: 30.0,
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.transparent,
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl:
                    'https://ctokens.io/api/v1/tokens/images/${token.policyId}.${token.assetId}.png',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => FutureBuilder(
                  future:
                      checkContainImage('assets/image/${token.policyId}.png'),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return snapshot.data!;
                    else
                      return Image.asset('assets/image/place_holder.png');
                  },
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 3.0),
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width - 40) * 0.25,
          child: Text(
            '${token.name ?? '-'}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: GoogleFonts.inter(
              color: Theme.of(context).focusColor,
              fontSize: textSize12,
            ),
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 40) * 0.25,
          height: 55.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  '${Decimal.convertPriceRoundToDouble(token.priceAda ?? 0.0)} ₳',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kPlusIconColor
                        : lPlusIconColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${Decimal.convertPriceRoundToDouble(token.priceUsd ?? 0.0)} \$',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).focusColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - 40) * 0.4,
          height: 65.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.liquidAda ?? 0.0).round().toString())} ₳',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kPlusIconColor
                        : lPlusIconColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${Decimal.dividePrice(Decimal.convertPriceRoundToDouble(token.liquidAda ?? 0.0).round().toString())} \$',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: Theme.of(context).focusColor,
                    fontSize: textSize12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
