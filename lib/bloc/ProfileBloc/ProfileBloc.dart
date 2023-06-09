import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepository.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/ListCoin.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/utils/file_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart' as profile;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../../core/error/exeption.dart';
import '../../data/model/CardanoModel.dart';

part 'ProfileEvent.dart';

part 'ProfileState.dart';

String? coinIdToDelete;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._dbRepository, this._prefProfileRepository,
      this._hiveProfileRepository, this._apiRepository)
      : super(ProfileState(ProfileStatus.start, [], [], [], [], false)) {
    add(CreateProfile());
  }

  final DbRepository _dbRepository;
  final SharedPrefProfileRepository _prefProfileRepository;
  final HivePrefProfileRepository _hiveProfileRepository;
  final IApiRepository _apiRepository;

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is CreateProfile) {
      yield* _getCoinsList(event, state);
    }
  }

  Stream<ProfileState> _getCoinsList(
      ProfileEvent event, ProfileState state) async* {
    List<double> wallet = [];
    List<double> walletAda = [];
    List<TransactionEntity> transactions = [];
    List<ListCoin> listCoin = [];
    List<ProfileModel> profile = [];
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    var formatterCache = new DateFormat('yyyy-MM-dd hh:mm');
    String formattedDate = formatter.format(now);
    String formattedDateCache = formatterCache.format(now);
    bool cache = false;
    bool isSame = false;
    bool isErrorEmpty = false;
    var pass = globals.pass.trim();
    print(
        "formattedDateCache = $formattedDateCache, formattedDate = $formattedDate"); // 2016-01-25
    try {
      await _prefProfileRepository.delProfile('lastProf');
      print(
          "globals.nameProfile = ${globals.nameProfile}, globals.pass = ${globals.pass}");
      print("pass = $pass");
      // global.idProfile =  await _hiveProfileRepository.getProfileByName(globals.nameProfile);

      profile = await _hiveProfileRepository.showProfile();
      print("profile = $profile");

      if (pass.isEmpty || pass == '') {
        // profile = await _hiveProfileRepository.showProfile();
        isErrorEmpty = true;
        yield state.copyWith(ProfileStatus.loading, wallet, walletAda,
            profile.toList(), listCoin, isErrorEmpty);
      } else {
        isErrorEmpty = false;
        var internet = await _apiRepository.check();
        print("intenet = $internet");
        print("::::::: global.idProfile = ${global.idProfile}");
        await _dbRepository.openDb(global.idProfile, pass);
        String lastDateCache = '';
        if (await FileManager.readDateCache() == null) {
          lastDateCache = '';
        } else {
          lastDateCache = await FileManager.readDateCache();
        }
        print("lastDateCache = $lastDateCache");
        if (lastDateCache.isNotEmpty) {
          int diffDays =
              now.difference(DateTime.parse(lastDateCache)).inMinutes;
          diffDays >= 720 ? diffDays = (diffDays - 720) : diffDays = diffDays;
          print("diffDays = $diffDays");
          isSame = (diffDays >= 55);
          print("DateTime.parse(coinsModel)= ${DateTime.parse(lastDateCache)}, "
              "formattedDateCache = $formattedDateCache, diffDays = $diffDays, isSame = $isSame");
        }
        if (lastDateCache.isEmpty || isSame) {
          if (internet) {
            _apiRepository.check().then((internet) async {
              await FileManager.deleteCache();
              await savePrices(formattedDateCache);
            });
          }
        }
        if (coinIdToDelete != null) {
          List<TransactionEntity> transactionList =
              await _dbRepository.getAllTransactionByIdCoin(coinIdToDelete!);
          print('coinIdToDelete = $coinIdToDelete');
          await _dbRepository.deleteCoin(int.parse(coinIdToDelete!));
          if (transactionList.isNotEmpty) {
            for (var data in transactionList) {
              try {
                print("transactionId = ${data.transactionId}");
                await _dbRepository.deleteTransaction(data.transactionId!);
              } on Exception catch (_) {
                throw CacheExeption();
              }
            }
          }
          coinIdToDelete = null;
        }
        transactions = await _dbRepository.getAllTransaction();
        print("!!!transactions!!!! = $transactions");
        print("!!!lastDateCache!!!! = ${await FileManager.readDateCache()}");

        //profile = await _hiveProfileRepository.showProfile();
        if (transactions.isNotEmpty) {
          if (lastDateCache.isNotEmpty) {
            wallet = (await getWallet(transactions))!;
            print('!!!!!wallet:::: $wallet');
            walletAda = (await getWalletAda(transactions))!;
            print('!!!!!walletAda:::: $walletAda');
            cache = true;
          } else {
            if (internet) {
              wallet = await getWalletApi(transactions);
              walletAda = await getWalletAdaApi(transactions);
              cache = false;
            }
          }
          listCoin = await getListCoin(cache, internet);
          print('!!!!!!!listCoin::::: $listCoin');
        } else {
          print('10');
          if (lastDateCache.isNotEmpty) {
            cache = true;
          } else {
            cache = false;
          }
          listCoin = await getListCoin(cache, internet);
          print('11');
        }
        // yield state.copyWith(ProfileStatus.loaded, wallet, profile, listCoin);

        print("wallet = $wallet");
        print("walletAda = $walletAda");
        print("listCoin = $listCoin");
        print("22profile = $profile");
        yield state.copyWith(ProfileStatus.loaded, wallet, walletAda,
            profile.toList(), listCoin);
      }
    } on Exception catch (e) {
      print("coinsListDB new error = $e isErrorEmpty = $isErrorEmpty");
      profile = await _hiveProfileRepository.showProfile();
      yield state.copyWith(ProfileStatus.loading, wallet, walletAda,
          profile.toList(), [], isErrorEmpty);
      throw Exception("Error on coinsListDB");
    }
  }

  Future<List<double>?> getWallet(List<TransactionEntity> transactions) async {
    double walletInOut = 0;
    var cost = 0.0;
    double priseUsd = 0.0;
    List<double>? walleted = [];
    print(getWallet);
    for (var element in transactions) {
      cost = element.qty;
      var id = element.coinId;
      if (await FileManager.readCoinById(id) == null ||
          await FileManager.readCoinById(id) == 0.0) {
        priseUsd = (await _dbRepository.getCoin(id)).price!;
      } else {
        CoinEntity coin =
            CoinEntity.fromDatabaseJson(await FileManager.readCoinById(id));
        priseUsd = coin.currentPrice;
      }
      print("coinsModel priseUsd = $priseUsd, cost = $cost");

      if (element.type == 'In') {
        walletInOut += cost * priseUsd;
      } else if (element.type == 'Out') {
        walletInOut -= cost * priseUsd;
      }
      walleted.clear();
      walleted.insert(0, walletInOut);
      print("getWallet = $walleted");
    }
    return walleted;
  }

  Future<List<double>?> getWalletAda(
      List<TransactionEntity> transactions) async {
    double walletAdaInOut = 0;
    var cost = 0.0;
    double priseAda = 0.0;
    List<double>? walletedAda = [];
    print(getWalletAda);
    for (var element in transactions) {
      cost = element.qty;
      var id = element.coinId;
      if (await FileManager.readCoinById(id) == null ||
          await FileManager.readCoinById(id) == 0.0) {
        priseAda = (await _dbRepository.getCoin(id)).adaPrice!;
      } else {
        CoinEntity coin =
            CoinEntity.fromDatabaseJson(await FileManager.readCoinById(id));
        priseAda = coin.adaPrice!;
      }
      print("coinsModel priseUsd = $priseAda, cost = $cost");

      if (element.type == 'In') {
        walletAdaInOut += cost * priseAda;
      } else if (element.type == 'Out') {
        walletAdaInOut -= cost * priseAda;
      }
      walletedAda.clear();
      walletedAda.insert(0, walletAdaInOut);
      walletedAda.insert(1, walletAdaInOut);
      print("getWallet = $walletedAda");
    }
    return walletedAda;
  }

  Future<List<double>> getWalletApi(
      List<TransactionEntity> transactions) async {
    double walletInOut = 0;
    List<double> walleted = [];
    num priseUsd = 0;
    Response responseCardano = await _apiRepository.getCardanoTokensList();
    for (var element in transactions) {
      if (responseCardano.statusCode == HttpStatus.ok) {
        Map data = jsonDecode(responseCardano.body);
        profile.adaExchangeGlobal = data["usd"] as double;
        var cardanoList = (data["tokens"] as List)
            .map((e) => Tokens.fromJson(e))
            .cast<Tokens>()
            .toList();
        for (var cardano in cardanoList) {
          if (cardano.tokenId == element.coinId) {
            priseUsd = cardano.priceUsd!;
          } else if (element.coinId.isNotEmpty) {
            priseUsd =
                (await _dbRepository.getCoin(element.coinId)).currentPrice;
          }
        }
      } else {
        if (element.coinId.isNotEmpty) {
          priseUsd = (await _dbRepository.getCoin(element.coinId)).currentPrice;
        }
      }
      var cost = element.qty;
      print("cost = $cost");
      if (element.type == 'In') {
        walletInOut += cost * priseUsd;
      } else if (element.type == 'Out') {
        walletInOut -= cost * priseUsd;
      }
      walleted.clear();
      walleted.insert(0, walletInOut);
      walleted.insert(1, walletInOut);
      print("getWalletApi = $walleted");
    }
    return walleted;
  }

  Future<List<double>> getWalletAdaApi(
      List<TransactionEntity> transactions) async {
    double walletAdaInOut = 0;
    List<double> walletedAda = [];
    double priseAda = 0;
    Response responseCardano = await _apiRepository.getCardanoTokensList();
    for (var element in transactions) {
      if (responseCardano.statusCode == HttpStatus.ok) {
        Map data = jsonDecode(responseCardano.body);
        profile.adaExchangeGlobal = data["usd"] as double;
        var cardanoList = (data["tokens"] as List)
            .map((e) => Tokens.fromJson(e))
            .cast<Tokens>()
            .toList();
        for (var cardano in cardanoList) {
          if (cardano.tokenId == element.coinId) {
            priseAda = cardano.priceAda!;
          } else if (element.coinId.isNotEmpty) {
            priseAda = (await _dbRepository.getCoin(element.coinId)).adaPrice!;
          }
        }
      } else {
        if (element.coinId.isNotEmpty) {
          print('element.coinId.isNotEmpty');
          priseAda = (await _dbRepository.getCoin(element.coinId)).adaPrice!;
        }
      }
      var cost = element.qty;
      print("cost = $cost");
      if (element.type == 'In') {
        walletAdaInOut += cost * priseAda;
      } else if (element.type == 'Out') {
        walletAdaInOut -= cost * priseAda;
      }
      walletedAda.clear();
      walletedAda.insert(0, walletAdaInOut);
      walletedAda.insert(1, walletAdaInOut);
      print("getWalletAdaApi = $walletedAda");
    }
    return walletedAda;
  }

  Future<List<ListCoin>> getListCoin(bool cache, var internet) async {
    double walletInOut = 0;
    double costInOut = 0;
    num priseUsd = 0;
    double walletAdaInOut = 0;
    num adaPrise = 0;
    var cost = 0.0;
    String? symbol = '';
    String? name = '';
    String? image = '';
    int? marketCap = 0;
    double? percentChange24h = 0.0;
    double? percentChange7d = 0.0;
    int? rank = 0;
    double liquidAda = 0.0;
    int isRelevant = 1;
    List<TransactionEntity> transaction = [];
    List<ListCoin> listCoin = [];
    List<CoinEntity> coinsList = [];
    int statusCardano = 0;
    List<Tokens> cardanoList = await getCardanoList(internet);
    if (cardanoList.isNotEmpty && internet) {
      statusCardano = HttpStatus.ok;
    }
    print('statusCardano: $statusCardano');
    coinsList = await _dbRepository.getAllCoins();
    print("coinsList_get = $coinsList");
    if (coinsList.isNotEmpty) {
      for (var coin in coinsList) {
        String id = coin.coinId;
        // print("!!Coin!!!id!!!! = $id FileManager.readCoinById(id) = ${await FileManager.readCoinById(id)}");
        id = coin.coinId;
        symbol = coin.symbol;
        name = coin.name;
        image = coin.image;
        priseUsd = coin.price!;
        adaPrise = coin.adaPrice!;
        marketCap = coin.marketCap;
        percentChange24h = coin.percentChange24h;
        percentChange7d = coin.percentChange7d;
        rank = coin.rank;
        liquidAda = coin.liquidAda!;
        isRelevant = 0;
        if (cache && internet) {
          if (await FileManager.readCoinById(id) == null) {
            for (var cardano in cardanoList) {
              if (cardano.tokenId == id) {
                id = coin.coinId;
                symbol = coin.symbol;
                name = coin.name;
                image = coin.image;
                priseUsd = coin.price!;
                adaPrise = coin.adaPrice!;
                marketCap = coin.marketCap;
                percentChange24h = coin.percentChange24h;
                percentChange7d = coin.percentChange7d;
                rank = coin.rank;
                liquidAda = coin.liquidAda!;
                isRelevant = 1;
                print("!!!__ 1 !!!");
              }
            }
          } else {
            CoinEntity coinById =
                CoinEntity.fromDatabaseJson(await FileManager.readCoinById(id));
            print("!!!!coinsModel!!!! = $coinById");
            id = id;
            symbol = coinById.symbol;
            name = coinById.name;
            image = coinById.image;
            priseUsd = coinById.price!;
            adaPrise = coinById.adaPrice!;
            marketCap = coinById.marketCap;
            percentChange24h = coinById.percentChange24h;
            percentChange7d = coinById.percentChange7d;
            rank = coinById.rank;
            isRelevant = coinById.isRelevant;
            liquidAda = coinById.liquidAda!;
            print("!!!__ 3 !!!");
          }
        } else {
          if (statusCardano == HttpStatus.ok) {
            for (var cardano in cardanoList) {
              print("!!!!222 cardano id = $id , cardano = $cardano");
              if (cardano.tokenId == id) {
                id = cardano.tokenId!;
                name = cardano.name!;
                symbol = cardano.assetName!;
                image =
                    'https://ctokens.io/api/v1/tokens/images/${cardano.policyId}.${cardano.assetId}.png';
                priseUsd = cardano.priceUsd!;
                adaPrise = cardano.priceAda!;
                marketCap = cardano.capUsd!.toInt();
                percentChange24h = cardano.priceTrend24h;
                percentChange7d = cardano.priceTrend7d;
                rank = cardano.decimals;
                liquidAda = cardano.liquidAda!;
                isRelevant = 1;
                print("!!!__ 5 !!!");
                break;
              }
            }
          } else if ((await _dbRepository.getCoin(id)).coinId.isNotEmpty &&
              internet) {
            id = coin.coinId;
            name = coin.name;
            symbol = coin.symbol;
            image = coin.image;
            priseUsd = coin.price!;
            adaPrise = coin.adaPrice!;
            marketCap = coin.marketCap;
            percentChange24h = coin.percentChange24h;
            percentChange7d = coin.percentChange7d;
            rank = coin.rank;
            liquidAda = coin.liquidAda!;
            isRelevant = coin.isRelevant;
            print("!!!__ 7 !!!");
            print(' !!!! cache= false symbol = $symbol ');
          }
        }
        transaction = await _dbRepository.getAllTransactionByIdCoin(id);
        if (transaction.isNotEmpty) {
          for (var element in transaction) {
            cost = element.qty;
            print(element);
            if (element.type == 'In') {
              walletInOut += cost * priseUsd;
              walletAdaInOut += cost * adaPrise;
              costInOut += cost;
            } else if (element.type == 'Out') {
              walletInOut -= cost * priseUsd;
              walletAdaInOut -= cost * adaPrise;
              costInOut -= cost;
            }
          }
        } else {
          costInOut = 0.0;
          walletInOut = 0.0;
          walletAdaInOut = 0.0;
        }
        print(
            "priseUsd = $priseUsd, costInOut = $costInOut, walletInOut = $walletInOut");
        listCoin.add(ListCoin(
            coinId: id,
            name: name!,
            symbol: symbol!,
            image: image!,
            quantity: costInOut,
            costUsd: walletInOut,
            costAda: walletAdaInOut,
            marketCap: marketCap,
            percentChange24h: percentChange24h,
            percentChange7d: percentChange7d,
            rank: rank,
            price: priseUsd.toDouble(),
            adaPrice: adaPrise.toDouble(),
            liquidAda: liquidAda.toDouble(),
            isRelevant: isRelevant));

        costInOut = 0.0;
        walletInOut = 0.0;
        walletAdaInOut = 0.0;
      }
    }
    listCoin = await updatedRank(listCoin);
    print("getListCoin listCoin  = $listCoin");
    return listCoin;
  }

  Future<List<Tokens>> getCardanoList(var internet) async {
    List<Tokens> cardanoList = [];
    if (internet) {
      try {
        Response responseCardano = await _apiRepository.getCardanoTokensList();
        int statusCardano = responseCardano.statusCode;
        if (statusCardano == HttpStatus.ok) {
          Map data = jsonDecode(responseCardano.body);
          cardanoList = (data["tokens"] as List)
              .map((e) => Tokens.fromJson(e))
              .cast<Tokens>()
              .toList();
        } else {
          print('http error');
        }
      } on Exception catch (e) {
        print('Exception::: $e');
      }
    }
    return cardanoList;
  }

  Future<int> checkRelevantCardanotoken(String id, var cardanoList) async {
    int isRelevant = 1;
    for (var cardano in cardanoList) {
      print("!!!!222 cardano id = $id , cardano = $cardano");
      if (cardano.tokenId == id) {
        isRelevant = 1;
        break;
      } else {
        isRelevant = 0;
      }
    }
    return isRelevant;
  }

  Future<void> savePrices(String formattedDateCache) async {
    //Response response = await _apiRepository.check();
    //if (response.statusCode == HttpStatus.ok) {
    //  var coinList = jsonDecode(response.body);
    //    List<CoinModel> coinPrice = (coinList as List)
    // //    .map((i) => CoinModel.fromJson(i))
    //     .toList();
    //  print("coinPrice1 = $coinPrice");
    //  await FileManager.saveList(coinList);
    // var now = new DateTime.now();
    //var formatterCache = new DateFormat('yyyy-MM-dd hh:mm');
    //// String formattedDateCache = formatterCache.format(now);
    var coinsId = await _hiveProfileRepository.getCoinId();
    print("coinsId ProfBloc = $coinsId");

    if (coinsId.isNotEmpty) {
      await FileManager.saveDateCache(formattedDateCache);
      print("getDateCache = ${FileManager.readDateCache().toString()}");
      Response responseCardano = await _apiRepository.getCardanoTokensList();
      for (var coinElem in coinsId) {
        if (responseCardano.statusCode == HttpStatus.ok) {
          Map data = jsonDecode(responseCardano.body);
          profile.adaExchangeGlobal = data["usd"] as double;
          var cardanoList = (data["tokens"] as List)
              .map((e) => Tokens.fromJson(e))
              .cast<Tokens>()
              .toList();
          for (var cardano in cardanoList) {
            if (coinElem.id == cardano.tokenId) {
              var coin = CoinEntity(
                  coinId: cardano.tokenId!,
                  name: cardano.name!,
                  symbol: cardano.assetName!,
                  image:
                      'https://ctokens.io/api/v1/tokens/images/${cardano.policyId}.${cardano.assetId}.png',
                  currentPrice: cardano.priceUsd!,
                  marketCap: cardano.capUsd!.toInt(),
                  percentChange24h: cardano.priceTrend24h,
                  percentChange7d: cardano.priceTrend7d,
                  rank: cardano.decimals,
                  price: cardano.priceUsd,
                  adaPrice: cardano.priceAda,
                  liquidAda: cardano.liquidAda,
                  isRelevant: 1);
              await FileManager.saveCoinById(
                  coinElem.id, (coin.toDatabaseJson()));
              await _dbRepository.updateCoinIsRelevant(coin);
            }
          }
        } else {
          var coinIdDB = await _dbRepository.getCoin(coinElem.id);
          var coin = CoinEntity(
              coinId: coinElem.id,
              name: coinIdDB.name,
              symbol: coinIdDB.symbol,
              image: coinIdDB.image,
              currentPrice: coinIdDB.currentPrice,
              marketCap: coinIdDB.marketCap,
              percentChange24h: coinIdDB.percentChange24h,
              percentChange7d: coinIdDB.percentChange7d,
              rank: coinIdDB.rank,
              price: coinIdDB.price,
              adaPrice: coinIdDB.adaPrice,
              liquidAda: coinIdDB.liquidAda,
              isRelevant: 0);
          await FileManager.saveCoinById(coinElem.id, (coin.toDatabaseJson()));
          await _dbRepository.updateCoinIsRelevant(coin);
        }
      }
    }
  }

  updatedRank(List<ListCoin> listCoin) async {
    listCoin.sort((b, a) => a.liquidAda!.compareTo(b.liquidAda!));
    List<ListCoin> list = [];
    var i = 0;
    for (var element in listCoin) {
      i++;
      list.add(ListCoin(
          coinId: element.coinId,
          name: element.name,
          symbol: element.symbol,
          image: element.image,
          quantity: element.quantity,
          costUsd: element.costUsd,
          costAda: element.costAda,
          marketCap: element.marketCap,
          percentChange24h: element.percentChange24h,
          percentChange7d: element.percentChange7d,
          rank: i,
          price: element.price,
          adaPrice: element.adaPrice,
          liquidAda: element.liquidAda,
          isRelevant: element.isRelevant));
    }
    return list;
  }
}
