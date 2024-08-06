
import 'package:equatable/equatable.dart';

import '../../domain/entities/ListCoin.dart';

// ignore: must_be_immutable
class AddCoinState extends Equatable {
  final AddCoinStatus state;
  late final List<ListCoin> ? listCoin;
  late bool internet;

  // ignore: non_constant_identifier_names
  AddCoinState(this.state, this.internet, this.listCoin);

  AddCoinState copyWith(
      AddCoinStatus status, bool internet,
      [List<ListCoin> ? listCoin]
      ) {
    return AddCoinState(status, internet, listCoin);
  }

  @override
  List<Object> get props => [state, internet, listCoin!];
}

enum AddCoinStatus { start, update}
