
import 'dart:async';
import 'package:crypto_offline/bloc/TransactionDetailsBloc/TransactionDetailsState.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;
import 'TransactionDetailsEvent.dart';


class TransactionDetailsBloc extends Bloc<TransactionDetailsEvent, TransactionDetailsState> {
  final DbRepository _dbRepository;
   String id;
 int transactionId;


  TransactionDetailsBloc(this._dbRepository, this.id, this.transactionId)
      : super(TransactionDetailsState()) {
    add(GetTransactionInfo());
  }

  @override
  Stream<TransactionDetailsState> mapEventToState(TransactionDetailsEvent event) async* {
    if (event is GetTransactionInfo) {
      yield* _getTransactionDetailsInfo(event, state);
    }
  }

  Stream<TransactionDetailsState> _getTransactionDetailsInfo(TransactionDetailsEvent  event, TransactionDetailsState state) async* {
    try {
      if(transactionId == -1){
        await _dbRepository.openDb(global.idProfile, globals.pass);
        List<TransactionEntity> list =  await _dbRepository.getAllTransactionByIdCoin(id);
        TransactionEntity transaction =  list.last;
        yield state.copyWith(transaction);
      }else{
        await _dbRepository.openDb(global.idProfile, globals.pass);
        List<TransactionEntity> transaction = await _dbRepository.getTransaction(transactionId);
        yield state.copyWith(transaction.first);
      }
    } on Exception catch (e) {
      print("e = $e");
      throw Exception();
    }
  }

}