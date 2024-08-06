
import 'package:equatable/equatable.dart';

abstract class AddCoinEvent extends Equatable {
  const AddCoinEvent();

  @override
  List<Object> get props => [];
}

class CreateAddCoin extends AddCoinEvent {
  final String coin;
  const CreateAddCoin({required this.coin});

  @override
  List<Object> get props => [coin];
}

// class SaveAddCoin extends AddCoinEvent {
//   final CoinEntity coin;
//   const SaveAddCoin({required this.coin}) : assert(coin != null);
//
//   @override
//   List<Object> get props => [coin];
// }
