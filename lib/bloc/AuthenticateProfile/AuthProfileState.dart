
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:equatable/equatable.dart';

class AuthProfileState extends Equatable {
  AuthProfileState(this.state, List<ProfileModel> profileExist){
    this.profileExist = profileExist;
  }

  final AuthProfileStatus state;
  late final List<ProfileModel> profileExist;

  AuthProfileState copyWith(AuthProfileStatus status, List<ProfileModel> profileExist) {
    return AuthProfileState(status, profileExist);
  }

  @override
  List<Object> get props => [state];
}

enum AuthProfileStatus { start, exist, noexist }

// class SaveCoinState extends Equatable {
//   // ignore: non_constant_identifier_names
//   SaveCoinState(this.state) ;
//
//   final SaveCoinStatus state;
//
//
//   SaveCoinState copyWith(SaveCoinStatus status) {
//     return SaveCoinState(status);
//   }
//
//   @override
//   List<Object> get props => [state];
// }
//
// enum SaveCoinStatus { save }

