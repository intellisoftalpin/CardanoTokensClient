part of 'ProfileBloc.dart';

class ProfileState extends Equatable {
  final ProfileStatus state;
  final List<double>? wallet;
  final List<double>? walletAda;
  late final List<ListCoin> ? listCoin;
  late final List<ProfileModel> profile;
  late final bool? isErrorEmpty;

  ProfileState(this.state, this.wallet, this.walletAda, this.profile, [List<ListCoin> ? listCoin, bool? isErrorEmpty]) {
    this.listCoin = listCoin;
    this.isErrorEmpty = isErrorEmpty;
  }

  ProfileState copyWith(
      ProfileStatus status, List<double>? wallet, List<double>? walletAda, List<ProfileModel> profile, [List<ListCoin> ? listCoin, bool? isErrorEmpty]) {
    return ProfileState(status, wallet, walletAda, profile, listCoin, isErrorEmpty);
  }

  @override
  List<Object> get props => [state, wallet!, walletAda!, profile];
}

enum ProfileStatus { loaded, loading, load, start, update }
