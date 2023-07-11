import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinBloc.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';

import '../../domain/entities/ListCoin.dart';
import 'ProfileTransactionsPage.dart';

class DetailsPage extends StatefulWidget {
  final CoinEntity coinEntity;
  final String coinPrice;
  final String coinPriceAda;

  DetailsPage(this.coinEntity, this.coinPrice, this.coinPriceAda);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late GlobalKey<ScaffoldState> _key;
  List<ListCoin> listCoinDb = [];

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    _key = GlobalKey();
    AppBar appBar = AppBar(
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Theme.of(context).primaryColorDark,
      title: Text(
        LocaleKeys.details.tr(),
        style: kAppBarTextStyle(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 35.0,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () {
          _key.currentState!.openDrawer();
        },
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      key: _key,
      appBar: appBar,
      drawer: ProfilePageState.getDrawMenu(context, _packageInfo),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).viewPadding.top,
          child: SingleChildScrollView(child: portrait())),
    );
  }

  Widget portrait() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 20.0,
          height: 400.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).primaryColorDark,
              ],
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          imageUrl: widget.coinEntity.image!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => FutureBuilder(
                            future: checkContainImage(
                                'assets/image/${widget.coinEntity.symbol.toLowerCase()}.png'),
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
                    SizedBox(
                      width: 10.0,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.coinEntity.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: textSize30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  '\$: ${widget.coinPrice} \n₳: ${widget.coinPriceAda}',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).focusColor,
                    fontSize: textSize24,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    BlocListener<SaveCoinBloc, SaveCoinState>(
                        bloc: SaveCoinBloc(DatabaseProvider(),
                            HivePrefProfileRepositoryImpl(), widget.coinEntity),
                        listener: (context, state) {
                          if (state.state == SaveCoinStatus.save) {
                            BlocProvider.of<SaveCoinBloc>(context)
                                .add(SaveCoin(coin: widget.coinEntity));
                          }
                        });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileTransactionsPage(
                                  id: widget.coinEntity.coinId,
                                  name: widget.coinEntity.name,
                                  symbol: widget.coinEntity.symbol,
                                  image: widget.coinEntity.image ?? '',
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
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    LocaleKeys.cancel.tr(),
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
          ),
        ),
      ],
    );
  }
}
