import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/PriceEntity.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/utils/file_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;
import 'package:http/http.dart';
import '../../data/model/CardanoModel.dart';
import 'ProfileTransactionEvent.dart';
import 'ProfileTransactionState.dart';

class ProfileTransactionBloc
    extends Bloc<ProfileTransactionEvent, ProfileTransactionState> {
  List<TransactionEntity> listTransaction;
  final DbRepository _dbRepository;
  final IApiRepository _apiRepository;
  String coinId;
  List<double> walletCoin;
  List<double> walletAda;
  int transactionId;

  ProfileTransactionBloc(
      this._dbRepository,
      this._apiRepository,
      this.walletCoin,
      this.walletAda,
      this.listTransaction,
      this.coinId,
      this.transactionId)
      : super(ProfileTransactionState(ProfileTransactionStatus.start)) {
    add(CreateProfileTransaction(
        id: coinId, listTransaction: [], walletCoin: [], walletAda: []));
  }

  @override
  Stream<ProfileTransactionState> mapEventToState(
      ProfileTransactionEvent event) async* {
    if (event is CreateProfileTransaction) {
      coinId = event.id;
      yield* _getListTransaction(event, state);
    } else if (event is DeleteTransaction) {
      transactionId = event.transactionId;
      yield* _deleteTransaction(event);
    } else if (event is DeleteTransactionDetailsPage) {
      transactionId = event.transactionId;
      yield* _deleteTransactionDetailsPage(event);
    }
  }

  Stream<ProfileTransactionState> _getListTransaction(
      ProfileTransactionEvent event, ProfileTransactionState state) async* {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2016-01-25
    List<PriceEntity> priceEntity = [];
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);
      print("coinId = $coinId");
      if (coinId.isNotEmpty) {
        listTransaction = await _dbRepository.getAllTransactionByIdCoin(coinId);
        print('listTransaction = $listTransaction');

        if (listTransaction.isNotEmpty) {
          priceEntity = await getPriceEntity(formattedDate, coinId);
          walletCoin =
              await getWalletCoin(listTransaction, formattedDate, priceEntity);
          walletAda =
              await getWalletAda(listTransaction, formattedDate, priceEntity);
          yield state.copyWith(ProfileTransactionStatus.get, walletCoin,
              walletAda, listTransaction);
        } else {
          listTransaction = [];
          walletCoin = [];
          walletAda = [];
          yield state.copyWith(ProfileTransactionStatus.get, walletCoin,
              walletAda, listTransaction);
        }
      }
    } on Exception catch (_) {
      throw CacheExeption();
    }
  }

  Stream<ProfileTransactionState> _deleteTransaction(
      ProfileTransactionEvent event) async* {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2016-01-25
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);
      print("transactionId = $transactionId");
      await _dbRepository.deleteTransaction(transactionId);
      listTransaction = await _dbRepository.getAllTransactionByIdCoin(coinId);
      print("list = $listTransaction");

      yield state.copyWith(ProfileTransactionStatus.start);
    } on Exception catch (_) {
      throw CacheExeption();
    }
  }

  Stream<ProfileTransactionState> _deleteTransactionDetailsPage(
      ProfileTransactionEvent event) async* {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2016-01-25
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);
      print("transactionId = $transactionId");
      if (transactionId == -1) {
        listTransaction = await _dbRepository.getAllTransactionByIdCoin(coinId);
        log("\n\n\n\nlist before delete= $listTransaction\n\n\n\n");
        TransactionEntity lastTransaction = listTransaction.last;
        transactionId = lastTransaction.transactionId!;
      }

      ///TODO: add the check for the empty list case. It would be necessary if after the pressing cancel we will push to the TransactionDetailsPage.
      await _dbRepository.deleteTransaction(transactionId);
      listTransaction = await _dbRepository.getAllTransactionByIdCoin(coinId);
      log("\n\n\n\nlist after the transaction delete  = $listTransaction\n\n\n\n\n");

      yield state.copyWith(ProfileTransactionStatus.start);
    } on Exception catch (_) {
      throw CacheExeption();
    }
  }

  Future<List<PriceEntity>> getPriceEntity(
      String formattedDate, String id) async {
    List<PriceEntity> priceEntity = [];
    var internet = await _apiRepository.check();
    print('getPriceEntity ID=== $id');
    print(
        'getPriceEntity FileManager.readList()=== ${await FileManager.readList()}');
    print(
        'await FileManager.readCoinById(id) === ${await FileManager.readCoinById(id)}');
    if (await FileManager.readCoinById(id) != null) {
      print('getPriceEntity FileManager.readCoinById(id) != null');
      CoinEntity coinById =
          CoinEntity.fromDatabaseJson(await FileManager.readCoinById(id));
      print("intenet = $internet, coinById getPriceEntity = $coinById");
      priceEntity = [
        PriceEntity(
            date: formattedDate,
            coinId: coinById.coinId,
            usdPrice: coinById.price,
            adaPrice: coinById.adaPrice,
            name: coinById.name,
            symbol: coinById.symbol)
      ];
      print("priceEntity = $priceEntity");
    } else {
      print('ELSE getPriceEntity FileManager.readCoinById(id) != null');
      if (internet) {
        try {
          Response responseCardano =
              await _apiRepository.getCardanoTokensList();
          var statusCardano = responseCardano.statusCode;
          if (statusCardano == HttpStatus.ok) {
            Map data = jsonDecode(responseCardano.body);
            var cardanoList = (data["tokens"] as List)
                .map((e) => Tokens.fromJson(e))
                .cast<Tokens>()
                .toList();
            for (var cardano in cardanoList) {
              print(" cardano.tokenId = ${cardano.tokenId}, coinId = $coinId");
              if (cardano.tokenId == coinId) {
                priceEntity = [
                  PriceEntity(
                      date: formattedDate,
                      coinId: coinId,
                      name: cardano.name!,
                      symbol: cardano.assetName!,
                      usdPrice: cardano.priceUsd!,
                      adaPrice: cardano.priceAda)
                ];
                print("priceEntity cardano = $priceEntity");
                break;
              } else {
                // await _dbRepository.openDb(global.idProfile, globals.pass);
                CoinEntity coin = await _dbRepository.getCoin(coinId);
                priceEntity = [
                  PriceEntity(
                      date: formattedDate,
                      coinId: coinId,
                      name: coin.name,
                      symbol: coin.symbol,
                      usdPrice: coin.price,
                      adaPrice: coin.adaPrice)
                ];
                print("priceEntity DB = $priceEntity  coin = $coin");
              }
            }
          } else if ((await _dbRepository.getCoin(id)).coinId.isNotEmpty) {
            CoinEntity coin = await _dbRepository.getCoin(id);
            priceEntity = [
              PriceEntity(
                  date: formattedDate,
                  coinId: id,
                  name: coin.name,
                  symbol: coin.symbol,
                  usdPrice: coin.price,
                  adaPrice: coin.adaPrice)
            ];
          }
        } on Exception catch (e) {
          print('Exception::: $e');
          if ((await _dbRepository.getCoin(id)).coinId.isNotEmpty) {
            CoinEntity coin = await _dbRepository.getCoin(id);
            priceEntity = [
              PriceEntity(
                  date: formattedDate,
                  coinId: id,
                  name: coin.name,
                  symbol: coin.symbol,
                  usdPrice: coin.price,
                  adaPrice: coin.adaPrice)
            ];
          }
        }
      } else {
        if ((await _dbRepository.getCoin(id)).coinId.isNotEmpty) {
          CoinEntity coin = await _dbRepository.getCoin(id);
          priceEntity = [
            PriceEntity(
                date: formattedDate,
                coinId: id,
                name: coin.name,
                symbol: coin.symbol,
                usdPrice: coin.price,
                adaPrice: coin.adaPrice)
          ];
        }
      }
    }
    return priceEntity;
  }

  Future<List<double>> getWalletCoin(List<TransactionEntity> transactions,
      String formattedDate, List<PriceEntity> priceEntity) async {
    double walletInOut = 0;
    double costInOut = 0;
    double priseUsd = 0;
    var cost = 0.0;
    List<double> walleted = [];
    print("priceEntity = $priceEntity");
    for (var element in transactions) {
      cost = element.qty;
      for (var price in priceEntity) {
        print("price.coinId == element.coinId = ${element.coinId}");
        if (price.coinId == element.coinId) {
          priseUsd = price.usdPrice!;
        }
      }
      print("!!!!!!!!!usdPrice = $priseUsd");
      if (element.type == 'In') {
        walletInOut += cost * priseUsd;
        costInOut += cost;
      } else if (element.type == 'Out') {
        walletInOut -= cost * priseUsd;
        costInOut -= cost;
      }
      walleted.clear();
      walleted.insert(0, costInOut);
      walleted.insert(1, priseUsd);
      walleted.insert(2, walletInOut);
      print("getWallet = $walleted");
    }
    return walleted;
  }

  Future<List<double>> getWalletAda(List<TransactionEntity> transactions,
      String formattedDate, List<PriceEntity> priceEntity) async {
    double walletAdaInOut = 0;
    double costAdaInOut = 0;
    double priseAda = 0;
    var cost = 0.0;
    List<double> walletedAda = [];
    print("priceEntity = $priceEntity");
    for (var element in transactions) {
      cost = element.qty;
      for (var price in priceEntity) {
        print("price.coinId == element.coinId = ${element.coinId}");
        if (price.coinId == element.coinId) {
          print('price.adaPrice:: ${price.adaPrice}');
          priseAda = price.adaPrice!;
        }
      }
      if (element.type == 'In') {
        walletAdaInOut += cost * priseAda;
        costAdaInOut += cost;
      } else if (element.type == 'Out') {
        walletAdaInOut -= cost * priseAda;
        costAdaInOut -= cost;
      }
      walletedAda.clear();
      walletedAda.insert(0, costAdaInOut);
      walletedAda.insert(1, priseAda);
      walletedAda.insert(2, walletAdaInOut);
      print("getWalletAda = $walletedAda");
    }
    return walletedAda;
  }
}
