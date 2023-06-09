import 'package:equatable/equatable.dart';

abstract class TransactionDetailsEvent extends Equatable {
  const TransactionDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetTransactionInfo extends TransactionDetailsEvent {

  const GetTransactionInfo();

  @override
  List<Object> get props => [];
}