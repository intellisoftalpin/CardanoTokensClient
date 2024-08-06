import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto_offline/bloc/AddCoinBloc/AddCoinEvent.dart';
import 'package:crypto_offline/bloc/AddCoinBloc/AddCoinState.dart';
import 'package:crypto_offline/data/model/CardanoModel.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../../domain/entities/ListCoin.dart';

class AddCoinBloc extends Bloc<AddCoinEvent, AddCoinState> {
  final IApiRepository _apiRepository;
  String searchCoin;

  AddCoinBloc(this._apiRepository, this.searchCoin)
      : super(AddCoinState(AddCoinStatus.start, false, [])) {
    add(CreateAddCoin(coin: searchCoin));
  }

  @override
  Stream<AddCoinState> mapEventToState(AddCoinEvent event) async* {
    if (event is CreateAddCoin) {
      searchCoin = event.coin;
      yield* _getCoinsList(event, state);
    }
  }

  Stream<AddCoinState> _getCoinsList(
      AddCoinEvent event, AddCoinState state) async* {
    List<Tokens>? cardanoList = [];
    List<ListCoin> foundCoinsList = [];
    List<ListCoin> cardanoCoinsList = [];
    bool internet = false;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2016-01-25
    var statusResponseCardano = 0;
    try {
      // String dateCache = await FileManager.readDateCache();
      internet = await _apiRepository.check();
      print("internet = $internet");
      if (internet) {
        try {
          Response responseCardano = await _apiRepository.getCardanoTokensList();
          if (responseCardano.statusCode == HttpStatus.ok) {
            Map data = jsonDecode(responseCardano.body);

            cardanoList = (data["tokens"] as List)
                .map((e) => Tokens.fromJson(e))
                .cast<Tokens>()
                .toList();

            print("cardanoList api = $cardanoList");
          } else {
            statusResponseCardano = responseCardano.statusCode;
            print("statusResponceCardano= $statusResponseCardano");
          }
        } on TimeoutException catch (e) {
          print('Timeout Error: $e');
        } on SocketException catch (e) {
          print('Socket Error: $e');
        }
      }
      for (var cardano in cardanoList!) {
        cardanoCoinsList.add(ListCoin(
            coinId: cardano.tokenId!,
            name: cardano.name!,
            symbol: cardano.assetName!,
            rank: cardano.decimals,
            image: 'https://ctokens.io/api/v1/tokens/images/${cardano.policyId}.${cardano.assetId}.png',
            marketCap: cardano.capUsd!.toInt(),
            percentChange24h: cardano.priceTrend24h,
            percentChange7d: cardano.priceTrend7d,
            costUsd: 0.0,
            costAda: 0.0,
            quantity: 0.0,
            price: cardano.priceUsd,
            adaPrice: cardano.priceAda,
            liquidAda: cardano.liquidAda,
            isRelevant: 1));
      }
      print("searchCoin= $searchCoin");
      if (searchCoin.isEmpty) {
        cardanoCoinsList.sort((b, a) => a.liquidAda!.compareTo(b.liquidAda!));
        yield state.copyWith(AddCoinStatus.update, internet, cardanoCoinsList);
        // AddCoinStatus.loaded,

      } else if (searchCoin.isNotEmpty) {
        /*     Response response = await _apiRepository.searchCoins(searchCoin);
      if (response.statusCode == HttpStatus.ok) {
        searchCoinsList = (jsonDecode(response.body)['currencies'] as List)
            .map((i) => Currencies.fromJson(i))
            .toList();
        print("coinsList_search = ${searchCoinsList}");
        for (var element in searchCoinsList) {
          var coins = CoinModel(
              id: element.id,
              symbol: element.symbol,
              name: element.name,
              quotes: null);
          foundCoinsList.add(coins);
        }
        print("foundCoinsList = $foundCoinsList");
        yield state.copyWith(AddCoinStatus.update, foundCoinsList);
      } else {
        statusResponce = response.statusCode;
        print("statusResponce= $statusResponce");
      }*/
        foundCoinsList = cardanoCoinsList
            .where((coin) =>
                    coin.name.toLowerCase().contains(searchCoin.toLowerCase())
                    //    && coin.name.toLowerCase().startsWith(searchCoin.toLowerCase())
                    ||
                    coin.symbol.toLowerCase().contains(searchCoin.toLowerCase())
                //    && coin.symbol.toLowerCase().startsWith(searchCoin.toLowerCase())
                )
            .toList();

        foundCoinsList.sort((b, a) => a.liquidAda!.compareTo(b.liquidAda!));

        print("foundCoinsList = $foundCoinsList, new cardanoCoinsList = $cardanoCoinsList");
        yield state.copyWith(AddCoinStatus.update, internet, foundCoinsList);
      }
    } on Error catch (e) {
      print('General Error: $e');
    }
  }
}
