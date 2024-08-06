
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinState.dart';
import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/utils/file_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;

part 'SaveCoinEvent.dart';


class SaveCoinBloc extends Bloc<SaveCoinEvent, SaveCoinState> {
  final DbRepository _dbRepository;
  final HivePrefProfileRepository _hiveProfileRepository;
  CoinEntity coinEntity;

  SaveCoinBloc(this._dbRepository, this._hiveProfileRepository, this.coinEntity) : super(SaveCoinState(SaveCoinStatus.save)) {
    add(SaveCoin(coin: coinEntity));
  }

  @override
  Stream<SaveCoinState> mapEventToState(SaveCoinEvent event) async* {
    if (event is SaveCoin) {
      coinEntity = event.coin;
      print("coinEntity = $coinEntity");
      yield* _setCoin(event);
    }
  }

  Stream<SaveCoinState> _setCoin(SaveCoinEvent event) async* {
      try {
        await _dbRepository.openDb(global.idProfile, globals.pass);
        await _dbRepository.putCoin(coinEntity);
        print("coinEntity save db = $coinEntity");

        await _hiveProfileRepository.saveCoinId(coinEntity.coinId);
        print("_hiveProfileRepository coinById = ${await _hiveProfileRepository.getCoinId()}");

        await FileManager.saveCoinById(coinEntity.coinId, coinEntity.toDatabaseJson());

        yield state.copyWith(SaveCoinStatus.save);

      } on Exception catch (e) {
        print(" CacheExeption = $e");
        throw CacheExeption();
      }
  }

}