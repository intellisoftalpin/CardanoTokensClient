
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class SaveTransaction extends TransactionEvent {
  final List<TransactionEntity> transaction;
  const SaveTransaction({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

class CreateTransaction extends TransactionEvent {
  const CreateTransaction();

  @override
  List<Object> get props => [];
}

class CoinTransaction extends TransactionEvent {
  final String id;
  final List<double> walletCoin;
  final List<TrastWalletEntity> listTrastWallet;
  final int transactionId;
  final List<TransactionEntity> transactionById;

  const CoinTransaction({required this.id, required this.transactionId, required this.transactionById,
    required this.walletCoin, required this.listTrastWallet});

  @override
  List<Object> get props => [id, transactionId, transactionById,  walletCoin, listTrastWallet];
}

class GetByTransactionId extends TransactionEvent {
  final int transactionId;
  final List<TransactionEntity> transactionById;

  const GetByTransactionId({required this.transactionId, required this.transactionById});

  @override
  List<Object> get props => [transactionId, transactionById];
}
