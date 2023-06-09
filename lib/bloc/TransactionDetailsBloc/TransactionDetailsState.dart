import 'package:crypto_offline/domain/entities/TransactionEntity.dart';

class TransactionDetailsState{
   TransactionDetailsState([this.transactionDetails]);
  final TransactionEntity? transactionDetails;

   TransactionDetailsState copyWith(
       TransactionEntity testData) {
    return TransactionDetailsState(testData);
  }
}
