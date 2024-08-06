
import 'package:crypto_offline/data/dbhive/WalletModel.dart';
import 'package:crypto_offline/data/model/CurrentPrice.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:equatable/equatable.dart';

class TransactionState extends Equatable {

  TransactionState(this.state, [List<TransactionEntity>? transactionById, List<TransactionEntity>? transaction, List<CurrentPrice>? coinId, List<double>? walletCoin,
    List<double>? walletAda, List<WalletModel>? listTrastWallet, int? transactionId]) {
    this.coinId = coinId;
    this.transaction = transaction;
    this.transactionById = transactionById;
    this.walletCoin = walletCoin;
    this.walletAda = walletAda;
    this.listTrastWallet = listTrastWallet;
    this.transactionId = transactionId;
  }

  final TransactionStatus state;
  late final List<CurrentPrice>? coinId;
  late final List<TransactionEntity>? transaction;
  late final List<TransactionEntity>? transactionById;
  late final List<double>? walletCoin;
  late final List<double>? walletAda;
  late final List<WalletModel>? listTrastWallet;
  late final int? transactionId;

  TransactionState copyWith(
      TransactionStatus status, [List<TransactionEntity>? transactionById, List<TransactionEntity>? transaction, List<CurrentPrice>? coinId, List<double>? walletCoin,
        List<double>? walletAda, List<WalletModel>? listTrastWallet, int? transactionId]) {
    return TransactionState(status, transactionById, transaction, coinId, walletCoin, walletAda, listTrastWallet, transactionId );
  }

  @override
  List<Object> get props => [state];
}

enum TransactionStatus {start, get}