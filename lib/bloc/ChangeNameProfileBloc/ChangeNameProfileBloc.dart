import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

import '../../data/dbhive/HivePrefProfileRepositoryImpl.dart';
import '../../data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import '../../view/CreateProfilePage/CreateProfilePage.dart';

part 'ChangeNameProfileEvent.dart';

part 'ChangeNameProfileState.dart';

class ChangeNameProfileBloc
    extends Bloc<ChangeNameProfileEvent, ChangeNameProfileState> {
  final HivePrefProfileRepository _hiveProfileRepository;
  final DbRepository _dbRepository;
  String profile;
  String newProfile;

  ChangeNameProfileBloc(this._dbRepository, this._hiveProfileRepository,
      this.profile, this.newProfile)
      : super(ChangeNameProfileState(ChangeNameProfileStatus.start)) {
    add(ChangeNameProfile(profile: '', newProfile: ''));
  }

  @override
  Stream<ChangeNameProfileState> mapEventToState(
      ChangeNameProfileEvent event) async* {
    if (event is ChangeNameProfile) {
      yield* _changeNameProfile(event);
    }
  }

  Stream<ChangeNameProfileState> _changeNameProfile(
      ChangeNameProfileEvent event) async* {
    SharedPrefProfileRepositoryImpl _prefProfileRepository =
        SharedPrefProfileRepositoryImpl();
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);
      print(
          "profile= $profile newProfile = $newProfile  global.idProfile = ${global.idProfile}  ");

      await _hiveProfileRepository.renameProfile(
          profile, newProfile, global.idProfile, globals.passPrefer);

      print(
          ':::ChangeNameProfileBloc::: showProfile = ${await _hiveProfileRepository.showProfile()}');

      await _prefProfileRepository.saveProfile('lastProf', newProfile);
      int pref = await getPassPref(global.idProfile);
      globals.nameProfile = newProfile;
      if (pref == 0) {
        String? pass = box.read('${profile + global.idProfile}pass');
        box.write('${newProfile + global.idProfile}pass', pass);
        int createDate = box.read('${profile + global.idProfile}create_time');
        int enterDate = box.read('${profile + global.idProfile}enter_time');
        box.write('${newProfile + global.idProfile}create_time', createDate);
        box.write('${newProfile + global.idProfile}enter_time', enterDate);
      }

      yield state.copyWith(ChangeNameProfileStatus.start);
    } on Exception catch (e) {
      print(Error.safeToString(e));
      print("Exception $e");
    }
  }
}
