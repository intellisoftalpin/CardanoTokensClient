
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:equatable/equatable.dart';

class ProfileTransactionState extends Equatable {

  // ignore: non_constant_identifier_names
  ProfileTransactionState(this.state, [List<double>? walletCoin, List<double>? walletAda, List<TransactionEntity>? transactionList,
    String? coinId, int? transactionId]) {
    this.walletCoin = walletCoin;
    this.walletAda = walletAda;
    this.coinId = coinId;
    this.transactionList = transactionList;
    this.transactionId = transactionId;
  }

  final ProfileTransactionStatus state;
  late final List<double>? walletCoin;
  late final List<double>? walletAda;
  late final String? coinId;
  late final List<TransactionEntity>? transactionList;
  late final int? transactionId;

  ProfileTransactionState copyWith(
      ProfileTransactionStatus status, [List<double>? walletCoin, List<double>? walletAda, List<TransactionEntity>? transactionList,
        String? coinId, int? transactionId]) {
    return ProfileTransactionState(status, walletCoin, walletAda, transactionList, coinId );
  }

  @override
  List<Object> get props => [state];
}

enum ProfileTransactionStatus {start, get}