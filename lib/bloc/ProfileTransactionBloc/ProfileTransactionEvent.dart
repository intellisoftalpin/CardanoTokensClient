
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileTransactionEvent extends Equatable {
  const ProfileTransactionEvent();

  @override
  List<Object> get props => [];
}

class CreateProfileTransaction extends ProfileTransactionEvent {
  final List<double> walletCoin;
  final List<double> walletAda;
  final List<TransactionEntity> listTransaction;
  final String id;

  const CreateProfileTransaction({ required this.walletCoin, required this.walletAda, required this.listTransaction, required this.id});

  @override
  List<Object> get props => [walletCoin, walletAda, listTransaction];
}

class DeleteTransaction extends ProfileTransactionEvent {
  final int transactionId;

  const DeleteTransaction({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}

class DeleteTransactionDetailsPage extends ProfileTransactionEvent {
  final int transactionId;

  const DeleteTransactionDetailsPage({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}


