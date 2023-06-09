import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;
import 'AuthProfileEvent.dart';
import 'AuthProfileState.dart';

class AuthProfileBloc extends Bloc<AuthProfileEvent, AuthProfileState> {
  AuthProfileBloc(this._prefProfileRepository, this._hiveProfileRepository)
      : super(AuthProfileState(AuthProfileStatus.exist, [])) {
    add(LoggedIn());
  }

  final SharedPrefProfileRepository _prefProfileRepository;
  final HivePrefProfileRepository _hiveProfileRepository;

  @override
  Stream<AuthProfileState> mapEventToState(AuthProfileEvent event) async* {
    if (event is LoggedIn) {
      yield* _setProfile(event);
    } else if (event is LoggedOut) {
      yield* _saveLastProfile(event);
    } else if (event is Logged) {
      yield* _delLastProfileKey(event);
    }
  }

  Stream<AuthProfileState> _setProfile(AuthProfileEvent event) async* {
    try {
      final profileExist = await _hiveProfileRepository.showProfile();
      print("profileExist=  $profileExist");

      if (profileExist.isNotEmpty) {
        var lastProfile = ((await _prefProfileRepository.readProfile('lastProf')).isEmpty ||
            await _prefProfileRepository.readProfile('lastProf') == 'null') ?
        (await _hiveProfileRepository.showProfile()).last.nameProfile : await _prefProfileRepository.readProfile('lastProf');

        for(var profile in profileExist) {
          if(profile.nameProfile == lastProfile) {
            global.idProfile = profile.id;
          }
        }
        globals.nameProfile = lastProfile;

        print("globals.nameProfile=  ${globals.nameProfile} global.idProfile = ${global.idProfile}   profileAll = $profileExist");

        yield state.copyWith(AuthProfileStatus.exist, profileExist);
      } else {
        yield state.copyWith(AuthProfileStatus.noexist, []);
      }
    } on Exception catch (e) {
      print(Error.safeToString(e));
      throw CacheExeption();
    }
  }

  Stream<AuthProfileState> _saveLastProfile(AuthProfileEvent event) async* {
    try {
      if(globals.nameProfile.isNotEmpty && global.idProfile.isNotEmpty && globals.pass.isNotEmpty ||
          globals.nameProfile != '' && global.idProfile != '' && globals.pass != '') {
      await _prefProfileRepository.saveProfile('lastProf', globals.nameProfile);
      await _prefProfileRepository.saveProfile('lastIdProf', global.idProfile);
      var lastProfile = await _prefProfileRepository.readProfile('lastProf');
      print("profileSaveLast=  $lastProfile, globals.pass = ${globals.pass}");

         // await _dbRepository.openDb(globals.nameProfile, globals.pass);
         // await _dbRepository.closeDb(globals.nameProfile, globals.pass);
      //  globals.nameProfile = "";  globals.pass = "";
      print("profile deleteDB=  ${globals.nameProfile}, globals.pass = ${globals.pass}");
      }

    } on Exception catch (e) {
      print("_saveLastProfile = $e");
      throw CacheExeption();
    }
  }

  Stream<AuthProfileState> _delLastProfileKey(AuthProfileEvent event) async* {
    try {
      var dellLastKey = await _prefProfileRepository.delProfile('lastProf');
      await _prefProfileRepository.delProfile('lastIdProf');
      print("dellLastKey=  $dellLastKey");
    } on Exception catch (e) {
      print(Error.safeToString(e));
      throw CacheExeption();
    }
  }
}
