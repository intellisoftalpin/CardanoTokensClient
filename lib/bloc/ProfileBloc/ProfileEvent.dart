part of 'ProfileBloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  List<Object> get props => [];
}

class CreateProfile extends ProfileEvent {
  const CreateProfile();

  @override
  List<Object> get props => [];
}

class StartProfile extends ProfileEvent {
  const StartProfile();  //

  @override
  List<Object> get props => []; //
}


// class SaveAddCoin extends ProfileEvent {
//   final CoinEntity coin;
//   const SaveAddCoin({required this.coin}) : assert(coin != null);
//
//   @override
//   List<Object> get props => [coin];
// }
