
part of 'SaveCoinBloc.dart';

abstract class SaveCoinEvent extends Equatable {
  const SaveCoinEvent();

  @override
  List<Object> get props => [];
}

class SaveCoin extends SaveCoinEvent {
  final CoinEntity coin;

  const SaveCoin({required this.coin});

  @override
  List<Object> get props => [coin];
}

