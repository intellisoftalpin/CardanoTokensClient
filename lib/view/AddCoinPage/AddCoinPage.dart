import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinBloc.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/view/ProfilePage/DetailsPage.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:crypto_offline/bloc/AddCoinBloc/AddCoinBloc.dart';
import 'package:crypto_offline/bloc/AddCoinBloc/AddCoinEvent.dart';
import 'package:crypto_offline/bloc/AddCoinBloc/AddCoinState.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/ListCoin.dart';
import '../../utils/decimal.dart';

bool searchPressed = false;
late AnimationController _animationController;

class AddCoinPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => AddCoinPage());
  }

  @override
  State<StatefulWidget> createState() {
    return AddCoinPageState();
  }
}

class AddCoinPageState extends State<AddCoinPage> {
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  List<ListCoin> listCoinView = [];
  List<ListCoin> listCoinNew = [];
  late CoinEntity coinEntity;
  late Color inputFieldTextColor;
  late EdgeInsets inputFieldPadding;
  late int weight;
  bool internet = false;
  final ScrollController _controller = ScrollController();

  void scrollUp() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (orientation == Orientation.portrait) {
      if (screenHeight < 600) {
        weight = 3;
      } else {
        weight = 2;
      }
    } else {
      weight = 6;
    }

    if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
      //when keyboard open
      inputFieldTextColor = Theme.of(context).shadowColor;
      inputFieldPadding = EdgeInsets.only(left: 20.0);
    } else {
      //when keyboard close
      inputFieldTextColor = Theme.of(context).shadowColor;
      inputFieldPadding = EdgeInsets.only(left: 20.0);
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
          return true;
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AddCoinBloc>(
              create: (context) => AddCoinBloc(ApiRepository(), ''),
            ),
            BlocProvider<SaveCoinBloc>(
              create: (context) => SaveCoinBloc(DatabaseProvider(),
                  HivePrefProfileRepositoryImpl(), coinEntity),
            ),
          ],
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                LocaleKeys.add_coin.tr(),
                // style: Theme
                //     .of(context)
                //     .appBarTheme
                //     .textTheme!
                //     .headline6,
                style: kAppBarTextStyle(context),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 35.0,
                  color: Theme.of(context).focusColor,
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProfilePage())),
              ),
            ),
            body: BlocBuilder<AddCoinBloc, AddCoinState>(
                builder: (context, state) {
              switch (state.state) {
                case AddCoinStatus.start:
                  context.read<AddCoinBloc>().add(CreateAddCoin(coin: ''));
                  return SplashPage();
                //     coinListNew = state.coinsList!;
                //     coinListView = coinListNew;
                //     break;
                //   case AddCoinStatus.loaded:
                //     coinListView = state.coinsList!;
                //     print("coinListView =  $coinListView");
                //     break;
                //   case AddCoinStatus.cache:
                //     coinListView = state.coinsList!;
                //     break;
                case AddCoinStatus.update:
                  listCoinView = state.listCoin!;
                  listCoinNew = state.listCoin!;
                  internet = state.internet;
                  print(
                      "::::::: internet =  $internet , coinListViewUpdate =  $listCoinView");
                  if (searchPressed) {
                    if (_controller.hasClients) scrollUp();
                    FocusManager.instance.primaryFocus?.unfocus();
                    searchPressed = false;
                  }
                  //     break;
                  // }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AddCoinBloc>().add(CreateAddCoin(coin: ''));
                    },
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: weight,
                            child: SearchLine(
                              inputFieldColor: inputFieldTextColor,
                              inputFieldPadding: inputFieldPadding,
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: (internet && state.listCoin!.isEmpty)
                                ? Center(
                                    child: Text(LocaleKeys.noCoinsFound.tr()))
                                : internet
                                    ? CustomScrollView(
                                        controller: _controller,
                                        slivers: <Widget>[
                                          //list 1 (using builder)
                                          SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              (context, i) {
                                                return getListCardano(context, i,
                                                    state); // HERE goes your list item
                                              },
                                              childCount:
                                                  state.listCoin!.length,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                top: 16.0,
                                                left: 16.0,
                                                right: 16.0,
                                                bottom: 16),
                                            child: Center(
                                              child: Text(
                                                LocaleKeys
                                                    .no_internet_connection
                                                    .tr(),
                                                style: TextStyle(
                                                    fontSize: textSize18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  );
              }
            }),
          ),
        ));
  }

  Widget getListCardano(BuildContext context, int index, AddCoinState state) {
    String cardanoPrice;
    var price = state.listCoin![index].price;
    (state.listCoin![index].price) != null
        ? cardanoPrice = '${Decimal.convertPriceRoundToString(price ?? 0.0)}'
        : cardanoPrice = "0.0";
    String cardanoPriceAda;
    var priceAda = state.listCoin![index].adaPrice;
    (state.listCoin![index].adaPrice) != null
        ? cardanoPriceAda = '${Decimal.convertPriceRoundToString(priceAda ?? 0.0)}'
        : cardanoPriceAda = "0.0";
    return Card(
      margin: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
      child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 2, right: 4, top: 4, bottom: 4),
                child: Text(
                  state.listCoin![index].name,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: textSize20,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  // style: Theme
                  //     .of(context)
                  //     .textTheme
                  //     .headline6!
                  //     .copyWith(fontSize: LargeTextSize),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 2, right: 4, top: 4, bottom: 4),
                child: Text(
                  '\$: $cardanoPrice',
                  style: GoogleFonts.inter(fontSize: textSize15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  // style: Theme
                  //     .of(context)
                  //     .textTheme
                  //     .headline6!
                  //     .copyWith(fontSize: MediumBodyTextSize),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 2, right: 4, top: 4, bottom: 4),
                child: Text(
                  '₳: $cardanoPriceAda',
                  style: GoogleFonts.inter(fontSize: textSize15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  // style: Theme
                  //     .of(context)
                  //     .textTheme
                  //     .headline6!
                  //     .copyWith(fontSize: MediumBodyTextSize),
                ),
              ),
            ],
          ),
          leading: Container(
            width: (MediaQuery.of(context).size.width - 30) / 5,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 2, right: 2, top: 0, bottom: 4),
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Colors.transparent,
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: '${state.listCoin![index].image}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => FutureBuilder(
                        future: checkContainImage(
                            'assets/image/${state.listCoin![index].name.toLowerCase()}.png'),
                        builder: (BuildContext context,
                            AsyncSnapshot<Widget> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done)
                            return snapshot.data!;
                          else
                            return Image.asset('assets/image/place_holder.png');
                        },
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      state.listCoin![index].symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: textSize8,
                      ),
                      // style: Theme
                      //     .of(context)
                      //     .textTheme
                      //     .headline6!
                      //     .copyWith(fontSize: LargeTextSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            print(
                "!! add coinPAge !! coinId: state.listCoin![index].image, = ${state.listCoin![index].image}");
            coinEntity = CoinEntity(
                coinId: state.listCoin![index].coinId,
                name: state.listCoin![index].name,
                symbol: state.listCoin![index].symbol,
                image: state.listCoin![index].image,
                currentPrice: state.listCoin![index].price!,
                percentChange24h: state.listCoin![index].percentChange24h,
                percentChange7d: state.listCoin![index].percentChange7d,
                marketCap: state.listCoin![index].marketCap!.toInt(),
                rank: state.listCoin![index].rank,
                price: state.listCoin![index].price,
                adaPrice: state.listCoin![index].adaPrice,
                liquidAda: state.listCoin![index].liquidAda,
                isRelevant: 1);
            print("coinEntity = $coinEntity");
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailsPage(coinEntity, cardanoPrice, cardanoPriceAda)));
            //saveCoinDialog(context, coinEntity);
          }),
    );
  }

  Future saveCoinDialog(BuildContext context, CoinEntity coinEntity) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save coin ' + '${coinEntity.name}'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                BlocListener<SaveCoinBloc, SaveCoinState>(
                    bloc: SaveCoinBloc(DatabaseProvider(),
                        HivePrefProfileRepositoryImpl(), coinEntity),
                    listener: (context, state) {
                      if (state.state == SaveCoinStatus.save) {
                        BlocProvider.of<SaveCoinBloc>(context)
                            .add(SaveCoin(coin: coinEntity));
                      }
                    });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
          ],
        );
      },
    );
  }
}

class SearchLine extends StatefulWidget {
  final Color inputFieldColor;
  final EdgeInsets inputFieldPadding;

  SearchLine(
      {Key? key,
      required this.inputFieldColor,
      required this.inputFieldPadding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchLineState();
}

class _SearchLineState extends State<SearchLine>
    with SingleTickerProviderStateMixin {
  final _textEditingController = TextEditingController();
  final FocusNode _focusNode = new FocusNode();
  bool obs = true;
  final searchLine = GlobalKey();

  @override
  void initState() {
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     _textEditingController.selection = TextSelection(
    //         baseOffset: 0, extentOffset: _textEditingController.text.length);
    //   }
    // });
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      _animationController.reset();
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(10.0),
        child: TextField(
          onSubmitted: (value) {
            _animationController.repeat(reverse: true);
            enterButtonSearch();
            print("${_textEditingController.text}");
            searchPressed = true;
          },
          textInputAction: TextInputAction.done,
          key: searchLine,
          obscureText: obs,
          controller: _textEditingController,
          // focusNode: _focusNode,
          autofocus: true,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.start,
          onChanged: (value) => setState(() {
            obs = false;
            if (value == '') {
              enterButtonSearch();
            }
          }),
          enabled: true,
          decoration: kTextFieldSearchDecoration(context).copyWith(
            contentPadding: widget.inputFieldPadding,
            hintText: LocaleKeys.enter_coin.tr(),
            suffixIcon: Container(
                width: 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _animationController.repeat(reverse: true);
                      enterButtonSearch();
                      print("${_textEditingController.text}");
                      searchPressed = true;
                    },
                    child: AnimatedIcon(
                        color: Theme.of(context)
                            .iconTheme
                            .copyWith(color: Theme.of(context).shadowColor)
                            .color,
                        progress: _animationController,
                        icon: AnimatedIcons.search_ellipsis,
                        size: Theme.of(context)
                            .iconTheme
                            .copyWith(size: MediumIcon)
                            .size),
                  ),
                )),
          ),
          style: TextStyle(
            color: Theme.of(context).disabledColor,
          ),
          //onChanged: (string) {
          //  BlocProvider.of<AddCoinBloc>(context)
          //      .add(CreateAddCoin(coin: string));
          //  //context.read<AddCoinBloc>().CreateAddCoin(coin: string);
          //  print("$string");
          //  //  },);
          //},
        ),
    );
  }

  void enterButtonSearch() {
    BlocProvider.of<AddCoinBloc>(context)
        .add(CreateAddCoin(coin: _textEditingController.text));
  }
}

// ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// content: Text('snack'),
// duration: Duration(seconds: 5),
// ));
