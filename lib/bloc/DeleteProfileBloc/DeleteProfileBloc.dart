import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
as globals;

part 'DeleteProfileEvent.dart';

part 'DeleteProfileState.dart';


class DeleteProfileBloc extends Bloc<DeleteProfileEvent, DeleteProfileState> {
  final HivePrefProfileRepository _hiveProfileRepository;
  final DbRepository _dbRepository;
  String profile;
  String idProfile;

  DeleteProfileBloc(
      this._dbRepository, this._hiveProfileRepository, this.profile, this.idProfile)
      : super(DeleteProfileState(DeleteProfileStatus.start)) {
    add(DeleteProfile(profile: '', idProfile: ''));
  }

  @override
  Stream<DeleteProfileState> mapEventToState(DeleteProfileEvent event) async* {
    if (event is DeleteProfile) {
      yield* _delProfile(event);
    }
  }

  Stream<DeleteProfileState> _delProfile(DeleteProfileEvent event) async* {
    try {
        await _dbRepository.openDb(profile, globals.pass);
        print("profile= $profile");
        final profileExist = await _hiveProfileRepository.deleteGroupFrom(profile, idProfile);

        yield state.copyWith(DeleteProfileStatus.start, profileExist);
    } on Exception catch (e) {
      print(Error.safeToString(e));
      print("Exception $e");
    }
  }
}
